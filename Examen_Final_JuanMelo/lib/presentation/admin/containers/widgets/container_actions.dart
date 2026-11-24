import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/collection_notes_dialog.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

/// Permisos sobre contenedores según el perfil (los mismos del backend).
/// El front oculta lo que el perfil no puede hacer y el backend lo vuelve a
/// validar: si alguien fuerza la petición, responde 403.
abstract final class ContainerPermissions {
  /// Detalle completo (administrador y recolector).
  static bool canSeeDetail(UserRole? role) =>
      role == UserRole.administrador || role == UserRole.recolector;

  /// Vaciar contenedores: registrar la recolección (administrador y
  /// recolector). Los contenedores no se crean, editan ni retiran desde la app:
  /// se crean solos al asignar una terminal a un punto.
  static bool canCollect(UserRole? role) =>
      role == UserRole.administrador || role == UserRole.recolector;

  /// La ruta de recolección es del recolector.
  static bool usesRoute(UserRole? role) => role == UserRole.recolector;
}

/// Acciones sobre un contenedor que se usan desde varias pantallas (lista,
/// alertas, detalle). Así cada regla vive en un solo lugar.
abstract final class ContainerActions {
  /// Abre el detalle. El perfil Interesado no tiene detalle en el backend,
  /// así que ve el historial de llenado del contenedor.
  static void open(BuildContext context, UserRole? role, ContainerModel item) {
    if (ContainerPermissions.canSeeDetail(role)) {
      context.push(AppRoutes.containerDetail(item.id));
    } else {
      context.push(AppRoutes.fillHistory(item.id));
    }
  }

  static void openHistory(BuildContext context, ContainerModel item) {
    context.push(AppRoutes.fillHistory(item.id));
  }

  /// Agrega o quita el contenedor de la ruta (estado global).
  static void toggleRoute(
    BuildContext context,
    WidgetRef ref,
    ContainerModel item,
  ) {
    final t = AppLocalizations.of(context)!;
    final added = ref.read(routeProvider.notifier).toggle(item);
    AppAlerts.show(
      context,
      added ? t.addedToRoute(item.name) : t.removedFromRoute(item.name),
      type: added ? AlertType.success : AlertType.info,
    );
  }

  /// Pide observaciones y vacía el contenedor (registra la recolección).
  /// Devuelve true si quedó vacío.
  static Future<bool> registerCollection(
    BuildContext context,
    ContainerModel item,
  ) async {
    final t = AppLocalizations.of(context)!;
    final container = ProviderScope.containerOf(context, listen: false);
    final notes = await showCollectionNotesDialog(
      context,
      title: t.emptyContainerTitle(item.code),
      message: t.emptyContainerMessage,
      confirmText: t.emptyContainer,
    );
    if (notes == null || !context.mounted) return false;

    try {
      final result = await AppAlerts.progress(
        context,
        () => container
            .read(containerServiceProvider)
            .registerCollection(item.id, notes: notes),
      );
      // Ya se recogió: sale de la ruta y se actualizan las pantallas.
      container.read(routeProvider.notifier).remove(item.id);
      refreshOperationalData(container.invalidate);
      if (context.mounted) {
        AppAlerts.success(
          context,
          t.containerEmptied(result.collection.unitsCollected),
        );
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, t.actionErrorMessage(error));
      }
      return false;
    }
  }
}
