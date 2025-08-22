import 'dart:async';
import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final Function(LatLng) onLocationPicked;
  final LatLng initialPosition;
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
  LatLng _currentCenter = const LatLng(14.6105, 120.9630);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition;
  }

  @override
  void didUpdateWidget(Maps oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if initial position changes from parent
    if (widget.initialPosition != oldWidget.initialPosition) {
      _moveToLocation(widget.initialPosition);
    }
  }

  Future<void> _moveToLocation(LatLng position) async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17.0));
      setState(() {
        _currentCenter = position;
      });
      widget.onLocationPicked(position);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentCenter,
            zoom: 17.0,
          ),
          onMapCreated: (controller) => _controller.complete(controller),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onCameraMove: (position) {
            _currentCenter = position.target;
          },
          onCameraIdle: () {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () async {
              widget.onLocationPicked(_currentCenter);

              // Call the callback only if it exists
              if (widget.onCameraIdleUpdate != null) {
                await widget.onCameraIdleUpdate!(_currentCenter);
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
