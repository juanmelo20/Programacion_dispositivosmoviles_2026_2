import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/model/admin/event_model.dart';
import 'package:parcial_2/providers/api_provider.dart';

/// Filtros de la bitácora.
typedef EventsQuery = ({String? level, String query});

/// Estado de la bitácora paginada: eventos cargados y si faltan más.
class EventsState {
  const EventsState({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<EventModel> items;
  final int total;
  final int page;
  final bool loadingMore;

  /// Error al pedir la siguiente página (la lista ya cargada se conserva).
  final Object? loadMoreError;

  bool get hasMore => items.length < total;

  EventsState copyWith({
    List<EventModel>? items,
    int? total,
    int? page,
    bool? loadingMore,
    Object? loadMoreError,
    bool clearError = false,
  }) {
    return EventsState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreError: clearError ? null : loadMoreError ?? this.loadMoreError,
    );
  }
}

/// Bitácora con "scroll infinito": la primera página se carga con esqueleto
/// y las siguientes se piden al llegar al final de la lista.
final eventsProvider = AsyncNotifierProvider.autoDispose
    .family<EventsNotifier, EventsState, EventsQuery>(EventsNotifier.new);

class EventsNotifier extends AsyncNotifier<EventsState> {
  EventsNotifier(this.filter);

  final EventsQuery filter;

  static const int pageSize = 25;

  @override
  Future<EventsState> build() async {
    final page = await ref
        .watch(eventServiceProvider)
        .list(
          page: 1,
          pageSize: pageSize,
          level: filter.level,
          query: filter.query,
        );
    return EventsState(items: page.items, total: page.total, page: 1);
  }

  /// Pide la siguiente página y la agrega al final.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(loadingMore: true, clearError: true));
    try {
      final next = await ref
          .read(eventServiceProvider)
          .list(
            page: current.page + 1,
            pageSize: pageSize,
            level: filter.level,
            query: filter.query,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreError: error),
      );
    }
  }
}
