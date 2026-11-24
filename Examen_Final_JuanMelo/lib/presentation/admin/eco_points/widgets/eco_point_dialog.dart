import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/handler/ecopunto_handler.dart';
import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/form_helpers.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/services/offline/eco_points_offline_service.dart';

/// Crear o editar un punto ecológico. Devuelve cómo quedó guardado
/// (en la API o en el celular, si no hay conexión), o null si se canceló.
Future<SaveResult?> showEcoPointDialog(
  BuildContext context, {
  LocationModel? point,
}) {
  return showDialog<SaveResult>(
    context: context,
    builder: (context) => _EcoPointDialog(point: point),
  );
}

class _EcoPointDialog extends ConsumerStatefulWidget {
  const _EcoPointDialog({this.point});

  final LocationModel? point;

  @override
  ConsumerState<_EcoPointDialog> createState() => _EcoPointDialogState();
}

class _EcoPointDialogState extends ConsumerState<_EcoPointDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _zone;
  late final TextEditingController _description;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.point?.name ?? '');
    _zone = TextEditingController(text: widget.point?.buildingZone ?? '');
    _description = TextEditingController(text: widget.point?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _zone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    if (!validateForm(
      context,
      _formKey,
      missingRequired: _name.text.trim().isEmpty,
    )) {
      return;
    }

    setState(() => _saving = true);
    try {
      // Con conexión va a la API; sin conexión queda guardado en el celular.
      final handler = ref.read(ecoPuntoHandlerProvider);
      final point = widget.point;
      final SaveResult result;
      if (point == null) {
        result = await handler.crear(
          nombre: _name.text.trim(),
          zona: _zone.text.trim(),
          descripcion: _description.text.trim(),
        );
      } else {
        result = await handler.editar(point.id, {
          'name': _name.text.trim(),
          'building_zone': _zone.text.trim(),
          'description': _description.text.trim(),
        });
      }
      if (!mounted) return;
      refreshOperationalData(ref.invalidate);
      Navigator.of(context).pop(result);
    } catch (error) {
      if (mounted) AppAlerts.error(context, t.actionErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEdit = widget.point != null;

    return AlertDialog(
      icon: const Icon(Icons.place_outlined),
      title: Text(isEdit ? t.editEcoPoint : t.newEcoPoint),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: !isEdit,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: t.fieldName),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return t.fieldRequired;
                    return Validators.isValidName(text) ? null : t.invalidName;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _zone,
                  maxLength: 100,
                  decoration: InputDecoration(labelText: t.fieldZone),
                  validator: (value) =>
                      (value?.trim().length ?? 0) > 100 ? t.invalidZone : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  maxLength: 255,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: t.fieldDescription),
                  validator: (value) => (value?.trim().length ?? 0) > 255
                      ? t.invalidDescription
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        SaveButton(
          saving: _saving,
          onPressed: _save,
          label: isEdit ? t.save : t.create,
        ),
      ],
    );
  }
}
