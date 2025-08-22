// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:scaler/scaler.dart';

class ChooseLocScreen extends StatefulWidget {
  const ChooseLocScreen({super.key});

  @override
  State<ChooseLocScreen> createState() => _ChooseLocScreenState();
}

class _ChooseLocScreenState extends State<ChooseLocScreen> {
  LatLng? selectedPoint;
  String? selectedAddress;
  List<dynamic> suggestions = [];
  TextEditingController searchController = TextEditingController();
  final MapController _mapController = MapController();
  final apiKey = 'pk.0171199465c4a256c544db1b0ccdc96e';
  bool isLoading = false;
  final double _targetZoom = 18.0;
  Map<String, dynamic>? args;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only fetch arguments once
    if (args == null) {
      final Object? passedArgs = ModalRoute.of(context)?.settings.arguments;
      if (passedArgs != null && passedArgs is Map<String, dynamic>) {
        setState(() {
          args = passedArgs;
        });
      }
    }
  }

  Future<void> fetchAddressFromCoordinates(LatLng coords) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
      'https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=${coords.latitude}&lon=${coords.longitude}&format=json',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fullAddress = data['display_name'];
      final shortAddress = fullAddress.split(',').take(3).join(',').trim();
      setState(() {
        selectedAddress = shortAddress;
        searchController.text = shortAddress;
        isLoading = false;
      });
    } else {
      setState(() {
        selectedAddress = 'Address not found';
        searchController.text = 'Address not found';
        isLoading = false;
      });
    }
  }

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final viewbox = '120.9628,14.6116,120.9638,14.6106';
    final url = Uri.parse(
      'https://us1.locationiq.com/v1/autocomplete.php?key=$apiKey&q=$input&format=json&viewbox=$viewbox&bounded=1&countrycodes=ph',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        suggestions = json.decode(response.body);
      });
    }
  }

  void _handleTap(LatLng latLng) {
    setState(() {
      selectedPoint = latLng;
      suggestions = [];
    });

    _mapController.move(latLng, _targetZoom);
    fetchAddressFromCoordinates(latLng);
  }

  void _locateMe() async {
    try {
      Position? position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
        'https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fullAddress = data['display_name'];
        final shortAddress = fullAddress.split(',').take(4).join(',').trim();
        print('📍 Current Address: $shortAddress');

        // You can set this address to a controller
        setState(() {
          selectedPoint = LatLng(lat, lon);
          selectedAddress = shortAddress;
          searchController.text = shortAddress;
          isLoading = false;
        });

        _mapController.move(LatLng(lat, lon), _targetZoom);
      } else {
        print('Failed to get address: ${response.body}');
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final incidentType = args['incidentType'];
    final username = args['username'];
    final message = args['message'];
    final address = args['address'];
    final status = args['status'];
    final Map<String, dynamic> volunteer = args['volunteer'] ?? {};
    final String volunteerName =
        volunteer['volunteerName']?.toString() ?? 'none';
    final String volunteerPhone =
        volunteer['volunteerPhone']?.toString() ?? 'none';

    Future<void> _sendSOSReport() async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('sos_reports')
              .where('username', isEqualTo: username)
              .where('incidentType', isEqualTo: incidentType)
              .where('location', isEqualTo: selectedAddress)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        await customDialog(
          context,
          title: 'Duplicate Reports',
          content: 'You already submitted this report',
        );
        return;
      }

      bool confirmed = await confirmationDialog(
        context,
        title: "Confirm Submission",
        content: "Are you sure you want to submit this emergency report?",
      );

      if (!confirmed) {
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('sos_reports')
            .add({
              'incidentType': incidentType,
              'userId': user.uid,
              'username': username,
              'address': address,
              'timestamp': FieldValue.serverTimestamp(),
              'message': message,
              'location': selectedAddress,
              'latlng': {
                'lat': selectedPoint?.latitude,
                'lng': selectedPoint?.longitude,
              },
              'volunteer': {
                'volunteerName': volunteerName,
                'volunteerPhone': volunteerPhone,
              },
              'status': status,
            });
        await docRef.update({'docId': docRef.id});

        if (volunteerPhone != 'none' && volunteerName != 'none') {
          await volunteersDialog(context);
          if (mounted) {
            context.go('/home');
          }
        } else {
          await customDialog(
            context,
            title: 'Success',
            content: 'SOS Report sent Successfully!',
          );
          if (mounted) {
            context.go('/home');
          }
        }
      } catch (e) {
        print('Error: $e');
        negateToast(context, message: 'Failed to send SOS. Try again');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Location', style: GoogleFonts.poppins(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_sharp, color: white),
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Container(
                      height: Scaler.height(0.45, context),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            14.6105,
                            120.9630,
                          ), // Brgy 72, Manila
                          initialZoom: 17.0,
                          onTap: (tapPosition, latLng) => _handleTap(latLng),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),
                          if (selectedPoint != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedPoint!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Primary,
                                    size: 40.0,
                                  ),
                                ),
                              ],
                            ),
                          if (isLoading)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: fetchSuggestions,
                              decoration: InputDecoration(
                                hintText: 'Search location',
                                border: InputBorder.none,
                                icon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),

                        if (suggestions.isNotEmpty)
                          Transform.scale(
                            scale: 0.8,
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = suggestions[index];
                                  final fullName = suggestion['display_name'];
                                  final shortName =
                                      fullName
                                          .split(',')
                                          .take(3)
                                          .join(',')
                                          .trim();
                                  return ListTile(
                                    title: Text(shortName),
                                    onTap: () {
                                      final lat = double.parse(
                                        suggestion['lat'],
                                      );
                                      final lon = double.parse(
                                        suggestion['lon'],
                                      );
                                      final fullName =
                                          suggestion['display_name'];
                                      final shortName =
                                          fullName
                                              .split(',')
                                              .take(3)
                                              .join(',')
                                              .trim();
                                      final newPoint = LatLng(lat, lon);

                                      setState(() {
                                        selectedPoint = newPoint;
                                        selectedAddress = shortName;
                                        searchController.text = shortName;
                                        suggestions.clear(); // hide suggestions
                                      });

                                      _mapController.move(
                                        newPoint,
                                        _targetZoom,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 25,
                    right: 15,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: GestureDetector(
                        onTap: _locateMe,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Primary,
                          ),
                          child: Icon(
                            Icons.gps_fixed_outlined,
                            color: white,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 10.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Username: ',
                        style: GoogleFonts.poppins(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                            text: username,
                            style: GoogleFonts.poppins(
                              color: Primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: RichText(
                      text: TextSpan(
                        text: 'Status: ',
                        style: GoogleFonts.poppins(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                            text: status,
                            style: GoogleFonts.poppins(
                              color: Primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Incident: ',
                        style: GoogleFonts.poppins(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                            text: incidentType,
                            style: GoogleFonts.poppins(
                              color: Primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text:
                            volunteerName == 'none' ? 'Volunteer: ' : 'Phone: ',
                        style: GoogleFonts.poppins(
                          color: black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                            text:
                                volunteerName == 'none' ? 'No' : volunteerPhone,
                            style: GoogleFonts.poppins(
                              color: Primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Message: ',
                    style: GoogleFonts.poppins(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                    children: [
                      TextSpan(
                        text: message,
                        style: GoogleFonts.poppins(
                          color: Primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Location: ',
                    style: GoogleFonts.poppins(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                    children: [
                      TextSpan(
                        text: selectedAddress,
                        style: GoogleFonts.poppins(
                          color: Primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Spacer(),

          CustomButton(
            onTap:
                selectedAddress != null && !isLoading
                    ? () async {
                      setState(() {
                        isLoading = true;
                      });

                      await _sendSOSReport();

                      setState(() => isLoading = false);
                    }
                    : null,
            height: 45.0,
            fontSize: 18.0,
            width: Scaler.width(0.93, context),
            buttonName: 'Submit Report',
          ),

          SizedBox(height: 15.0),
        ],
      ),
    );
  }
}
