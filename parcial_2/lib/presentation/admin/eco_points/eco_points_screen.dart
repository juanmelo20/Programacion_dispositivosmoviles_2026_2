import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/handler/ecopunto_handler.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/model/local/pending_change_model.dart';
import 'package:parcial_2/presentation/admin/eco_points/widgets/eco_point_dialog.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/sync_banner.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';
import 'package:parcial_2/services/offline/eco_points_offline_service.dart';

/// Texto escrito en el buscador de puntos ecológicos.
final _searchTextProvider = StateProvider.autoDispose<String>((ref) => '');

enum _PointAction {
  containers,
  edit,
  activate,
  deactivate,
  delete,
  viewSyncError,
  discardChange,
}

/// Puntos ecológicos del campus. El administrador ve también los inactivos
/// y puede crearlos, editarlos, activarlos/desactivarlos y eliminarlos.
///
/// Funciona sin conexión: muestra la copia guardada en el celular, y lo que
/// se cree, edite o elimine queda "pendiente" hasta que vuelva la conexión.
class EcoPointsScreen extends ConsumerWidget {
  const EcoPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final isAdmin =
        ref.watch(authProvider).user?.role == UserRole.administrador;
    // Consulta (query) por el handler: con texto, la busca SQLite.
    final query = (
      includeInactive: isAdmin,
      text: ref.watch(_searchTextProvider),
    );
    final value = ref.watch(ecoPointsSearchProvider(query));
    Future<void> refresh() async {
      // Deslizar para actualizar también envía los cambios pendientes.
      await ref.read(syncProvider.notifier).sync();
      final _ = await ref.refresh(ecoPointsSearchProvider(query).future);
    }

    return Column(
      children: [
        const SyncBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: (text) =>
                ref.read(_searchTextProvider.notifier).state = text,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.searchEcoPoints,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(child: _list(t, ref, value, refresh, query)),
      ],
    );
  }

  Widget _list(
    AppLocalizations t,
    WidgetRef ref,
    AsyncValue<List<LocationModel>> value,
    Future<void> Function() refresh,
    EcoPointsQuery query,
  ) {
    final isAdmin = query.includeInactive;
    return AsyncView<List<LocationModel>>(
      value: value,
      onRetry: () => ref.invalidate(ecoPointsSearchProvider(query)),
      skeleton: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 4; i++) ...[
            _EcoPointCard(point: LocationModel.placeholder(i), isAdmin: false),
            const SizedBox(height: 12),
          ],
        ],
      ),
      builder: (points) {
        if (points.isEmpty) {
          return RefreshableView(
            onRefresh: refresh,
            child: EmptyView(
              icon: Icons.place_outlined,
              message: t.ecoPointsEmpty,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: points.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _EcoPointCard(point: points[index], isAdmin: isAdmin),
          ),
        );
      },
    );
  }
}

class _EcoPointCard extends ConsumerWidget {
  const _EcoPointCard({required this.point, required this.isAdmin});

  final LocationModel point;
  final bool isAdmin;

  void _openContainers(BuildContext context) {
    // Un punto creado sin conexión todavía no tiene contenedores en la API.
    if (point.isLocalOnly) {
      AppAlerts.show(context, AppLocalizations.of(context)!.localOnlyHint);
      return;
    }
    context.go(AppRoutes.containersAt(point.id, point.displayName));
  }

  Future<void> _edit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final result = await showEcoPointDialog(context, point: point);
    if (result != null && context.mounted) {
      AppAlerts.success(
        context,
        result == SaveResult.synced ? t.ecoPointSaved : t.savedOffline,
      );
    }
  }

  Future<void> _setActive(BuildContext context, {required bool active}) async {
    final t = AppLocalizations.of(context)!;
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final result = await AppAlerts.progress(
        context,
        () => container
            .read(ecoPuntoHandlerProvider)
            .activar(point.id, activo: active),
      );
      refreshOperationalData(container.invalidate);
      if (context.mounted) {
        AppAlerts.success(
          context,
          result == SaveResult.savedLocally
              ? t.savedOffline
              : active
              ? t.ecoPointActivated
              : t.ecoPointDeactivated,
        );
      }
    } catch (error) {
      // Ej. 409: "tiene terminales asociadas" → se muestra el motivo.
      if (context.mounted) {
        AppAlerts.error(context, t.actionErrorMessage(error));
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppAlerts.confirm(
      context,
      title: t.deletePointTitle,
      message: t.deletePointMessage,
      confirmText: t.menuDelete,
      cancelText: t.cancel,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final result = await AppAlerts.progress(
        context,
        () => container.read(ecoPuntoHandlerProvider).eliminar(point.id),
      );
      refreshOperationalData(container.invalidate);
      if (context.mounted) {
        AppAlerts.success(
          context,
          result == SaveResult.savedLocally
              ? t.deletedOffline
              : t.ecoPointDeleted,
        );
      }
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, t.actionErrorMessage(error));
      }
    }
  }

  /// Quita el cambio pendiente: el punto vuelve a como está en la API.
  Future<void> _discardChange(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(ecoPuntoHandlerProvider).descartarCambio(point.id);
    refreshOperationalData(container.invalidate);
    if (context.mounted) AppAlerts.success(context, t.changeDiscarded);
  }

  void _showSyncError(BuildContext context) {
    final error = point.syncError;
    if (error == null) return;
    AppAlerts.error(
      context,
      AppLocalizations.of(context)!.actionErrorMessage(error),
    );
  }

  String _pendingLabel(AppLocalizations t) {
    switch (point.pendingAction) {
      case PendingAction.create:
        return t.pendingCreate;
      case PendingAction.delete:
        return t.pendingDelete;
      default:
        return t.pendingUpdate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final zone = point.buildingZone?.trim() ?? '';
    final description = point.description?.trim() ?? '';
    // Eliminado sin conexión: se ve atenuado hasta que se sincronice.
    final deleting = point.isPendingDelete;

    final card = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openContainers(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: point.isActive
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.place_rounded,
                  color: point.isActive
                      ? scheme.onPrimaryContainer
                      : scheme.outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: deleting
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (zone.isNotEmpty)
                      Text(
                        zone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(description, style: theme.textTheme.bodySmall),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TagChip(
                          label: point.isActive
                              ? t.activeBadge
                              : t.inactiveBadge,
                          color: point.isActive
                              ? WasteColors.status(context, 'normal')
                              : scheme.outline,
                        ),
                        // Cambio guardado en el celular que falta enviar.
                        if (point.isPending)
                          point.syncError == null
                              ? TagChip(
                                  label: _pendingLabel(t),
                                  icon: Icons.schedule_rounded,
                                  color: scheme.tertiary,
                                )
                              : TagChip(
                                  label: t.syncErrorBadge,
                                  icon: Icons.error_outline_rounded,
                                  color: scheme.error,
                                ),
                        Text(
                          t.pointContainers(
                            point.activeContainerCount,
                            point.containerCount,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_PointAction>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _PointAction.containers:
                      _openContainers(context);
                    case _PointAction.edit:
                      _edit(context);
                    case _PointAction.activate:
                      _setActive(context, active: true);
                    case _PointAction.deactivate:
                      _setActive(context, active: false);
                    case _PointAction.delete:
                      _delete(context);
                    case _PointAction.viewSyncError:
                      _showSyncError(context);
                    case _PointAction.discardChange:
                      _discardChange(context);
                  }
                },
                itemBuilder: (context) => [
                  if (!point.isLocalOnly)
                    _item(
                      _PointAction.containers,
                      Icons.delete_outline_rounded,
                      t.menuViewContainers,
                    ),
                  if (isAdmin && !deleting) ...[
                    if (!point.isLocalOnly) const PopupMenuDivider(),
                    _item(_PointAction.edit, Icons.edit_outlined, t.menuEdit),
                    // Activar o desactivar solo cuando ya existe en la API.
                    if (!point.isLocalOnly)
                      point.isActive
                          ? _item(
                              _PointAction.deactivate,
                              Icons.toggle_off_outlined,
                              t.menuDeactivate,
                            )
                          : _item(
                              _PointAction.activate,
                              Icons.toggle_on_outlined,
                              t.menuActivate,
                            ),
                    _item(
                      _PointAction.delete,
                      Icons.delete_forever_outlined,
                      t.menuDelete,
                    ),
                  ],
                  if (point.isPending) ...[
                    const PopupMenuDivider(),
                    if (point.syncError != null)
                      _item(
                        _PointAction.viewSyncError,
                        Icons.error_outline_rounded,
                        t.menuViewSyncError,
                      ),
                    _item(
                      _PointAction.discardChange,
                      Icons.undo_rounded,
                      t.menuDiscardChange,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return deleting ? Opacity(opacity: 0.6, child: card) : card;
  }

  PopupMenuItem<_PointAction> _item(
    _PointAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_PointAction>(
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

/// Botón flotante del administrador para crear un punto ecológico.
class NewEcoPointButton extends StatelessWidget {
  const NewEcoPointButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () async {
        final result = await showEcoPointDialog(context);
        if (result != null && context.mounted) {
          AppAlerts.success(
            context,
            result == SaveResult.synced ? t.ecoPointSaved : t.savedOffline,
          );
        }
      },
      icon: const Icon(Icons.add_location_alt_outlined),
      label: Text(t.newEcoPoint),
    );
  }
}
