// ignore_for_file: unused_field, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:bantay_72_users/constants.dart';
import 'package:scaler/scaler.dart';

class ChooseFromMapsScreen extends StatefulWidget {
  const ChooseFromMapsScreen({super.key});

  @override
  State<ChooseFromMapsScreen> createState() => _ChooseFromMapsScreenState();
}

class _ChooseFromMapsScreenState extends State<ChooseFromMapsScreen> {
  final Completer<GoogleMapController> mapController = Completer();
  final Location locationController = Location();
  final TextEditingController searchController = TextEditingController();

  LatLng _currentPos = const LatLng(14.6105, 120.9630);
  LatLng _cameraCenter = const LatLng(14.6105, 120.9630);
  List<dynamic> _placePredictions = [];

  bool _isCameraMoving = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose from maps',
          style: GoogleFonts.poppins(color: white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController.complete(controller),
            initialCameraPosition: CameraPosition(
              target: _cameraCenter,
              zoom: 15.0,
            ),
            onCameraMove: (position) {
              _cameraCenter = position.target;
              if (!_isCameraMoving) {
                setState(() => _isCameraMoving = true);
              }
            },
            onCameraIdle: () {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () async {
                setState(() {
                  _isCameraMoving = false;
                  _currentPos = _cameraCenter;
                });
                await updateSearchFieldFromLatLng(_cameraCenter);
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Fixed Center Pin
          Center(
            child: IgnorePointer(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.only(bottom: _isCameraMoving ? 15 : 0),
                child: const Icon(Icons.location_pin, size: 50, color: Primary),
              ),
            ),
          ),

          // Search Bar & Autocomplete
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) async {
                      if (val.isEmpty) {
                        setState(() => _placePredictions = []);
                        return;
                      }
                      final suggestions = await fetchAutocompleteSuggestions(
                        val,
                      );
                      setState(() => _placePredictions = suggestions);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search location',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                    ),
                  ),
                ),
                if (_placePredictions.isNotEmpty)
                  Container(
                    color: white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _placePredictions.length,
                      itemBuilder: (context, index) {
                        final place = _placePredictions[index];
                        return ListTile(
                          title: Text(place['description']),
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            final LatLng? pos = await fetchPlaceLocation(
                              place['placeId'],
                            );
                            if (pos != null) {
                              _moveCamera(pos);
                              setState(() {
                                _currentPos = pos;
                                _placePredictions = [];
                                searchController.text = place['description'];
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CustomButton(
              onTap: () {
                Navigator.pop(context, {
                  'position': _currentPos,
                  'address': searchController.text,
                }); // return position to previous screen
              },
              leading: const Icon(Icons.check),
              buttonName: 'Confirm Location',
              height: 45.0,
              fontSize: 18.0,
              width: Scaler.width(0.93, context),
            ),
          ),

          // Location Button
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: white,
              onPressed: () async {
                setState(() => _isLoading = true);
                await _goToUserLocation();
                setState(() => _isLoading = false);
              },
              child: const Icon(Icons.my_location, color: black),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Primary),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _moveCamera(LatLng pos) async {
    final controller = await mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 18));
  }

  Future<void> _goToUserLocation() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    final location = await locationController.getLocation();
    if (location.latitude != null && location.longitude != null) {
      final LatLng userLoc = LatLng(location.latitude!, location.longitude!);
      await _moveCamera(userLoc);
      setState(() => _currentPos = userLoc);
      await updateSearchFieldFromLatLng(userLoc);
    }
  }

  Future<bool> _checkPermissions() async {
    bool enabled = await locationController.serviceEnabled();
    if (!enabled) {
      enabled = await locationController.requestService();
      if (!enabled) return false;
    }

    PermissionStatus permission = await locationController.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await locationController.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<void> updateSearchFieldFromLatLng(LatLng pos) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$apiKey&region=ph',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];
      if (results.isNotEmpty) {
        setState(() {
          searchController.text = results[0]['formatted_address'];
        });
      }
    } else {
      print('Reverse geocode failed: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAutocompleteSuggestions(
    String input,
  ) async {

    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete?key=$apiKey',
    );
    final body = {
      "input": input,
      "languageCode": "en",
      "locationRestriction": {
        "rectangle": {
          // Coordinates for Barangay 72, Tondo, Manila, Philippines
          "low": {"latitude": 14.6050, "longitude": 120.9620},
          "high": {"latitude": 14.6150, "longitude": 120.9720},
        },
      },
      "includedRegionCodes": ["ph"],
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['suggestions'] as List)
          .map(
            (e) => {
              "description": e['placePrediction']['text']['text'],
              "placeId": e['placePrediction']['placeId'],
            },
          )
          .toList();
    } else {
      print("Autocomplete error: ${response.body}");
      return [];
    }
  }

  Future<LatLng?> fetchPlaceLocation(String placeId) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places/$placeId?key=$apiKey&fields=location',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final location = jsonDecode(response.body)['location'];
      return LatLng(location['latitude'], location['longitude']);
    } else {
      print("Details error: ${response.body}");
      return null;
    }
  }
}
