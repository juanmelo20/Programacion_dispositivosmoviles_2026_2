import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/public/auth/header_widget.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/app_logo.dart';
import 'package:parcial_2/presentation/shared/widgets/settings_controls.dart';
import 'package:parcial_2/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  ///Controlador del formulario para validar los campos y enviar los datos al servidor.
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  ///Para pasar el foco al campo de contraseña cuando se presiona "next" en el teclado.

  bool _obscurePassword =
      true; //Para ocultar o mostrar la contraseña en el campo de texto.
  bool _loading = false; //Para mostrar un indicador de carga mientras se realiza la petición al servidor.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled; //Para habilitar o deshabilitar la validación automática de los campos del formulario.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final expired = ref.read(authProvider.notifier).consumeSessionExpired();
      if (expired) {
        AppAlerts.warning(
          context,
          AppLocalizations.of(context)!.sessionExpired,
        );
      }
    });
  }

  @override
  void dispose() {
    ///Se llama cuando el widget se elimina del árbol de widgets. Se utiliza para liberar recursos y evitar fugas de memoria.
    _userController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateUser(String? value, AppLocalizations t) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return t.fieldRequired;
    if (!Validators.isValidUserOrEmail(text)) return t.invalidUser;
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations t) {
    final text = value ?? '';
    if (text.isEmpty) return t.fieldRequired;
    if (!Validators.isValidPassword(text)) return t.invalidPassword;
    return null;
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    final auth = ref.read(authProvider.notifier);
    FocusScope.of(context).unfocus();

    if (auth.isLocked) {
      AppAlerts.warning(context, t.tooManyAttempts(auth.remainingLockSeconds));
      return;
    }

    final username = _userController.text.trim();
    final password = _passwordController.text;

    // Validación del formulario antes de enviar nada al servidor.
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      final missingData = username.isEmpty || password.isEmpty;
      AppAlerts.warning(
        context,
        missingData ? t.completeAllFields : t.checkFields,
      );
      return;
    }

    setState(() => _loading = true);
    final result = await auth.login(username, password);
    if (!mounted) return;
    setState(() => _loading = false);

    // Con éxito no hay que navegar: el guard del router detecta la sesión y
    // lleva al usuario a la zona privada.
    if (result == LoginResult.success) return;

    // Credenciales inválidas alerta
    if (result == LoginResult.invalidCredentials ||
        result == LoginResult.tooManyAttempts) {
      _formKey.currentState!.reset();
      setState(() => _autovalidateMode = AutovalidateMode.disabled);
    }
    AppAlerts.error(
      context,
      t.loginMessage(result, lockSeconds: auth.remainingLockSeconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(
              height: 280,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: ThemeToggleButton(color: scheme.onPrimary),
                  ),
                  Align(
                    alignment: const Alignment(0, -0.3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 76, inverted: true),
                        const SizedBox(height: 12),
                        Text(
                          t.appTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          t.appSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: _buildForm(t, theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations t, ThemeData theme) {
    final scheme = theme.colorScheme;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.loginTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.loginSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Usuario o correo
            TextFormField(
              controller: _userController,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                LengthLimitingTextInputFormatter(100),
              ],
              decoration: InputDecoration(
                labelText: t.userLabel,
                hintText: t.userHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => _validateUser(value, t),
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 16),

            // Contraseña
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !_loading,
              obscureText: _obscurePassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              inputFormatters: [LengthLimitingTextInputFormatter(72)],
              decoration: InputDecoration(
                labelText: t.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? t.showPassword : t.hidePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => _validatePassword(value, t),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(t.login),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                const LanguageSelector(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
