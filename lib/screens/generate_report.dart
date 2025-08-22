// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_final_fields, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/firebase_services/firestore.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/incidents.dart';
import 'package:bantay_72_users/widgets/maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:scaler/scaler.dart';

class ReportEmergencyScreen extends StatefulWidget {
  const ReportEmergencyScreen({super.key});

  @override
  State<ReportEmergencyScreen> createState() => _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends State<ReportEmergencyScreen> {
  final FirestoreService _firestore = FirestoreService();
  TextEditingController msg = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isSwitched = false;
  bool isLoading = false;
  bool isEditing = false;
  List<dynamic> _placePredictions = [];
  String? volunteerPhoneNumber;
  String? selectedAddress;
  LatLng _cameraCenter = const LatLng(14.6105, 120.9630);
  final Completer<GoogleMapController> mapController = Completer();
  final Location locationController = Location();
  LatLng _currentPos = const LatLng(14.6105, 120.9630);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    msg.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  final List<String> emergencyTypes = [
    'Medical',
    'Fire',
    'Natural Disaster',
    'Accident',
    'Violence',
    'Rescue',
  ];
  int selectedEmergency = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Submit a Report', style: GoogleFonts.rubik(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          'Type of Emergency',
                          style: GoogleFonts.interTight(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IncidentsButton(
                            onTap: () {
                              setState(() {
                                if (selectedEmergency == 0) {
                                  selectedEmergency =
                                      -1; // Deselect if already selected
                                } else {
                                  selectedEmergency = 0;
                                }
                              });
                            },
                            pressed: selectedEmergency == 0,
                            buttonName: 'Medical',
                            icon: Icon(
                              Icons.medical_services_rounded,
                              color: Primary,
                              size: 30.0,
                            ),
                          ),

                          IncidentsButton(
                            onTap: () {
                              setState(() {
                                if (selectedEmergency == 1) {
                                  selectedEmergency =
                                      -1; // Deselect if already selected
                                } else {
                                  selectedEmergency = 1;
                                }
                              });
                            },
                            pressed: selectedEmergency == 1,
                            buttonName: 'Fire',
                            icon: Icon(
                              Elusive.fire,
                              color: Primary,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IncidentsButton(
                              onTap: () {
                                setState(() {
                                  if (selectedEmergency == 2) {
                                    selectedEmergency =
                                        -1; // Deselect if already selected
                                  } else {
                                    selectedEmergency = 2;
                                  }
                                });
                              },
                              pressed: selectedEmergency == 2,
                              buttonName: 'Natural \nDisasters',
                              fontSize: 18.0,
                              icon: Icon(
                                Icons.flood_rounded,
                                color: Primary,
                                size: 30.0,
                              ),
                            ),

                            IncidentsButton(
                              onTap: () {
                                setState(() {
                                  if (selectedEmergency == 3) {
                                    selectedEmergency =
                                        -1; // Deselect if already selected
                                  } else {
                                    selectedEmergency = 3;
                                  }
                                });
                              },
                              pressed: selectedEmergency == 3,
                              buttonName: '\tAccident',
                              fontSize: 18.0,
                              icon: Icon(
                                FontAwesomeIcons.carBurst,
                                color: Primary,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IncidentsButton(
                              onTap: () {
                                setState(() {
                                  if (selectedEmergency == 4) {
                                    selectedEmergency = -1;
                                  } else {
                                    selectedEmergency = 4;
                                  }
                                });
                              },
                              pressed: selectedEmergency == 4,
                              buttonName: 'Violence',
                              icon: Icon(
                                RpgAwesome.dripping_knife,
                                color: Primary,
                                size: 30.0,
                              ),
                            ),

                            IncidentsButton(
                              onTap: () {
                                setState(() {
                                  if (selectedEmergency == 5) {
                                    selectedEmergency = -1;
                                  } else {
                                    selectedEmergency = 5;
                                  }
                                });
                              },
                              pressed: selectedEmergency == 5,
                              buttonName: 'Rescue',
                              icon: Icon(
                                Icons.safety_divider_rounded,
                                color: Primary,
                                size: 35.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      //   child: Text(
                      //     'Location',
                      //     style: GoogleFonts.interTight(
                      //       color: black,
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: Scaler.height(0.05, context),
                      //   child: Divider(
                      //     color: const Color.fromARGB(157, 0, 0, 0),
                      //     thickness: 1,
                      //   ),
                      // ),
                      Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_sharp,
                                    color: Primary,
                                    size: 28.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child:
                                        isEditing
                                            ? TextField(
                                              controller: addressController,
                                              onChanged: (val) async {
                                                if (val.isEmpty) {
                                                  setState(
                                                    () =>
                                                        _placePredictions = [],
                                                  );
                                                  return;
                                                }
                                                final suggestions =
                                                    await fetchAutocompleteSuggestions(
                                                      val,
                                                    );
                                                setState(
                                                  () =>
                                                      _placePredictions =
                                                          suggestions,
                                                );
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter your location',
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Primary,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : Text(
                                              addressController.text.isNotEmpty
                                                  ? addressController.text
                                                  : 'Fetching Location...',

                                              style: GoogleFonts.poppins(
                                                color: black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                  ),

                                  SizedBox(width: 10.0),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isEditing) {
                                          selectedAddress =
                                              addressController.text;
                                          _placePredictions = [];
                                          isEditing = false;
                                        } else {
                                          setState(() {
                                            addressController.text =
                                                selectedAddress ?? '';
                                            isEditing = true;
                                          });
                                        }
                                      });
                                    },
                                    child: Text(
                                      isEditing ? 'Save' : 'Change',
                                      style: GoogleFonts.poppins(
                                        color: Primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15.0),

                              // 🗺️ MAP directly below the input
                              SizedBox(
                                width: double.infinity,
                                height: 220.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0.r),
                                  child: Maps(
                                    initialPosition: _cameraCenter,
                                    onLocationPicked: (newPos) {
                                      setState(() {
                                        _cameraCenter = newPos;
                                        _currentPos = newPos;
                                      });
                                    },
                                    onCameraIdleUpdate:
                                        updateSearchFieldFromLatLng,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 🔼 Floating suggestion list
                          if (_placePredictions.isNotEmpty)
                            Positioned(
                              top:
                                  45, // adjust as needed to appear below TextField
                              left: 30, // match textfield padding/offset
                              right: 15,
                              child: Container(
                                constraints: BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _placePredictions.length,
                                  itemBuilder: (context, index) {
                                    final place = _placePredictions[index];
                                    return ListTile(
                                      title: Text(place['description']),
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        final LatLng? pos =
                                            await fetchPlaceLocation(
                                              place['placeId'],
                                            );
                                        if (pos != null) {
                                          setState(() {
                                            _cameraCenter = pos;
                                            _currentPos = pos;
                                            _placePredictions = [];
                                            addressController.text =
                                                place['description'];
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: CustomButton(
                          onTap:
                              (selectedEmergency == -1 ||
                                      (addressController.text.trim().isEmpty ||
                                          _currentPos == null))
                                  ? null
                                  : _displayReportDetails, //selectedEmergency == -1 ? null : _sendSOSReport,
                          height: 50,
                          width: double.infinity,
                          buttonName: 'Submit Report',
                          fontSize: 20.0.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _displayReportDetails() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await _firestore.fetchDocument(
      context: context,
      collection: 'users',
      docId: userId,
    );

    final data = userDoc?.data() as Map<String, dynamic>;
    final phone = data['phone'] ?? 'None';
    final user = data['username'] ?? 'Unknown';
    final address = data['address'] ?? 'None';

    final result = await showReportDetails(
      context,
      username: user,
      incident: emergencyTypes[selectedEmergency],
      phone: phone,
      location:
          addressController.text.isNotEmpty
              ? addressController.text
              : 'Unknown location',
      latlng: _currentPos,
      address: address,
      userId: userId,
    );

    if (!context.mounted) return;

    if (result == 'success_volunteer') {
      await volunteersDialog(context);
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (result == 'success') {
      await customDialog(
        context,
        title: 'Success',
        content: 'SOS Report sent Successfully',
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
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
      final suggestions = (data['suggestions'] as List? ?? []);

      final tondoOnlyResults =
          suggestions.where((suggestion) {
            final description =
                suggestion['placePrediction']['text']['text']
                    .toString()
                    .toLowerCase();

            // Check if the description contains "tondo"
            return description.contains('tondo');
          }).toList();

      return tondoOnlyResults
          .map(
            (e) => {
              "description": e['placePrediction']['text']['text'],
              "placeId": e['placePrediction']['placeId'],
            },
          )
          .toList();

      // return (data['suggestions'] as List)
      //     .map(
      //       (e) => {
      //         "description": e['placePrediction']['text']['text'],
      //         "placeId": e['placePrediction']['placeId'],
      //       },
      //     )
      //     .toList();
    } else {
      print("Autocomplete error: ${response.body}");
      return [];
    }
  }

  Future<void> updateSearchFieldFromLatLng(LatLng pos) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];
      if (results.isNotEmpty) {
        setState(() {
          addressController.text = results[0]['formatted_address'];
        });
      }
    } else {
      print('Reverse geocode failed: ${response.body}');
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
