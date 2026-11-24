import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_admin.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/widgets/role_badge.dart';
import 'package:parcial_2/presentation/shared/widgets/settings_controls.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/theme_provider.dart';

/// Menú lateral. Solo muestra los módulos que el perfil del usuario puede
/// abrir.
class DrawerWidget extends ConsumerWidget {
  const DrawerWidget({super.key, this.currentRouteName});

  final String? currentRouteName;

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    final confirmed = await AppAlerts.confirm(
      context,
      title: t.logoutConfirmTitle,
      message: t.logoutConfirmMessage,
      confirmText: t.logout,
      cancelText: t.cancel,
      icon: Icons.logout_rounded,
    );
    if (!confirmed) return;
    // Al cerrar sesión el guard redirige automáticamente al login.
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final isDark = ref.watch(themeProvider);

    final items = routerConfigAdmin
        .where((route) => route.inDrawer && route.allows(user?.role))
        .toList();

    return Drawer(
      child: Column(
        children: [
          if (user != null) _DrawerHeader(user: user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final item in items)
                  ListTile(
                    selected: item.name == currentRouteName,
                    selectedTileColor: scheme.secondaryContainer,
                    selectedColor: scheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    leading: Icon(item.icon),
                    title: Text(item.title(t)),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (item.name != currentRouteName) context.go(item.path);
                    },
                  ),
                const Divider(height: 24),
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
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 28),
              leading: Icon(Icons.logout_rounded, color: scheme.error),
              title: Text(t.logout, style: TextStyle(color: scheme.error)),
              onTap: () => _logout(context, ref, t),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: scheme.onPrimary,
                foregroundColor: scheme.primary,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 10),
              RoleBadge(role: user.role, inverted: true),
            ],
          ),
        ),
      ),
    );
  }
}
