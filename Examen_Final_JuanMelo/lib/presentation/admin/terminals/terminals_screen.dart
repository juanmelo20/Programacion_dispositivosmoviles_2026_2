import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/terminal_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Terminales de los puntos ecológicos (solo administrador).
///
/// Cada terminal es una pantalla que muestra un código de 6 dígitos. Aquí se
/// ve cuáles hay y, con el botón «Agregar terminal», se asigna una a un punto.
class TerminalsScreen extends ConsumerWidget {
  const TerminalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(terminalsProvider);
    Future<void> refresh() => ref.refresh(terminalsProvider.future);

    return AsyncView<List<TerminalModel>>(
      value: value,
      onRetry: () => ref.invalidate(terminalsProvider),
      skeleton: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 4; i++) ...[
            _TerminalCard(terminal: TerminalModel.placeholder(i)),
            const SizedBox(height: 12),
          ],
        ],
      ),
      builder: (terminals) {
        if (terminals.isEmpty) {
          return RefreshableView(
            onRefresh: refresh,
            child: EmptyView(
              icon: Icons.memory_rounded,
              message: t.terminalsEmpty,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: terminals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _TerminalCard(terminal: terminals[index]),
          ),
        );
      },
    );
  }
}

class _TerminalCard extends ConsumerWidget {
  const _TerminalCard({required this.terminal});

  final TerminalModel terminal;

  Future<void> _remove(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppAlerts.confirm(
      context,
      title: t.removeTerminalTitle,
      message: t.removeTerminalMessage,
      confirmText: t.menuRemoveTerminal,
      cancelText: t.cancel,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await AppAlerts.progress(
        context,
        () => container.read(terminalServiceProvider).delete(terminal.id),
      );
      refreshOperationalData(container.invalidate);
      if (context.mounted) AppAlerts.success(context, t.terminalRemoved);
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, t.actionErrorMessage(error));
      }
    }
  }

  String _statusLabel(AppLocalizations t) {
    switch (terminal.status) {
      case TerminalStatus.assigned:
        return t.terminalStatusAssigned;
      case TerminalStatus.changeRequested:
        return t.terminalStatusChange;
      default:
        return t.terminalStatusUnassigned;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lastSeen = terminal.lastSeenAt;
    final statusColor = switch (terminal.status) {
      TerminalStatus.assigned => scheme.primary,
      TerminalStatus.changeRequested => scheme.tertiary,
      _ => scheme.outline,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: const Icon(Icons.memory_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terminal.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    terminal.locationName ?? t.terminalNoPoint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (terminal.device != null)
                    Text(
                      terminal.device!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      TagChip(label: _statusLabel(t), color: statusColor),
                      TagChip(
                        label: terminal.online
                            ? t.terminalOnline
                            : t.terminalOffline,
                        color: terminal.online ? Colors.green : scheme.outline,
                        icon: Icons.circle,
                      ),
                    ],
                  ),
                  if (lastSeen != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      t.terminalLastSeen(
                        Formatters.dateTime(lastSeen.toLocal(), t.localeName),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Skeleton.ignore(
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (_) => _remove(context),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 20),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            t.menuRemoveTerminal,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón flotante del administrador para agregar una terminal.
class NewTerminalButton extends ConsumerWidget {
  const NewTerminalButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () async {
        final result = await context.push<TerminalAssignResultModel>(
          AppRoutes.terminalAssign,
        );
        if (result == null || !context.mounted) return;
        final codes = result.containersCreated.join(', ');
        AppAlerts.success(
          context,
          codes.isEmpty
              ? t.terminalAssigned(result.terminal.label, result.locationName)
              : t.terminalAssignedWithContainers(
                  result.terminal.label,
                  result.locationName,
                  codes,
                ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: Text(t.titleAssignTerminal),
    );
  }
}
