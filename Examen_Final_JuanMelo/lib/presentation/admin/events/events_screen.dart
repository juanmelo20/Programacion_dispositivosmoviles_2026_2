import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/event_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/events_provider.dart';

/// Bitácora del sistema (solo administrador): filtro por nivel, búsqueda y
/// carga por páginas al hacer scroll.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _level;

  EventsQuery get _filter => (level: _level, query: _query);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final filter = _filter;
    final value = ref.watch(eventsProvider(filter));
    // Nombres legibles de los tipos; si fallan se muestra el código.
    final types = ref.watch(eventTypesProvider).value ?? const {};
    Future<void> refresh() => ref.refresh(eventsProvider(filter).future);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.searchEvents,
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
              for (final level in [null, ...EventLevel.all])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      level == null ? t.allLabel : t.eventLevelName(level),
                    ),
                    selected: _level == level,
                    onSelected: (_) => setState(() => _level = level),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<EventsState>(
            value: value,
            onRetry: () => ref.invalidate(eventsProvider(filter)),
            skeleton: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 7; i++)
                  _EventTile(event: EventModel.placeholder(i), types: types),
              ],
            ),
            builder: (state) {
              if (state.items.isEmpty) {
                return RefreshableView(
                  onRefresh: refresh,
                  child: EmptyView(
                    icon: Icons.receipt_long_outlined,
                    message: t.eventsEmpty,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: refresh,
                child: NotificationListener<ScrollNotification>(
                  // Al acercarse al final se pide la siguiente página.
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 400) {
                      ref.read(eventsProvider(filter).notifier).loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: state.items.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${t.eventsTotal(state.total)} · '
                            '${t.ofLabel(state.items.length, state.total)}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        );
                      }
                      if (index == state.items.length + 1) {
                        return _ListFooter(
                          state: state,
                          onRetry: () => ref
                              .read(eventsProvider(filter).notifier)
                              .loadMore(),
                        );
                      }
                      return _EventTile(
                        event: state.items[index - 1],
                        types: types,
                      );
                    },
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

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final EventsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = state.loadMoreError;
    if (error != null) {
      return ErrorView.compact(
        message: t.errorMessage(
          error is ApiException ? error.type : ApiErrorType.unknown,
        ),
        onRetry: onRetry,
      );
    }
    return const SizedBox(height: 24);
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.types});

  final EventModel event;
  final Map<String, String> types;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final (IconData icon, Color color) = switch (event.level) {
      EventLevel.error => (
        Icons.error_outline_rounded,
        dark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
      ),
      EventLevel.warning => (
        Icons.warning_amber_rounded,
        dark ? const Color(0xFFFFD54F) : const Color(0xFFE08B00),
      ),
      _ => (Icons.info_outline_rounded, scheme.primary),
    };
    final details = [
      Formatters.dateTime(event.createdAt, t.localeName),
      if (event.userName != null) event.userName!,
      if (event.containerCode != null) event.containerCode!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.eventTypeName(
                              event.eventType,
                              fallback: types[event.eventType],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          t.eventLevelName(event.level),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(event.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      details,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
