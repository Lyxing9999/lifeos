import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/widgets/app_form_section.dart';
import '../../../../core/widgets/app_form_widget.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/enum/place_type.dart';
import '../../domain/model/place.dart';
import '../widgets/place_map_preview.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlaceFormPage — Senior-level form using AppFormMixin
//
// Principles applied:
//   1. Form key + inline validation via AppTextFormField
//   2. Chip pickers for type / radius presets (zero typing)
//   3. Map + location picker with progressive disclosure
//   4. Cross-field validation (pin required) via showFormError
//   5. Safe async submit via AppFormMixin.submitForm
//   6. All SnackBars use themed showFormError
//   7. Accessibility: all buttons have Semantics, min 48dp targets
// ─────────────────────────────────────────────────────────────────────────────

class PlaceFormPage extends StatefulWidget {
  final Place? existing;
  final Future<void> Function(PlaceFormResult result) onSubmit;
  final bool isSaving;

  const PlaceFormPage({
    super.key,
    this.existing,
    required this.onSubmit,
    required this.isSaving,
  });

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> with AppFormMixin {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  late PlaceType _type;
  bool _active = true;
  double _radius = 50;

  // Null means no pin set yet
  LatLng? _pinLocation;
  bool _locating = false;
  bool _showMapPicker = false;
  bool _showRadiusSlider = false;
  bool _showMoreOptions = false;

  bool get _isEdit => widget.existing != null;
  bool get _hasPin => _pinLocation != null;

  static const _radiusPresets = [50.0, 100.0, 200.0, 500.0];

  bool _isPresetRadius(double value) {
    return _radiusPresets.any((preset) => (preset - value).abs() < 0.5);
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final item = widget.existing!;
      _nameController.text = item.name;
      _pinLocation = LatLng(item.latitude, item.longitude);
      _radius = item.matchRadiusMeters.clamp(10, 1000);
      _type = item.placeType;
      _active = item.active;
    } else {
      _type = PlaceType.home;
      _radius = 50;
    }
    _showRadiusSlider = !_isPresetRadius(_radius);
    _showMoreOptions = !_active;
    // Smart default: auto-show map for new places since location is required.
    // Saves the user one tap. For edit, map stays hidden (pin is already set).
    _showMapPicker = !_isEdit;

    Future.microtask(() => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) showFormError('Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      HapticFeedback.mediumImpact();
      setState(() => _pinLocation = LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      if (mounted) showFormError('Could not get location');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Cross-field: pin is required
    if (_pinLocation == null) {
      showFormError('Choose on map or use your current location');
      setState(() => _showMapPicker = true);
      return;
    }

    await widget.onSubmit(
      PlaceFormResult(
        name: _nameController.text.trim(),
        placeType: _type,
        latitude: _pinLocation!.latitude,
        longitude: _pinLocation!.longitude,
        matchRadiusMeters: _radius,
        active: _active,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return buildFormPage(
      title: _isEdit ? 'Edit Place' : 'New Place',
      subtitle: _isEdit
          ? 'Update your saved place'
          : 'Save a place for better life context',
      submitLabel: 'Create Place',
      isSaving: widget.isSaving,
      isEdit: _isEdit,
      onSubmit: _submit,
      shouldPopOnSubmit: true,
      children: [
        // ── Name ────────────────────────────────────────────────────────
        AppFormSection(
          title: 'Name',
          child: AppTextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            hintText: 'Home, Office, Gym...',
            prefixIcon: Icons.place_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            validator: FormValidators.requiredField('Name'),
          ),
        ),

        // ── Type ────────────────────────────────────────────────────────
        AppFormSection(
          title: 'Type',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: PlaceType.values.map((type) {
              final selected = _type == type;
              return AppChip.filter(
                label: type.label,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _type = type);
                },
              );
            }).toList(),
          ),
        ),

        // ── Pick location ───────────────────────────────────────────────
        AppFormSection(
          title: 'Location',
          subtitle: _hasPin
              ? 'Pin selected. You can adjust it anytime.'
              : 'Choose on map or use your current location',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showMapPicker = !_showMapPicker);
                    },
                    icon: Icon(
                      _showMapPicker
                          ? Icons.expand_less_rounded
                          : Icons.map_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _showMapPicker ? 'Hide map' : 'Choose on map',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _locating ? null : _useMyLocation,
                    icon: _locating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      _locating ? 'Getting location...' : 'Use my location',
                    ),
                  ),
                ],
              ),
              if (_hasPin) ...[
                const SizedBox(height: AppSpacing.xs),
                PlaceMapCaption(
                  latitude: _pinLocation!.latitude,
                  longitude: _pinLocation!.longitude,
                  radius: _radius,
                ),
              ],
              if (_showMapPicker) ...[
                const SizedBox(height: AppSpacing.sm),
                _InteractiveMap(
                  pinLocation: _pinLocation,
                  radius: _radius,
                  height: 188,
                  onTap: (latLng) {
                    HapticFeedback.selectionClick();
                    setState(() => _pinLocation = latLng);
                  },
                ),
              ],
            ],
          ),
        ),

        // ── Radius ──────────────────────────────────────────────────────
        AppFormSection(
          title: 'Radius',
          subtitle: 'How close you need to be to trigger this place',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _radiusPresets.map((preset) {
                  final selected = _radius == preset;
                  return AppChip.filter(
                    label: '${preset.toInt()} m',
                    selected: selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _radius = preset;
                        _showRadiusSlider = false;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${_radius.toInt()} m',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(
                          () => _showRadiusSlider = !_showRadiusSlider);
                    },
                    icon: Icon(
                      _showRadiusSlider
                          ? Icons.expand_less_rounded
                          : Icons.tune_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _showRadiusSlider ? 'Hide fine tune' : 'Fine tune',
                    ),
                  ),
                ],
              ),
              if (_showRadiusSlider)
                Row(
                  children: [
                    Text('10 m',
                        style: AppTextStyles.statLabel(context)),
                    Expanded(
                      child: Slider(
                        value: _radius.clamp(10, 1000),
                        min: 10,
                        max: 1000,
                        divisions: 99,
                        label: '${_radius.toInt()} m',
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _radius = v);
                        },
                      ),
                    ),
                    Text('1 km',
                        style: AppTextStyles.statLabel(context)),
                  ],
                ),
            ],
          ),
        ),

        // ── More options ────────────────────────────────────────────────
        AppFormSection(
          title: 'Options',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoreOptionsTile(
                icon: _showMoreOptions
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                label: 'Place status',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(
                      () => _showMoreOptions = !_showMoreOptions);
                },
              ),
              if (_showMoreOptions) ...[
                const SizedBox(height: AppSpacing.sm),
                _SwitchTile(
                  title: 'Active place',
                  subtitle:
                      'Inactive places are kept but ignored for matching',
                  value: _active,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _active = v);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreOptionsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label)),
              Icon(icon,
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InteractiveMap — Google Maps with pin + radius circle
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveMap extends StatefulWidget {
  final LatLng? pinLocation;
  final double radius;
  final double height;
  final void Function(LatLng) onTap;

  const _InteractiveMap({
    required this.pinLocation,
    required this.radius,
    this.height = 240,
    required this.onTap,
  });

  @override
  State<_InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<_InteractiveMap> {
  GoogleMapController? _controller;

  // Default camera — world view until pin is set
  static const _defaultCamera = CameraPosition(
    target: LatLng(13.3671, 103.8448), // Siem Reap as sensible default
    zoom: 5,
  );

  double get _zoom {
    final r = widget.radius;
    if (r <= 50) return 17.5;
    if (r <= 100) return 17.0;
    if (r <= 200) return 16.0;
    if (r <= 500) return 15.0;
    return 14.0;
  }

  @override
  void didUpdateWidget(_InteractiveMap old) {
    super.didUpdateWidget(old);
    final pin = widget.pinLocation;
    if (pin != null &&
        (old.pinLocation != pin || old.radius != widget.radius)) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pin, zoom: _zoom),
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
    final primary = Theme.of(context).colorScheme.primary;
    final pin = widget.pinLocation;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: pin != null
                  ? CameraPosition(target: pin, zoom: _zoom)
                  : _defaultCamera,
              onMapCreated: (c) => _controller = c,
              onTap: widget.onTap,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              markers: pin != null
                  ? {
                      Marker(
                        markerId: const MarkerId('place'),
                        position: pin,
                        draggable: true,
                        onDragEnd: widget.onTap,
                      ),
                    }
                  : {},
              circles: pin != null
                  ? {
                      Circle(
                        circleId: const CircleId('radius'),
                        center: pin,
                        radius: widget.radius,
                        fillColor: primary.withValues(alpha: 0.15),
                        strokeColor: primary.withValues(alpha: 0.60),
                        strokeWidth: 2,
                      ),
                    }
                  : {},
            ),
            // Overlay hint when no pin yet
            if (pin == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final cs = Theme.of(context).colorScheme;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: cs.inverseSurface
                                .withValues(alpha: 0.75),
                            borderRadius:
                                BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: cs.onInverseSurface,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Tap to place pin',
                                style: TextStyle(
                                  color: cs.onInverseSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SwitchTile — Accessible toggle tile
// ─────────────────────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.cardTitle(context)),
                    Text(subtitle,
                        style: AppTextStyles.bodySecondary(context)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PlaceFormResult (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class PlaceFormResult {
  final String name;
  final PlaceType placeType;
  final double latitude;
  final double longitude;
  final double matchRadiusMeters;
  final bool active;

  const PlaceFormResult({
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.matchRadiusMeters,
    required this.active,
  });
}
