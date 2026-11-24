import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/form_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/page_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/role_badge.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Crear o editar un usuario (solo administrador).
class UserFormScreen extends ConsumerWidget {
  const UserFormScreen({super.key, this.userId});

  /// null = usuario nuevo.
  final int? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final id = userId;

    return Scaffold(
      appBar: AppBar(
        leading: pageBackButton(context, AppRoutes.users),
        title: Text(id == null ? t.titleNewUser : t.titleEditUser),
      ),
      body: id == null
          ? const _UserForm()
          : AsyncView<List<UserModel>>(
              value: ref.watch(usersProvider),
              onRetry: () => ref.invalidate(usersProvider),
              skeleton: _UserForm(
                initial: UserModel.placeholder(),
                skeleton: true,
              ),
              builder: (users) {
                final matches = users.where((u) => u.id == id);
                if (matches.isEmpty) {
                  return ScrollFill(
                    child: EmptyView(
                      icon: Icons.person_off_outlined,
                      message: t.errorNotFound,
                    ),
                  );
                }
                return _UserForm(initial: matches.first);
              },
            ),
    );
  }
}

class _UserForm extends ConsumerStatefulWidget {
  const _UserForm({this.initial, this.skeleton = false});

  final UserModel? initial;
  final bool skeleton;

  @override
  ConsumerState<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<_UserForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _fullName;
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole? _role;
  bool _active = true;
  bool _obscure = true;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final user = widget.initial;
    _username = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _fullName = TextEditingController(text: user?.fullName ?? '');
    _role = user == null || user.role == UserRole.desconocido
        ? null
        : user.role;
    _active = user?.isActive ?? true;
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _fullName.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save({required bool isMe}) async {
    final t = AppLocalizations.of(context)!;
    final missing =
        _username.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _role == null ||
        (!_isEdit && (_password.text.isEmpty || _confirm.text.isEmpty));
    if (!validateForm(context, _formKey, missingRequired: missing)) return;

    setState(() => _saving = true);
    try {
      final service = ref.read(userServiceProvider);
      final fullName = _fullName.text.trim();
      final initial = widget.initial;

      if (initial == null) {
        await service.create(
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          role: _role!.name,
          fullName: fullName.isEmpty ? null : fullName,
        );
      } else {
        await service.update(initial.id, {
          'email': _email.text.trim(),
          'full_name': fullName,
          // El backend no deja cambiar el propio perfil ni desactivarse.
          if (!isMe) 'role': _role!.name,
          if (!isMe) 'is_active': _active,
        });
        // Si se editó a sí mismo, se actualiza el nombre del menú.
        if (isMe) await ref.read(authProvider.notifier).verifySession();
      }

      if (!mounted) return;
      ref.invalidate(usersProvider);
      closePage(context, fallback: AppRoutes.users, result: true);
    } catch (error) {
      if (mounted) AppAlerts.error(context, t.actionErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isMe =
        _isEdit && ref.watch(currentUserIdProvider) == widget.initial!.id;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        physics: widget.skeleton ? const NeverScrollableScrollPhysics() : null,
        children: [
          TextFormField(
            controller: _username,
            readOnly: _isEdit,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: t.fieldUsername,
              helperText: _isEdit ? t.usernameLocked : null,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return t.fieldRequired;
              return Validators.username.hasMatch(text)
                  ? null
                  : t.invalidUsername;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: t.fieldEmail,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return t.fieldRequired;
              return Validators.isValidEmail(text) ? null : t.invalidEmail;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t.fieldFullName,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              return Validators.isValidFullName(text)
                  ? null
                  : t.invalidFullName;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserRole>(
            initialValue: _role,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: t.fieldRole,
              prefixIcon: const Icon(Icons.verified_user_outlined),
              helperText: isMe ? t.cantEditOwnRole : null,
              helperMaxLines: 2,
            ),
            hint: Text(t.selectOption),
            items: [
              for (final role in UserRole.registered)
                DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(roleIcon(role), size: 20),
                      const SizedBox(width: 10),
                      Text(t.roleName(role)),
                    ],
                  ),
                ),
            ],
            onChanged: isMe ? null : (value) => setState(() => _role = value),
            validator: (value) => value == null ? t.fieldRequired : null,
          ),
          if (_isEdit)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.fieldActive),
              subtitle: _active ? null : Text(t.deactivateUserMessage),
              value: _active,
              onChanged: isMe
                  ? null
                  : (value) => setState(() => _active = value),
            )
          else ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: t.fieldNewPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: t.fieldPasswordConfirm,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return t.fieldRequired;
                return value == _password.text ? null : t.passwordsDontMatch;
              },
            ),
          ],
          const SizedBox(height: 24),
          SaveButton(
            saving: _saving,
            onPressed: () => _save(isMe: isMe),
            label: _isEdit ? t.save : t.create,
          ),
        ],
      ),
    );
  }
}
