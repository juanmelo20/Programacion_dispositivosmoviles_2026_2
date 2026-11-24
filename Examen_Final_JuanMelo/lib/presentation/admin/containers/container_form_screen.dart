import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_detail_model.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/form_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/page_helpers.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Crear o editar un contenedor
class ContainerFormScreen extends ConsumerWidget {
  const ContainerFormScreen({super.key, this.containerId});

  final int? containerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final id = containerId;

    return Scaffold(
      appBar: AppBar(
        leading: pageBackButton(context, AppRoutes.containers),
        title: Text(id == null ? t.titleNewContainer : t.titleEditContainer),
      ),
      body: id == null
          ? const _ContainerForm()
          : AsyncView<ContainerDetailModel>(
              value: ref.watch(containerDetailProvider(id)),
              onRetry: () => ref.invalidate(containerDetailProvider(id)),
              skeleton: _ContainerForm(
                initial: ContainerModel.placeholder(),
                skeleton: true,
              ),
              builder: (detail) => _ContainerForm(initial: detail.container),
            ),
    );
  }
}

class _ContainerForm extends ConsumerStatefulWidget {
  const _ContainerForm({this.initial, this.skeleton = false});

  /// null = contenedor nuevo.
  final ContainerModel? initial;
  final bool skeleton;

  @override
  ConsumerState<_ContainerForm> createState() => _ContainerFormState();
}

class _ContainerFormState extends ConsumerState<_ContainerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _capacity;
  late final TextEditingController _threshold;
  String? _category;
  int? _locationId;
  bool _active = true;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name ?? '');
    _code = TextEditingController(text: c?.code ?? '');
    _capacity = TextEditingController(
      text: c == null ? '' : '${c.capacityUnits}',
    );
    // Si usa el umbral global, el campo queda vacío.
    _threshold = TextEditingController(
      text: c == null || c.usesGlobalThreshold
          ? ''
          : _formatThreshold(c.fillThreshold),
    );
    _category = c?.category;
    _locationId = c?.locationId;
    _active = c?.isActive ?? true;
  }

  static String _formatThreshold(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _capacity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final missing =
        _name.text.trim().isEmpty ||
        _category == null ||
        _locationId == null ||
        (_isEdit && _capacity.text.trim().isEmpty);
    if (!validateForm(context, _formKey, missingRequired: missing)) return;

    setState(() => _saving = true);
    try {
      final service = ref.read(containerServiceProvider);
      final code = _code.text.trim();
      final capacity = int.tryParse(_capacity.text.trim());
      final threshold = Validators.parseDecimal(_threshold.text);
      final initial = widget.initial;

      if (initial == null) {
        await service.create(
          name: _name.text.trim(),
          category: _category!,
          locationId: _locationId!,
          code: code,
          capacityUnits: capacity,
          fillThreshold: threshold,
        );
      } else {
        await service.update(initial.id, {
          'name': _name.text.trim(),
          'category': _category,
          'location_id': _locationId,
          'capacity_units': ?capacity,
          if (code.isNotEmpty) 'code': code,
          // Campo vacío = volver al umbral global del sistema.
          if (threshold == null)
            'use_global_threshold': true
          else
            'fill_threshold': threshold,
          'is_active': _active,
        });
      }

      if (!mounted) return;
      refreshOperationalData(ref.invalidate);
      closePage(context, fallback: AppRoutes.containers, result: true);
    } catch (error) {
      if (mounted) AppAlerts.error(context, t.actionErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        physics: widget.skeleton ? const NeverScrollableScrollPhysics() : null,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: t.fieldName,
              prefixIcon: const Icon(Icons.label_outline_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return t.fieldRequired;
              return Validators.isValidName(text) ? null : t.invalidName;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t.fieldCode,
              helperText: _isEdit ? null : t.fieldCodeHint,
              prefixIcon: const Icon(Icons.qr_code_2_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              return Validators.code.hasMatch(text) ? null : t.invalidCode;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: t.fieldCategory,
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            hint: Text(t.selectOption),
            items: [
              for (final category in WasteCategory.all)
                DropdownMenuItem(
                  value: category,
                  child: Text(t.categoryName(category)),
                ),
            ],
            onChanged: (value) => setState(() => _category = value),
            validator: (value) => value == null ? t.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _EcoPointField(
            selectedId: _locationId,
            onChanged: (value) => setState(() => _locationId = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _capacity,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t.fieldCapacity,
              helperText: _isEdit ? null : t.fieldCapacityHint,
              prefixIcon: const Icon(Icons.inventory_2_outlined),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return _isEdit ? t.fieldRequired : null;
              return Validators.isValidCapacity(text)
                  ? null
                  : t.invalidCapacity;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _threshold,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.fieldThreshold,
              helperText: t.fieldThresholdHint,
              prefixIcon: const Icon(Icons.notifications_active_outlined),
              suffixText: '%',
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              return Validators.isValidThreshold(text)
                  ? null
                  : t.invalidThreshold;
            },
          ),
          if (_isEdit) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.fieldActive),
              subtitle: _active ? null : Text(t.retireMessage),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
          const SizedBox(height: 24),
          SaveButton(
            saving: _saving,
            onPressed: _save,
            label: _isEdit ? t.save : t.create,
          ),
        ],
      ),
    );
  }
}

/// Lista desplegable de puntos ecológicos (se consulta a la API).
class _EcoPointField extends ConsumerWidget {
  const _EcoPointField({required this.selectedId, required this.onChanged});

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(locationsProvider(true));

    Widget field(List<LocationModel> points, {bool enabled = true}) {
      // Se ofrecen los puntos activos; uno inactivo solo si ya era el suyo.
      // Los creados o eliminados sin conexión no: aún no existen en la API o
      // están por eliminarse.
      final options = points
          .where((p) => (p.isAvailable && p.isActive) || p.id == selectedId)
          .toList();
      final hasSelected = options.any((p) => p.id == selectedId);
      return DropdownButtonFormField<int>(
        initialValue: hasSelected ? selectedId : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: t.fieldEcoPoint,
          prefixIcon: const Icon(Icons.place_outlined),
        ),
        hint: Text(t.selectOption),
        items: [
          for (final point in options)
            DropdownMenuItem(
              value: point.id,
              child: Text(
                point.isActive
                    ? point.displayName
                    : '${point.displayName} (${t.inactiveBadge})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: enabled ? onChanged : null,
        validator: (value) => value == null ? t.fieldRequired : null,
      );
    }

    return AsyncView<List<LocationModel>>(
      value: value,
      fill: false,
      onRetry: () => ref.invalidate(locationsProvider(true)),
      skeleton: field([LocationModel.placeholder()], enabled: false),
      builder: field,
    );
  }
}
