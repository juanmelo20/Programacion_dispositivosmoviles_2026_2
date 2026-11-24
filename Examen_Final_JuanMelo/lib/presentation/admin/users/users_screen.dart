import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/users/widgets/reset_password_dialog.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/role_badge.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';

enum _UserAction { edit, password, activate, deactivate }

/// Usuarios del sistema (solo administrador): buscar, filtrar por perfil,
/// crear, editar, restablecer contraseña y activar/desactivar.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  UserRole? _role;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  /// La lista llega completa de la API; la búsqueda se hace en el celular.
  List<UserModel> _filter(List<UserModel> users) {
    return users.where((user) {
      if (_role != null && user.role != _role) return false;
      if (_query.isEmpty) return true;
      return user.username.toLowerCase().contains(_query) ||
          user.email.toLowerCase().contains(_query) ||
          (user.fullName ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(usersProvider);
    Future<void> refresh() => ref.refresh(usersProvider.future);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: t.searchUsers,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final role in [null, ...UserRole.registered])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: role == null
                        ? null
                        : Icon(roleIcon(role), size: 18),
                    label: Text(role == null ? t.allLabel : t.roleName(role)),
                    selected: _role == role,
                    onSelected: (_) => setState(() => _role = role),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<List<UserModel>>(
            value: value,
            onRetry: () => ref.invalidate(usersProvider),
            skeleton: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 5; i++) ...[
                  _UserCard(user: UserModel.placeholder(i)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
            builder: (users) {
              final items = _filter(users);
              if (items.isEmpty) {
                return RefreshableView(
                  onRefresh: refresh,
                  child: EmptyView(
                    icon: Icons.person_search_outlined,
                    message: t.usersEmpty,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _UserCard(user: items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});

  final UserModel user;

  Future<void> _edit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final saved = await context.push<bool>(AppRoutes.userEdit(user.id));
    if (saved == true && context.mounted) {
      AppAlerts.success(context, t.userUpdated);
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final saved = await showResetPasswordDialog(context, user);
    if (saved && context.mounted) AppAlerts.success(context, t.passwordUpdated);
  }

  Future<void> _setActive(BuildContext context, {required bool active}) async {
    final t = AppLocalizations.of(context)!;
    final container = ProviderScope.containerOf(context, listen: false);
    if (!active) {
      final confirmed = await AppAlerts.confirm(
        context,
        title: t.deactivateUserTitle(user.username),
        message: t.deactivateUserMessage,
        confirmText: t.menuDeactivate,
        cancelText: t.cancel,
        icon: Icons.person_off_outlined,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    try {
      await AppAlerts.progress(
        context,
        () => container.read(userServiceProvider).update(user.id, {
          'is_active': active,
        }),
      );
      container.invalidate(usersProvider);
      if (context.mounted) {
        AppAlerts.success(
          context,
          active ? t.userActivated : t.userDeactivated,
        );
      }
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, t.actionErrorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMe = ref.watch(currentUserIdProvider) == user.id;
    final lastLogin = user.lastLoginAt;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: user.isActive
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                foregroundColor: user.isActive
                    ? scheme.onPrimaryContainer
                    : scheme.outline,
                child: Text(
                  user.initials,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${user.username} · ${user.email}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RoleBadge(role: user.role),
                        if (isMe)
                          TagChip(label: t.youBadge, color: scheme.tertiary),
                        if (!user.isActive)
                          TagChip(label: t.inactiveBadge, color: scheme.error),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastLogin == null
                          ? t.neverSignedIn
                          : t.lastLoginLabel(
                              Formatters.dateTime(lastLogin, t.localeName),
                            ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_UserAction>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _UserAction.edit:
                      _edit(context);
                    case _UserAction.password:
                      _resetPassword(context);
                    case _UserAction.activate:
                      _setActive(context, active: true);
                    case _UserAction.deactivate:
                      _setActive(context, active: false);
                  }
                },
                itemBuilder: (context) => [
                  _item(_UserAction.edit, Icons.edit_outlined, t.menuEdit),
                  _item(
                    _UserAction.password,
                    Icons.lock_reset_rounded,
                    t.menuResetPassword,
                  ),
                  // Nadie puede desactivarse a sí mismo (regla del backend).
                  if (!isMe)
                    user.isActive
                        ? _item(
                            _UserAction.deactivate,
                            Icons.person_off_outlined,
                            t.menuDeactivate,
                          )
                        : _item(
                            _UserAction.activate,
                            Icons.person_outline_rounded,
                            t.menuActivate,
                          ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_UserAction> _item(
    _UserAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_UserAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Botón flotante del administrador para crear un usuario.
class NewUserButton extends StatelessWidget {
  const NewUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () async {
        final saved = await context.push<bool>(AppRoutes.userNew);
        if (saved == true && context.mounted) {
          AppAlerts.success(context, t.userCreated);
        }
      },
      icon: const Icon(Icons.person_add_alt_1_outlined),
      label: Text(t.titleNewUser),
    );
  }
}
