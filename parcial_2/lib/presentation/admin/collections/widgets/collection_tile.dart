import 'package:flutter/material.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/collection_model.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';

/// Recolección registrada: contenedor, quién la hizo, residuos y hora.
class CollectionTile extends StatelessWidget {
  const CollectionTile({
    super.key,
    required this.collection,
    this.showContainer = true,
  });

  final CollectionModel collection;

  /// false dentro del detalle del contenedor (ya se sabe cuál es).
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = t.localeName;
    final notes = collection.notes?.trim() ?? '';
    final collector = collection.collectorName;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showContainer)
              CategoryAvatar(category: collection.category, size: 40)
            else
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showContainer
                        ? '${collection.containerName} (${collection.containerCode})'
                        : Formatters.dateTime(collection.createdAt, locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (showContainer) collection.locationName,
                      if (collector != null && collector.isNotEmpty)
                        t.collectedBy(collector),
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 16,
                          color: scheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            notes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t.unitsCollected(collection.unitsCollected),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.fillAtCollection(
                    Formatters.percent(collection.fillPercentage, locale),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (showContainer) ...[
                  const SizedBox(height: 2),
                  Text(
                    Formatters.time(collection.createdAt, locale),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
