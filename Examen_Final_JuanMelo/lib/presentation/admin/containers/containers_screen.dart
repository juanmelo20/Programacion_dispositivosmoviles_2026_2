import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_card.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/eco_point_picker.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Contenedores con pestañas por categoría.
class ContainersScreen extends ConsumerStatefulWidget {
  const ContainersScreen({super.key, this.locationId, this.locationName});

  /// Filtro inicial por punto ecológico (llega por la URL).
  final int? locationId;
  final String? locationName;

  @override
  ConsumerState<ContainersScreen> createState() => _ContainersScreenState();
}

class _ContainersScreenState extends ConsumerState<ContainersScreen> {
  /// Pestañas: todas y una por categoría (null = todas).
  static const List<String?> _categories = [null, ...WasteCategory.all];

  final _searchController = TextEditingController();
  Timer? _debounce;

  String _query = '';
  String? _status;
  int? _locationId;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _locationId = widget.locationId;
    _locationName = widget.locationName;
  }

  @override
  void didUpdateWidget(covariant ContainersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locationId != oldWidget.locationId) {
      _locationId = widget.locationId;
      _locationName = widget.locationName;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Espera a que el usuario deje de escribir para no consultar por cada
  /// letra.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _pickEcoPoint() async {
    final choice = await showEcoPointPicker(context, selectedId: _locationId);
    if (choice == null || !mounted) return;
    final point = choice.point;
    if (point == null) {
      _clearEcoPoint();
    } else {
      context.go(AppRoutes.containersAt(point.id, point.displayName));
    }
  }

  void _clearEcoPoint() {
    setState(() {
      _locationId = null;
      _locationName = null;
    });
    // Se limpia también la URL (?punto=...).
    if (widget.locationId != null) context.go(AppRoutes.containers);
  }

  ContainersQuery _queryFor(String? category) => (
    category: category,
    status: _status,
    query: _query,
    locationId: _locationId,
    includeInactive: false,
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _categories.length,
      child: Column(
        children: [
          Material(
            color: scheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: t.allLabel),
                Tab(text: t.categoryRecyclable),
                Tab(text: t.categoryOrganicShort),
                Tab(text: t.categoryNonRecyclable),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: t.searchContainers,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _searchController,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: t.clearFilter,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clearSearch,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _statusChip(null, t.allLabel),
                _statusChip(FillStatus.normal, t.statusNormal),
                _statusChip(FillStatus.attention, t.statusAttention),
                _statusChip(FillStatus.full, t.statusFull),
                const SizedBox(width: 8),
                if (_locationId != null)
                  InputChip(
                    avatar: const Icon(Icons.place_rounded, size: 18),
                    label: Text(t.ecoPointFilter(_locationName ?? '')),
                    selected: true,
                    onPressed: _pickEcoPoint,
                    onDeleted: _clearEcoPoint,
                    deleteButtonTooltipMessage: t.clearFilter,
                  )
                else
                  ActionChip(
                    avatar: const Icon(Icons.place_outlined, size: 18),
                    label: Text(t.fieldEcoPoint),
                    onPressed: _pickEcoPoint,
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final category in _categories)
                  _ContainerList(query: _queryFor(category)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String? status, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _status == status,
        onSelected: (_) => setState(() => _status = status),
      ),
    );
  }
}

class _ContainerList extends ConsumerWidget {
  const _ContainerList({required this.query});

  final ContainersQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(containersProvider(query));
    Future<void> refresh() => ref.refresh(containersProvider(query).future);

    return AsyncView<List<ContainerModel>>(
      value: value,
      onRetry: () => ref.invalidate(containersProvider(query)),
      skeleton: const ContainerListSkeleton(),
      builder: (items) {
        if (items.isEmpty) {
          return RefreshableView(
            onRefresh: refresh,
            child: EmptyView(
              icon: Icons.search_off_rounded,
              message: t.containersEmpty,
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
            itemBuilder: (_, index) => ContainerCard(container: items[index]),
          ),
        );
      },
    );
  }
}
