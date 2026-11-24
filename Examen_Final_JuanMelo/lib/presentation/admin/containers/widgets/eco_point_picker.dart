import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Resultado del selector: el punto elegido o "todos los puntos".
class EcoPointChoice {
  const EcoPointChoice(this.point);

  /// null = todos los puntos.
  final LocationModel? point;
}

/// Hoja inferior para filtrar por punto ecológico.
Future<EcoPointChoice?> showEcoPointPicker(
  BuildContext context, {
  int? selectedId,
}) {
  return showModalBottomSheet<EcoPointChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _EcoPointPicker(selectedId: selectedId),
  );
}

class _EcoPointPicker extends ConsumerWidget {
  const _EcoPointPicker({this.selectedId});

  final int? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final points = ref.watch(locationsProvider(false));

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              t.fieldEcoPoint,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: AsyncView<List<LocationModel>>(
              value: points,
              fill: false,
              onRetry: () => ref.invalidate(locationsProvider(false)),
              skeleton: Column(
                children: [
                  for (var i = 0; i < 4; i++)
                    _tile(context, LocationModel.placeholder(i), false),
                ],
              ),
              builder: (items) => ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.public_rounded),
                    title: Text(t.allEcoPoints),
                    selected: selectedId == null,
                    trailing: selectedId == null
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(const EcoPointChoice(null)),
                  ),
                  // Los creados o eliminados sin conexión no se ofrecen.
                  for (final point in items.where((p) => p.isAvailable))
                    _tile(context, point, point.id == selectedId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, LocationModel point, bool selected) {
    final t = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.place_outlined),
      title: Text(point.displayName),
      subtitle: Text(t.pointActiveContainers(point.activeContainerCount)),
      selected: selected,
      trailing: selected ? const Icon(Icons.check_rounded) : null,
      onTap: () => Navigator.of(context).pop(EcoPointChoice(point)),
    );
  }
}
