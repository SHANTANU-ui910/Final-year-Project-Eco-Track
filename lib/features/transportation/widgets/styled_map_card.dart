import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_point.dart';
import '../theme/design_tokens.dart';

/// 260dp bespoke styled map card with custom mint/slate palette, polyline glow, and shimmer skeleton
class StyledMapCard extends StatefulWidget {
  final List<LocationPoint> points;
  final bool isTracking;
  final bool isGpsLocked;
  final VoidCallback? onRecenter;
  final bool isDark;
  final double height;

  const StyledMapCard({
    super.key,
    required this.points,
    this.isTracking = true,
    this.isGpsLocked = true,
    this.onRecenter,
    this.isDark = false,
    this.height = 180.0,
  });

  @override
  State<StyledMapCard> createState() => _StyledMapCardState();
}

class _StyledMapCardState extends State<StyledMapCard> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  late final AnimationController _shimmerController;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090), // Default Capital Hub
    zoom: 16.0,
  );

  // Custom Mint-Slate Google Map Style JSON (Clean, minimal POIs, soft mint land, white roads)
  static const String _mintMapStyle = '''
  [
    {"featureType": "all", "elementType": "labels.text.fill", "stylers": [{"color": "#5D7A6E"}]},
    {"featureType": "all", "elementType": "labels.text.stroke", "stylers": [{"color": "#EEF8F2"}, {"weight": 2}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"visibility": "off"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#F3FAF6"}]},
    {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#E4F3EC"}]},
    {"featureType": "poi", "elementType": "labels", "stylers": [{"visibility": "simplified"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#FFFFFF"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#DCECE1"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#D1ECE0"}]}
  ]
  ''';

  static const String _darkMapStyle = '''
  [
    {"featureType": "all", "elementType": "geometry", "stylers": [{"color": "#0C2019"}]},
    {"featureType": "all", "elementType": "labels.text.fill", "stylers": [{"color": "#94A3B8"}]},
    {"featureType": "all", "elementType": "labels.text.stroke", "stylers": [{"color": "#06120E"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#16382C"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#08281E"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant StyledMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points.isNotEmpty && _controller != null) {
      final latest = widget.points.last;
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(latest.latitude, latest.longitude)),
      );
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPoints = widget.points.isNotEmpty;

    final polylineCoords = widget.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final Set<Polyline> polylines = {
      if (polylineCoords.length > 1)
        Polyline(
          polylineId: const PolylineId('eco_route'),
          points: polylineCoords,
          color: EcoDesignTokens.primary,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
    };

    final Set<Marker> markers = {
      if (hasPoints) ...[
        Marker(
          markerId: const MarkerId('start_node'),
          position: LatLng(widget.points.first.latitude, widget.points.first.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId('current_node'),
          position: LatLng(widget.points.last.latitude, widget.points.last.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      ],
    };

    final initialTarget = hasPoints
        ? LatLng(widget.points.last.latitude, widget.points.last.longitude)
        : _defaultPosition.target;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusCard),
        border: Border.all(
          color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
          width: 1.0,
        ),
        boxShadow: EcoDesignTokens.cardElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusCard),
        child: Stack(
          children: [
            // Underlying Native GoogleMap Platform View
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
                _controller = controller;
                controller.setMapStyle(widget.isDark ? _darkMapStyle : _mintMapStyle);
              },
            ),

            // Shimmer Overlay while Locking GPS (No points)
            if (!hasPoints)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    final progress = _shimmerController.value;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + (progress * 2), -0.5),
                          end: Alignment(1.0 + (progress * 2), 0.5),
                          colors: [
                            Colors.white.withValues(alpha: 0.6),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Floating Top-Left GPS Status Pill (Uses solid/semi-opaque surface, NOT BackdropFilter!)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(EcoDesignTokens.radiusPill),
                  border: Border.all(color: const Color(0xFFD4E6DC), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPoints ? EcoDesignTokens.bright : const Color(0xFFEAB308),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasPoints ? 'GPS Real-Time Lock' : 'Locking Satellite Feed...',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: hasPoints ? EcoDesignTokens.deepEmerald : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Recenter Button (Lower Right)
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'styled_map_recenter_fab',
                backgroundColor: Colors.white,
                foregroundColor: EcoDesignTokens.deepEmerald,
                elevation: 2,
                onPressed: () {
                  if (hasPoints) {
                    _controller?.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(widget.points.last.latitude, widget.points.last.longitude),
                      ),
                    );
                  }
                  widget.onRecenter?.call();
                },
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

