import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/collection_notes_dialog.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_actions.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

/// Ruta de recolección del recolector: el "carrito" de la app.
///
/// Es estado global (Riverpod): se llena desde Alertas, Contenedores o el
/// detalle, se puede reordenar y quitar, y al final se registran todas las
/// recolecciones en el backend, una por una, mostrando el avance (botón
/// flotante [RegisterRouteButton]).
class RouteScreen extends ConsumerStatefulWidget {
  const RouteScreen({super.key});

  @override
  ConsumerState<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends ConsumerState<RouteScreen> {
  @override
  void initState() {
    super.initState();
    // Al entrar se ocultan avisos de otras pantallas ("agregado a tu ruta").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
    });
    // Con conexión, se actualiza el llenado de los contenedores de la ruta.
    ref.read(routeProvider.notifier).refreshFromApi();
  }

  Future<void> _clear() async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppAlerts.confirm(
      context,
      title: t.routeClear,
      message: t.routeClearConfirm,
      confirmText: t.routeClear,
      cancelText: t.cancel,
      icon: Icons.remove_road_rounded,
      destructive: true,
    );
    if (confirmed) ref.read(routeProvider.notifier).clear();
  }

  void _remove(ContainerModel item, int index) {
    final t = AppLocalizations.of(context)!;
    ref.read(routeProvider.notifier).remove(item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.removedFromRoute(item.name)),
          action: SnackBarAction(
            label: t.undo,
            onPressed: () =>
                ref.read(routeProvider.notifier).insert(index, item),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = ref.watch(routeProvider);
    final units = items.fold<int>(0, (sum, c) => sum + c.currentCount);
    final role = ref.watch(authProvider).user?.role;

    if (items.isEmpty) {
      return ScrollFill(
        child: EmptyView(
          icon: Icons.route_outlined,
          title: t.routeEmptyTitle,
          message: t.routeEmptyMessage,
          action: FilledButton.tonalIcon(
            onPressed: () => context.go(AppRoutes.alerts),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(t.goToAlerts),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            margin: EdgeInsets.zero,
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Icon(Icons.route_rounded, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.routeSummary(items.length, units),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.routeHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: _clear, child: Text(t.routeClear)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            // Espacio al final para que el botón flotante no tape la última.
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) =>
                ref.read(routeProvider.notifier).reorder(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                key: ValueKey(item.id),
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey('dismiss-${item.id}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _remove(item, index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.routeRemove,
                          style: TextStyle(color: scheme.onErrorContainer),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: scheme.onErrorContainer,
                        ),
                      ],
                    ),
                  ),
                  child: ReorderableDelayedDragStartListener(
                    index: index,
                    child: _RouteStopCard(
                      index: index,
                      item: item,
                      onTap: () => ContainerActions.open(context, role, item),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({
    required this.index,
    required this.item,
    required this.onTap,
  });

  final int index;
  final ContainerModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CategoryAvatar(category: item.category, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.code} · ${item.locationName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FillBar(
                      percentage: item.fillPercentage,
                      status: item.status,
                      height: 6,
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: scheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Registra la recolección de todos los contenedores de la ruta, uno por uno.
/// Los que se registran salen de la ruta; los que fallan se quedan.
Future<void> registerRoute(
  BuildContext context,
  List<ContainerModel> items,
) async {
  final t = AppLocalizations.of(context)!;
  final container = ProviderScope.containerOf(context, listen: false);
  final notes = await showCollectionNotesDialog(
    context,
    title: t.routeConfirmTitle,
    message: t.routeConfirmMessage(items.length),
    confirmText: t.registerCollection,
  );
  if (notes == null || !context.mounted) return;

  final service = container.read(containerServiceProvider);
  // Textos que el diálogo de progreso escucha mientras avanza el registro.
  // No se liberan aquí a mano: el diálogo puede seguir dibujándose durante
  // su animación de cierre (se liberan solos cuando nadie los usa).
  final status = ValueNotifier<String>(t.routeProgress(1, items.length));
  final fraction = ValueNotifier<double?>(0);
  final registered = <int>[];
  var offline = false;

  await AppAlerts.progress(
    context,
    status: status,
    fraction: fraction,
    () async {
      for (var i = 0; i < items.length; i++) {
        status.value = t.routeProgress(i + 1, items.length);
        fraction.value = i / items.length;
        try {
          await service.registerCollection(items[i].id, notes: notes);
          registered.add(items[i].id);
        } on ApiException catch (error) {
          // Sesión vencida: se detiene (el guard lleva al login).
          if (error.type == ApiErrorType.unauthorized) break;
          // Sin conexión: se detiene; lo que falta sigue en la ruta, que está
          // guardada en el celular.
          if (error.type == ApiErrorType.noConnection ||
              error.type == ApiErrorType.timeout) {
            offline = true;
            break;
          }
        }
      }
      fraction.value = 1;
    },
  );

  // Los que se registraron salen de la ruta; los que fallaron se quedan.
  container.read(routeProvider.notifier).removeAll(registered);
  refreshOperationalData(container.invalidate);
  if (!context.mounted) return;

  final failed = items.length - registered.length;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        offline
            ? Icons.cloud_off_rounded
            : failed == 0
            ? Icons.task_alt_rounded
            : Icons.warning_amber_rounded,
      ),
      title: Text(t.moduleRoute),
      content: Text(
        offline
            ? t.routeOffline(registered.length)
            : failed == 0
            ? t.routeDone(registered.length)
            : t.routePartial(registered.length, failed),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.close),
        ),
      ],
    ),
  );
}

/// Botón flotante del recolector: registra toda la ruta. Al ser botón
/// flotante, los avisos (SnackBar) aparecen encima y no lo tapan.
class RegisterRouteButton extends ConsumerWidget {
  const RegisterRouteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final items = ref.watch(routeProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => registerRoute(context, items),
      icon: const Icon(Icons.local_shipping_outlined),
      label: Text(t.routeRegisterAll(items.length)),
    );
  }
}
