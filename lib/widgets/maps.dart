import 'dart:async';
import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final Function(LatLng) onLocationPicked;
  final LatLng? initialPosition;
  final Future<void> Function(LatLng)? onCameraIdleUpdate;
  const Maps({
    super.key,
    required this.onLocationPicked,
    required this.initialPosition,
    this.onCameraIdleUpdate,
  });

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentCenter;
  StreamSubscription<Position>? _positionStream;
  Timer? _debounce;
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    _startTrackingUserLocation();
  }

  @override
  void didUpdateWidget(Maps oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if initial position changes from parent
    if (widget.initialPosition != oldWidget.initialPosition) {
      if (widget.initialPosition != null) {
        _moveToLocation(widget.initialPosition!);
      }
    }
  }

  Future<void> _startTrackingUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Get first location immediately
      final position = await Geolocator.getCurrentPosition();
      final firstLatLng = LatLng(position.latitude, position.longitude);
      setState(() => _currentCenter = firstLatLng); // 👈 initialize here
      _moveToLocation(firstLatLng);

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // move at least 5 meters before update
        ),
      ).listen((Position position) {
        if (_followUser) {
          final userLatLng = LatLng(position.latitude, position.longitude);
          _moveToLocation(userLatLng);
        }
      });
    } catch (e) {
      debugPrint("Error tracking user location: $e");
    }
  }

  Future<void> _moveToLocation(LatLng position) async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      final zoomLevel = await controller.getZoomLevel();
      controller.animateCamera(CameraUpdate.newLatLngZoom(position, zoomLevel));
    }
    setState(() {
      _currentCenter = position;
    });
    widget.onLocationPicked(position);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentCenter == null) {
      // ⏳ Show loader until location is ready
      return const Center(child: CircularProgressIndicator(color: Primary));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentCenter!,
            zoom: 17.0,
          ),
          onMapCreated: (controller) => _controller.complete(controller),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onCameraMove: (position) {
            _currentCenter = position.target;
            _followUser = false; // Stop following user on manual move
          },
          onCameraIdle: () {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () async {
              widget.onLocationPicked(_currentCenter!);
              // Call the callback only if it exists
              if (widget.onCameraIdleUpdate != null) {
                await widget.onCameraIdleUpdate!(_currentCenter!);
              }
            });
          },
        ),
        const IgnorePointer(
          child: Icon(Icons.location_pin, size: 40.0, color: Primary),
        ),
      ],
    );
  }
}
