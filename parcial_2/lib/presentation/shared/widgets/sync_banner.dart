import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';

/// Barra de sincronización (arriba de los puntos ecológicos):
/// - Sin conexión: avisa que se ven los datos guardados en el celular.
/// - Con cambios pendientes: cuántos hay y el botón "Sincronizar".
/// - Con cambios rechazados por la API: cuántos son.
/// - Con red pero sin respuesta del servidor: el botón "Reintentar".
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!DatabaseHelper.isSupported) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;
    final sync = ref.watch(syncProvider);
    final visible = sync.offline || sync.pending > 0 || sync.failed > 0;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: !visible
          ? const SizedBox(width: double.infinity)
          : _Banner(sync: sync, t: t),
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.sync, required this.t});

  final SyncState sync;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final offline = sync.offline;
    final background = offline
        ? scheme.secondaryContainer
        : scheme.tertiaryContainer;
    final foreground = offline
        ? scheme.onSecondaryContainer
        : scheme.onTertiaryContainer;
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: foreground);
    final lastDownload = sync.lastDownload;

    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Icon(
            offline ? Icons.cloud_off_rounded : Icons.cloud_upload_outlined,
            color: foreground,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (offline) ...[
                  Text(
                    t.offlineBanner,
                    style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (lastDownload != null)
                    Text(
                      t.lastDownloadAt(
                        Formatters.dateTime(lastDownload, t.localeName),
                      ),
                      style: textStyle,
                    ),
                ],
                if (sync.pending > 0)
                  Text(
                    t.pendingChanges(sync.pending),
                    style: textStyle?.copyWith(
                      fontWeight: offline ? null : FontWeight.w600,
                    ),
                  ),
                if (sync.failed > 0)
                  Text(
                    t.failedChanges(sync.failed),
                    style: textStyle?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (sync.pending > 0)
            sync.syncing
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                        semanticsLabel: t.syncing,
                      ),
                    ),
                  )
                : TextButton(
                    style: TextButton.styleFrom(foregroundColor: foreground),
                    onPressed: sync.deviceOffline
                        ? null
                        : () => ref.read(syncProvider.notifier).sync(),
                    child: Text(t.syncNow),
                  )
          else if (sync.apiUnreachable && !sync.deviceOffline)
            // Hay red pero el servidor no respondía: se vuelve a consultar.
            TextButton(
              style: TextButton.styleFrom(foregroundColor: foreground),
              onPressed: () => refreshOperationalData(ref.invalidate),
              child: Text(t.retry),
            ),
        ],
      ),
    );
  }
}
