import 'package:flutter/material.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';

/// Valida un formulario y avisa qué pasó:
/// - Si falta algún campo obligatorio → "Por favor completa todos los campos".
/// - Si los campos están llenos pero alguno no cumple su formato → "Revisa
///   los campos marcados en rojo".
/// Cada campo, además, muestra su propio mensaje debajo (validator).
bool validateForm(
  BuildContext context,
  GlobalKey<FormState> formKey, {
  required bool missingRequired,
}) {
  final t = AppLocalizations.of(context)!;
  final valid = formKey.currentState?.validate() ?? false;
  if (valid) return true;
  AppAlerts.warning(
    context,
    missingRequired ? t.completeAllFields : t.checkFields,
  );
  return false;
}

/// Botón principal de un formulario que muestra un indicador mientras guarda.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.saving,
    required this.onPressed,
    required this.label,
    this.icon = Icons.save_outlined,
  });

  final bool saving;
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: saving ? null : onPressed,
      icon: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
