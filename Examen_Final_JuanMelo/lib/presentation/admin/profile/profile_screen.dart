import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/role_badge.dart';
import 'package:parcial_2/presentation/shared/widgets/settings_controls.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/theme_provider.dart';

/// Perfil del usuario. Los datos se piden a una ruta protegida
/// (GET /auth/me) con el token en la cabecera Authorization.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(profileProvider);

    return AsyncView<UserModel>(
      value: value,
      onRetry: () => ref.invalidate(profileProvider),
      skeleton: _ProfileBody(user: UserModel.placeholder(), skeleton: true),
      builder: (user) => RefreshIndicator(
        onRefresh: () => ref.refresh(profileProvider.future),
        child: _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user, this.skeleton = false});

  final UserModel user;
  final bool skeleton;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppAlerts.confirm(
      context,
      title: t.logoutConfirmTitle,
      message: t.logoutConfirmMessage,
      confirmText: t.logout,
      cancelText: t.cancel,
      icon: Icons.logout_rounded,
    );
    if (confirmed) await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = t.localeName;
    final expiresAt = ref.watch(authProvider).expiresAt;
    final isDark = ref.watch(themeProvider);

    return ListView(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(
              user.initials,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Center(child: RoleBadge(role: user.role)),
        const SizedBox(height: 20),
        SectionHeader(title: t.profileAccount),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.alternate_email_rounded,
                  label: t.profileUsername,
                  value: user.username,
                ),
                InfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: t.profileEmail,
                  value: user.email,
                ),
                InfoTile(
                  icon: roleIcon(user.role),
                  label: t.profileRole,
                  value: t.roleName(user.role),
                ),
                InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: t.profileCreated,
                  value: Formatters.date(user.createdAt, locale),
                ),
                InfoTile(
                  icon: Icons.login_rounded,
                  label: t.profileLastLogin,
                  value: user.lastLoginAt == null
                      ? t.never
                      : Formatters.dateTime(user.lastLoginAt, locale),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(title: t.profileSecurity),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoTile(
                  icon: Icons.verified_user_outlined,
                  label: t.profileSessionUntil,
                  value: Formatters.dateTime(expiresAt, locale),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(36, 0, 0, 10),
                  child: Text(
                    t.profileTokenStored,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(title: t.profilePreferences),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(t.darkMode),
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(t.language),
                trailing: const LanguageSelector(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
          ),
          onPressed: () => _logout(context, ref),
          icon: const Icon(Icons.logout_rounded),
          label: Text(t.logout),
        ),
      ],
    );
  }
}
