// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/status_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:scaler/scaler.dart';

class RouteInfo {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final int durationInSeconds;

  RouteInfo({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.durationInSeconds,
  });
}

class StatusScreen extends StatefulWidget {
  final String docId;

  const StatusScreen({super.key, required this.docId});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _dialogShown = false;
  bool _completedDialogShown = false;
  bool _resolvedDialogShown = false;

  Map<PolylineId, Polyline> polylines = {};
  LatLng? responderPosition;
  LatLng? incidentLoc;
  String? estimatedTime;

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  Future<RouteInfo?> getDirectionsWithETA({
    required String apiKey,
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=$mode'
        '&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Extract duration and distance
          final duration = leg['duration']['text'];
          final durationInSeconds = leg['duration']['value'];
          final distance = leg['distance']['text'];

          // Extract polyline points
          final polylineString = route['overview_polyline']['points'];
          final polylinePoints = _decodePolyline(polylineString);

          return RouteInfo(
            polylinePoints: polylinePoints,
            distance: distance,
            duration: duration,
            durationInSeconds: durationInSeconds,
          );
        } else {
          print('Directions API error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error message: ${data['error_message']}');
          }
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching directions: $e');
      return null;
    }
  }

  Future<void> generatePolyLineFromPoints(
    List<LatLng> polylineCoordinates,
  ) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 6,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  // Future<List<LatLng>> fetchPolylinePoints({
  //   required String apiKey,
  //   required LatLng origin,
  //   required LatLng destination,
  // }) async {
  //   final polylinePoints = PolylinePoints();

  //   print("Fetching polyline from $origin to $destination");
  //   print(
  //     "Using API key: ${apiKey.isNotEmpty ? 'API key provided' : 'API key is empty!'}",
  //   );

  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleApiKey: apiKey,
  //     request: PolylineRequest(
  //       origin: PointLatLng(origin.latitude, origin.longitude),
  //       destination: PointLatLng(destination.latitude, destination.longitude),
  //       mode: TravelMode.walking,
  //     ),
  //   );

  //   if (result.points.isNotEmpty) {
  //     return result.points
  //         .map((point) => LatLng(point.latitude, point.longitude))
  //         .toList();
  //   } else {
  //     debugPrint(result.errorMessage);
  //     return [];
  //   }
  // }

  Future<void> initializePolylines() async {
    if (responderPosition == null || incidentLoc == null) {
      print("Cannot initialize polylines: missing positions");
      return;
    }

    try {
      final routeInfo = await getDirectionsWithETA(
        apiKey: apiKey,
        origin: responderPosition!,
        destination: incidentLoc!,
        mode: 'walking', // Use driving mode for emergency responders
      );

      if (routeInfo != null) {
        // Update polylines
        generatePolyLineFromPoints(routeInfo.polylinePoints);

        // Calculate arrival time
        final arrivalTime = DateTime.now().add(
          Duration(seconds: routeInfo.durationInSeconds),
        );

        // Update ETA information
        setState(() {
          estimatedTime = routeInfo.duration;
        });

        print("ETA: ${routeInfo.duration}");
        print("Distance: ${routeInfo.distance}");
        print("Estimated arrival: ${arrivalTime.toString()}");
      }

      // final coordinates = await fetchPolylinePoints(
      //   apiKey: apiKey,
      //   origin: userPosition!,
      //   destination: position!,
      // );

      // if (coordinates.isNotEmpty) {
      //   generatePolyLineFromPoints(coordinates);
      // } else {
      //   print("No polyline coordinates received");
      // }
    } catch (e) {
      print("Error initializing polylines: $e");
    }
  }

  // Future<void> initializePolylines() async {
  //   if (responderPosition == null || incidentLoc == null) {
  //     print("Cannot initialize polylines: missing positions");
  //     return;
  //   }

  //   try {
  //     final coordinates = await fetchPolylinePoints(
  //       apiKey: apiKey,
  //       origin: responderPosition!,
  //       destination: incidentLoc!,
  //     );

  //     if (coordinates.isNotEmpty) {
  //       generatePolyLineFromPoints(coordinates);
  //     } else {
  //       print("No polyline coordinates received");
  //     }
  //   } catch (e) {
  //     print("Error initializing polylines: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status', style: GoogleFonts.poppins(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body:
          currentUser == null
              ? Center(child: Text("Not signed in"))
              : StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('sos_reports')
                        .doc(widget.docId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final report = snapshot.data!;

                  if (!report.exists) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final reportData = report.data() as Map<String, dynamic>;
                  final status = (reportData['status'] ?? 'Pending')
                      .toString()
                      .split(' ')
                      .map(
                        (word) =>
                            word.isNotEmpty
                                ? word[0].toUpperCase() +
                                    word.substring(1).toLowerCase()
                                : '',
                      )
                      .join(' ');
                  final incident = reportData['incidentType'] ?? 'Unknown';
                  final docId = report.id;
                  final bool isVolunteer = reportData['volunteer'];
                  final volunteer = isVolunteer == true ? 'Yes' : 'No';
                  final username = reportData['user'] ?? 'Unknown';
                  final location = reportData['location'] ?? 'Unknown';
                  final message = reportData['message'];
                  final responderPhone = reportData['responderPhone'];
                  final GeoPoint? responderlatlng =
                      reportData['responderPos'] as GeoPoint?;
                  responderPosition =
                      responderlatlng != null
                          ? LatLng(
                            responderlatlng.latitude,
                            responderlatlng.longitude,
                          )
                          : null;
                  final GeoPoint? incidentlatlng =
                      reportData['latlng'] as GeoPoint?;
                  incidentLoc =
                      incidentlatlng != null
                          ? LatLng(
                            incidentlatlng.latitude,
                            incidentlatlng.longitude,
                          )
                          : null;

                  if (responderPosition != null &&
                      incidentLoc != null &&
                      polylines.isEmpty) {
                    initializePolylines();
                  }
                  

                  if (status.toLowerCase() == 'resolved' &&
                      !_resolvedDialogShown) {
                    _resolvedDialogShown = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await redirectDialog(
                        context,
                        title: 'Emergency Resolved',
                        content:
                            'Thank you for your quick response. The situation has been resolved.',
                      );
                      if (mounted) setState(() => _resolvedDialogShown = false);
                    });
                  }

                  if (status.toLowerCase() == 'canceled' && !_dialogShown) {
                    _dialogShown = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await redirectDialog(
                        context,
                        title: 'Canceled',
                        content: 'Your report has been canceled.',
                      );
                      if (mounted) setState(() => _dialogShown = false);
                    });
                  }

                  if (status.toLowerCase() == 'completed' &&
                      !_completedDialogShown) {
                    _completedDialogShown = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await ratingsDialog(context, docId);
                      // if (mounted) setState(() => _completedDialogShown = false);
                    });
                  }

                  return Column(
                    children: [
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27.0),
                        child: Text(
                          switch (status) {
                            'Validated' => 'Admin has validated your report.',
                            'Ongoing' => 'Your report has been accepted.',
                            'On The Way' =>
                              isVolunteer
                                  ? 'Responders are on their way. Be ready to help.'
                                  : 'Responders are on the way! Track their live location below.',
                            'Arrived' =>
                              isVolunteer
                                  ? 'Responders has arrived. Stick together and follow instructions.'
                                  : 'Responders has arrived to the location.',
                            'Completed' =>
                              isVolunteer
                                  ? 'Incident has been completed. Well done, volunteer.'
                                  : 'Incident has been completed. Thank you for your participation. ',

                            _ =>
                              'Your report has been submitted. Hang on tight.',
                          },
                          style: GoogleFonts.poppins(
                            color: black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.clip,
                        ),
                      ),

                      Transform.scale(
                        scale: 0.95,
                        child: ReportStatusProgress(docId: docId),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child:
                            status.toLowerCase() == 'ongoing' ||
                                    status.toLowerCase() == 'on the way' ||
                                    status.toLowerCase() == 'arrived' ||
                                    status.toLowerCase() == 'completed' ||
                                    status.toLowerCase() == 'resolved'
                                ? SizedBox(
                                  height: Scaler.height(0.26, context),
                                  child:
                                      (responderPosition != null &&
                                              incidentLoc != null)
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                    target:
                                                        responderPosition ??
                                                        LatLng(0, 0),
                                                    zoom: 12.0,
                                                  ),
                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId(
                                                    'responderLoc',
                                                  ),
                                                  icon:
                                                      BitmapDescriptor
                                                          .defaultMarker,
                                                  position: responderPosition!,
                                                  infoWindow: InfoWindow(
                                                    title: 'Responder',
                                                  ),
                                                ),
                                                Marker(
                                                  markerId: const MarkerId(
                                                    'emergencyLocation',
                                                  ),
                                                  icon:
                                                      BitmapDescriptor
                                                          .defaultMarker,
                                                  position: incidentLoc!,
                                                  infoWindow: InfoWindow(
                                                    title: 'Incident',
                                                  ),
                                                ),
                                                Marker(
                                                  markerId: const MarkerId(
                                                    'userLoc',
                                                  ),
                                                  icon:
                                                      BitmapDescriptor.defaultMarker,
                                                ),
                                              },
                                              polylines: Set<Polyline>.of(
                                                polylines.values,
                                              ),
                                            ),
                                          )
                                          : Center(
                                            child: Text("Loading map..."),
                                          ),
                                )
                                : null,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child:
                                    status.toLowerCase() == 'on the way' ||
                                    status.toLowerCase() == 'arrived' ||
                                    status.toLowerCase() == 'completed' ||
                                    status.toLowerCase() == 'resolved'
                                ? RichText(
                                  text: TextSpan(
                                    text: 'Estimated Time of Arrival: ',
                                    style: GoogleFonts.poppins(
                                      color: black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: estimatedTime,
                                        style: GoogleFonts.poppins(
                                          color: black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : null,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: Scaler.width(0.85, context),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText('Username: ', username),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText(
                                  'Incident Type: ',
                                  incident,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText('Message: ', message),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText('Location: ', location),
                              ),
                              if (responderPhone != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: buildRichText(
                                    'Responder Phone: ',
                                    responderPhone,
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText('Status: ', status),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: buildRichText('Volunteer?: ', volunteer),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Widget buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.poppins(
          color: black,
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.poppins(
              color: black,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
