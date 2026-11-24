import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/form_helpers.dart';
import 'package:parcial_2/providers/api_provider.dart';

/// El administrador asigna una contraseña nueva. Devuelve true si se cambió.
Future<bool> showResetPasswordDialog(
  BuildContext context,
  UserModel user,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => _ResetPasswordDialog(user: user),
  );
  return saved ?? false;
}

class _ResetPasswordDialog extends ConsumerStatefulWidget {
  const _ResetPasswordDialog({required this.user});

  final UserModel user;

  @override
  ConsumerState<_ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final missing = _password.text.isEmpty || _confirm.text.isEmpty;
    if (!validateForm(context, _formKey, missingRequired: missing)) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(userServiceProvider)
          .resetPassword(widget.user.id, _password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) AppAlerts.error(context, t.actionErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: const Icon(Icons.lock_reset_rounded),
      title: Text(t.resetPasswordTitle(widget.user.username)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: t.fieldNewPassword,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? t.showPassword : t.hidePassword,
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) return t.fieldRequired;
                  return Validators.isValidPassword(value!)
                      ? null
                      : t.invalidPassword;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: InputDecoration(labelText: t.fieldPasswordConfirm),
                validator: (value) {
                  if ((value ?? '').isEmpty) return t.fieldRequired;
                  return value == _password.text ? null : t.passwordsDontMatch;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(t.cancel),
        ),
        SaveButton(saving: _saving, onPressed: _save, label: t.save),
      ],
    );
  }
}
