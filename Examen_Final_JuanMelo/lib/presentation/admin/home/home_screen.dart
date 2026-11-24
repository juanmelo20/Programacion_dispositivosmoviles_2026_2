import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_admin.dart';
import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/model/admin/report_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_card.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/charts.dart';
import 'package:parcial_2/presentation/shared/widgets/eco_points_carousel.dart';
import 'package:parcial_2/presentation/shared/widgets/role_badge.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

/// Filtro del resumen semanal del perfil Interesado.
const AnalyticsQuery _lastWeek = (days: 7, category: null, locationId: null);

/// Inicio de la zona privada. Todos ven el carrusel de puntos ecológicos
/// activos; además, cada perfil ve su resumen:
/// - Administrador: indicadores del día y contenedores en alerta.
/// - Recolector: cuántos contenedores necesitan recolección y su ruta.
/// - Interesado: resumen de los últimos 7 días.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    refreshOperationalData(ref.invalidate);
    ref.invalidate(analyticsProvider(_lastWeek));
    try {
      await ref.read(locationsProvider(false).future);
    } catch (_) {
      // Cada sección muestra su propio error con "Reintentar".
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final role = user.role;
    final expiresAt = auth.expiresAt;
    final registered = UserRole.registered.contains(role);

    // SingleChildScrollView + Column (y no ListView): el ListView destruye las
    // secciones que salen de la pantalla al hacer scroll; al destruirse el
    // carrusel, su provider (autoDispose) borraba los datos y al volver a
    // subir se pedían otra vez a la API (y aparecía el esqueleto de nuevo).
    // El inicio tiene pocas secciones, así que se construyen todas una vez.
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeCard(user: user),
            if (expiresAt != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.verified_user_outlined,
                text: t.sessionValidUntil(
                  Formatters.dateTime(expiresAt, t.localeName),
                ),
              ),
            ],
            if (registered) ...[
              const SizedBox(height: 20),
              SectionHeader(title: t.homeEcoPoints),
              const _EcoPointsSection(),
            ],
            const SizedBox(height: 12),
            switch (role) {
              UserRole.administrador => const _AdminSummary(),
              UserRole.recolector => const _CollectorSummary(),
              UserRole.interesado => const _ViewerSummary(),
              UserRole.desconocido => const SizedBox.shrink(),
            },
            if (registered) ...[
              const SizedBox(height: 20),
              SectionHeader(title: t.modulesTitle),
              _ModuleShortcuts(role: role),
            ],
          ],
        ),
      ),
    );
  }
}

/// Carrusel con los puntos ecológicos activos (GET /locations).
class _EcoPointsSection extends ConsumerWidget {
  const _EcoPointsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(locationsProvider(false));

    return AsyncView<List<LocationModel>>(
      value: value,
      fill: false,
      onRetry: () => ref.invalidate(locationsProvider(false)),
      skeleton: EcoPointsCarousel(
        autoPlay: false,
        points: [LocationModel.placeholder(0), LocationModel.placeholder(1)],
      ),
      builder: (points) {
        // Los eliminados sin conexión ya no se muestran aquí.
        final active = points
            .where((p) => p.isActive && !p.isPendingDelete)
            .toList();
        if (active.isEmpty) {
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(t.homeEcoPointsEmpty),
            ),
          );
        }
        return EcoPointsCarousel(
          points: active,
          onTap: (point) {
            // Creado sin conexión: todavía no tiene contenedores en la API.
            if (point.isLocalOnly) {
              AppAlerts.show(context, t.localOnlyHint);
              return;
            }
            context.go(AppRoutes.containersAt(point.id, point.displayName));
          },
        );
      },
    );
  }
}

/// Indicadores del día y alertas (GET /reports/overview).
class _AdminSummary extends ConsumerWidget {
  const _AdminSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<OverviewModel>(
      value: ref.watch(overviewProvider),
      fill: false,
      onRetry: () => ref.invalidate(overviewProvider),
      skeleton: _AdminSummaryBody(overview: OverviewModel.placeholder()),
      builder: (overview) => _AdminSummaryBody(overview: overview),
    );
  }
}

class _AdminSummaryBody extends StatelessWidget {
  const _AdminSummaryBody({required this.overview});

  final OverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = t.localeName;
    final kpis = overview.kpis;
    final alerts = overview.alerts.take(3).toList();
    String n(num value) => Formatters.number(value, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.homeTodaySummary),
        ResponsiveGrid(
          children: [
            KpiCard(
              icon: Icons.auto_awesome_outlined,
              label: t.kpiToday,
              value: n(kpis.classificationsToday),
            ),
            KpiCard(
              icon: Icons.delete_outline_rounded,
              label: t.kpiActiveContainers,
              value: n(kpis.activeContainers),
              color: Theme.of(context).colorScheme.secondary,
            ),
            KpiCard(
              icon: Icons.notifications_active_outlined,
              label: t.kpiAttention,
              value: n(kpis.attentionCount),
              color: WasteColors.status(context, FillStatus.attention),
            ),
            KpiCard(
              icon: Icons.warning_amber_rounded,
              label: t.kpiFull,
              value: n(kpis.fullCount),
              color: WasteColors.status(context, FillStatus.full),
            ),
            KpiCard(
              icon: Icons.speed_rounded,
              label: t.kpiAverageFill,
              value: Formatters.percent(kpis.averageFill, locale),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            KpiCard(
              icon: Icons.local_shipping_outlined,
              label: t.kpiCollectionsToday,
              value: n(kpis.collectionsToday),
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionHeader(
          title: t.moduleAlerts,
          action: TextButton(
            onPressed: () => context.go(AppRoutes.alerts),
            child: Text(t.seeAll),
          ),
        ),
        if (alerts.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.task_alt_rounded),
              title: Text(t.alertsEmpty),
            ),
          )
        else
          for (final item in alerts) ...[
            ContainerCard(container: item),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

/// Lo que necesita el recolector al empezar su turno.
class _CollectorSummary extends ConsumerWidget {
  const _CollectorSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final routeCount = ref.watch(routeProvider).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.homeTodaySummary),
        AsyncView<List<ContainerModel>>(
          value: ref.watch(alertsProvider),
          fill: false,
          onRetry: () => ref.invalidate(alertsProvider),
          skeleton: _ActionCard(
            icon: Icons.notifications_active_outlined,
            title: t.homeAlertsCard(3),
            action: t.goToAlerts,
            color: WasteColors.status(context, FillStatus.attention),
            onTap: () {},
          ),
          builder: (alerts) => _ActionCard(
            icon: alerts.isEmpty
                ? Icons.task_alt_rounded
                : Icons.notifications_active_outlined,
            title: t.homeAlertsCard(alerts.length),
            action: t.goToAlerts,
            color: alerts.isEmpty
                ? WasteColors.status(context, FillStatus.normal)
                : WasteColors.status(context, FillStatus.attention),
            onTap: () => context.go(AppRoutes.alerts),
          ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.route_rounded,
          title: t.homeRouteCard(routeCount),
          action: t.moduleRoute,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => context.go(AppRoutes.route),
        ),
      ],
    );
  }
}

/// Resumen de la semana para el perfil Interesado.
class _ViewerSummary extends ConsumerWidget {
  const _ViewerSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.homeLast7Days,
          action: TextButton(
            onPressed: () => context.go(AppRoutes.reports),
            child: Text(t.seeAll),
          ),
        ),
        AsyncView<AnalyticsModel>(
          value: ref.watch(analyticsProvider(_lastWeek)),
          fill: false,
          onRetry: () => ref.invalidate(analyticsProvider(_lastWeek)),
          skeleton: _ViewerKpis(report: AnalyticsModel.placeholder()),
          builder: (report) => _ViewerKpis(report: report),
        ),
      ],
    );
  }
}

class _ViewerKpis extends StatelessWidget {
  const _ViewerKpis({required this.report});

  final AnalyticsModel report;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = t.localeName;
    final scheme = Theme.of(context).colorScheme;
    final totals = report.totals;

    return ResponsiveGrid(
      children: [
        KpiCard(
          icon: Icons.auto_awesome_outlined,
          label: t.kpiClassifications,
          value: Formatters.number(totals.classifications, locale),
        ),
        KpiCard(
          icon: Icons.psychology_outlined,
          label: t.kpiAvgConfidence,
          value: Formatters.percent(totals.averageConfidence * 100, locale),
          color: scheme.secondary,
        ),
        KpiCard(
          icon: Icons.local_shipping_outlined,
          label: t.kpiCollections,
          value: Formatters.number(totals.collections, locale),
          color: scheme.tertiary,
        ),
        KpiCard(
          icon: Icons.inventory_2_outlined,
          label: t.kpiUnitsCollected,
          value: Formatters.number(totals.unitsCollected, locale),
          color: scheme.tertiary,
        ),
      ],
    );
  }
}

/// Tarjeta grande con un dato y un acceso directo.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.action,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String action;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accesos directos a los módulos del perfil (la misma lista del menú).
class _ModuleShortcuts extends StatelessWidget {
  const _ModuleShortcuts({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final modules = routerConfigAdmin
        .where((r) => r.inDrawer && r.name != 'home' && r.allows(role))
        .toList();

    return ResponsiveGrid(
      minItemWidth: 140,
      children: [
        for (final module in modules)
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.go(module.path),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 108),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          module.icon,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        module.title(t),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.user});

  final UserModel user;

  String _description(AppLocalizations t) {
    switch (user.role) {
      case UserRole.administrador:
        return t.homeAdminDescription;
      case UserRole.recolector:
        return t.homeCollectorDescription;
      case UserRole.interesado:
        return t.homeInterestedDescription;
      case UserRole.desconocido:
        return t.homeUnknownDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.onPrimary,
            foregroundColor: scheme.primary,
            child: Text(
              user.initials,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.greeting(user.displayName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                RoleBadge(role: user.role, inverted: true),
                const SizedBox(height: 12),
                Text(
                  _description(t),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
