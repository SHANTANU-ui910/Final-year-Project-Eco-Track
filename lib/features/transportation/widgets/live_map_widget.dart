import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../models/location_point.dart';

class LiveMapWidget extends StatefulWidget {
  final List<LocationPoint> points;
  final bool isTracking;

  const LiveMapWidget({
    super.key,
    required this.points,
    this.isTracking = true,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  GoogleMapController? _mapController;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco fallback
    zoom: 16.0,
  );

  @override
  void didUpdateWidget(covariant LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points.isNotEmpty && _mapController != null) {
      final latest = widget.points.last;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(latest.latitude, latest.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final polylineCoordinates = widget.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final Set<Polyline> polylines = {
      if (polylineCoordinates.length > 1)
        Polyline(
          polylineId: const PolylineId('active_trip_route'),
          points: polylineCoordinates,
          color: AppColors.forestGreen,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
    };

    final Set<Marker> markers = {};
    if (widget.points.isNotEmpty) {
      // Start marker
      markers.add(
        Marker(
          markerId: const MarkerId('start_pt'),
          position: LatLng(
            widget.points.first.latitude,
            widget.points.first.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Current location marker
      markers.add(
        Marker(
          markerId: const MarkerId('current_pt'),
          position: LatLng(
            widget.points.last.latitude,
            widget.points.last.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    final initialTarget = widget.points.isNotEmpty
        ? LatLng(widget.points.last.latitude, widget.points.last.longitude)
        : _defaultPosition.target;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 16.0,
            ),
            polylines: polylines,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'recenter_map_btn',
              backgroundColor: AppColors.pureWhite,
              foregroundColor: AppColors.charcoal,
              elevation: 2,
              onPressed: () {
                if (widget.points.isNotEmpty) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        widget.points.last.latitude,
                        widget.points.last.longitude,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

