import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

/// Live Google Map preview with a filled circle showing the detection radius.
/// Used in both the form (interactive) and detail page (read-only).
class PlaceMapPreview extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double radius;

  /// When true the map is non-interactive (detail page).
  /// When false the map is scrollable/zoomable but pin is fixed.
  final bool readOnly;

  const PlaceMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.readOnly = true,
  });

  @override
  State<PlaceMapPreview> createState() => _PlaceMapPreviewState();
}

class _PlaceMapPreviewState extends State<PlaceMapPreview> {
  GoogleMapController? _controller;

  LatLng get _center => LatLng(widget.latitude, widget.longitude);

  // Zoom level that fits the radius circle comfortably on screen.
  double get _zoom {
    // Rough heuristic: radius in metres → zoom level
    final r = widget.radius;
    if (r <= 50) return 17.5;
    if (r <= 100) return 17.0;
    if (r <= 200) return 16.0;
    if (r <= 500) return 15.0;
    return 14.0;
  }

  @override
  void didUpdateWidget(PlaceMapPreview old) {
    super.didUpdateWidget(old);
    if (old.latitude != widget.latitude ||
        old.longitude != widget.longitude ||
        old.radius != widget.radius) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _center, zoom: _zoom),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 220,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: _zoom,
          ),
          onMapCreated: (c) => _controller = c,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: !widget.readOnly,
          zoomGesturesEnabled: !widget.readOnly,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          mapType: MapType.normal,
          mapToolbarEnabled: false,
          compassEnabled: false,
          markers: {
            Marker(
              markerId: const MarkerId('place'),
              position: _center,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isDark
                    ? BitmapDescriptor.hueAzure
                    : BitmapDescriptor.hueRed,
              ),
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('radius'),
              center: _center,
              radius: widget.radius,
              fillColor: primary.withValues(alpha: 0.15),
              strokeColor: primary.withValues(alpha: 0.60),
              strokeWidth: 2,
            ),
          },
        ),
      ),
    );
  }
}

/// Compact coordinate + radius label shown below the map.
class PlaceMapCaption extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double radius;

  const PlaceMapCaption({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${radius.toInt()} m',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
