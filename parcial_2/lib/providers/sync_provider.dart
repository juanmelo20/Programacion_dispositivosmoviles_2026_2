import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/model/local/pending_change_model.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/repository/ecopunto_repository.dart';
import 'package:parcial_2/repository/pendiente_repository.dart';
import 'package:parcial_2/repository/ruta_repository.dart';
import 'package:parcial_2/services/offline/eco_points_offline_service.dart';

// Repositorios de SQLite (uno por tabla, como en el ejemplo de clase).
final ecoPuntoRepositoryProvider = Provider((ref) => EcoPuntoRepository());
final pendienteRepositoryProvider = Provider((ref) => PendienteRepository());
final rutaRepositoryProvider = Provider((ref) => RutaRepository());

/// Avisa cuando el celular gana o pierde red (wifi, datos, modo avión).
class ConnectivitySource {
  Stream<List<ConnectivityResult>> get changes =>
      Connectivity().onConnectivityChanged;

  Future<List<ConnectivityResult>> check() =>
      Connectivity().checkConnectivity();

  static bool isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);
}

final connectivitySourceProvider = Provider((ref) => ConnectivitySource());

/// Puntos ecológicos con almacenamiento local y sincronización.
final ecoPointsOfflineServiceProvider = Provider<EcoPointsOfflineService>((
  ref,
) {
  return EcoPointsOfflineService(
    api: ref.watch(locationServiceProvider),
    ecopuntos: ref.watch(ecoPuntoRepositoryProvider),
    pendientes: ref.watch(pendienteRepositoryProvider),
    userId: ref.watch(currentUserIdProvider),
    status: ref.read(syncProvider.notifier),
  );
});

/// Estado que muestra la barra de sincronización.
class SyncState {
  const SyncState({
    this.deviceOffline = false,
    this.apiUnreachable = false,
    this.pending = 0,
    this.failed = 0,
    this.syncing = false,
    this.lastDownload,
    this.lastSent = 0,
    this.lastSyncAt,
  });

  /// El celular no tiene red (modo avión, sin wifi ni datos).
  final bool deviceOffline;

  /// Hay red, pero la API no respondió (servidor o túnel apagado).
  final bool apiUnreachable;

  /// Cambios guardados en el celular esperando para enviarse.
  final int pending;

  /// Cambios que la API rechazó al sincronizar.
  final int failed;
  final bool syncing;

  /// Cuándo se descargaron por última vez los datos de la API.
  final DateTime? lastDownload;

  /// Cuántos cambios se enviaron en la última sincronización y cuándo.
  final int lastSent;
  final DateTime? lastSyncAt;

  bool get offline => deviceOffline || apiUnreachable;

  SyncState copyWith({
    bool? deviceOffline,
    bool? apiUnreachable,
    int? pending,
    int? failed,
    bool? syncing,
    DateTime? lastDownload,
    int? lastSent,
    DateTime? lastSyncAt,
  }) {
    return SyncState(
      deviceOffline: deviceOffline ?? this.deviceOffline,
      apiUnreachable: apiUnreachable ?? this.apiUnreachable,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
      syncing: syncing ?? this.syncing,
      lastDownload: lastDownload ?? this.lastDownload,
      lastSent: lastSent ?? this.lastSent,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

/// Sincronización de los cambios hechos sin conexión.
///
/// Se sincroniza:
/// 1. Cuando el celular recupera la red (connectivity_plus).
/// 2. Al iniciar sesión y al volver a abrir la app.
/// 3. Cuando una consulta a la API funciona y quedaban cambios pendientes.
/// 4. Con el botón "Sincronizar".
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final notifier = SyncNotifier(ref);

  ref.listen<int?>(currentUserIdProvider, (_, userId) {
    notifier.onUserChanged(userId);
  });

  final source = ref.read(connectivitySourceProvider);
  StreamSubscription<List<ConnectivityResult>>? subscription;
  try {
    subscription = source.changes.listen(
      notifier.onConnectivityChanged,
      onError: (_) {},
    );
    source.check().then(notifier.onConnectivityChanged, onError: (_) {});
  } catch (_) {
    // Plataforma sin soporte: se asume que hay red.
  }
  ref.onDispose(() => subscription?.cancel());

  return notifier;
});

class SyncNotifier extends StateNotifier<SyncState> implements SyncStatusSink {
  SyncNotifier(this._ref) : super(const SyncState());

  final Ref _ref;
  Timer? _retry;

  /// Candado: mientras es true ya hay una sincronización en curso. Se activa
  /// antes de cualquier `await` para que dos pedidos seguidos (el botón y el
  /// regreso a la app, por ejemplo) no envíen dos veces lo mismo.
  bool _running = false;

  bool get _enabled =>
      DatabaseHelper.isSupported && _ref.read(currentUserIdProvider) != null;

  @override
  bool get isDeviceOffline => state.deviceOffline;

  @override
  void reportOnline() {
    if (mounted && state.apiUnreachable) {
      state = state.copyWith(apiUnreachable: false);
    }
  }

  @override
  void reportOffline() {
    if (mounted && !state.apiUnreachable) {
      state = state.copyWith(apiUnreachable: true);
    }
  }

  @override
  void localChangesUpdated() {
    refreshCounts();
    // Si hay conexión, se envía enseguida.
    scheduleSync(const Duration(milliseconds: 300));
  }

  void onConnectivityChanged(List<ConnectivityResult> results) {
    if (!mounted) return;
    final offline = ConnectivitySource.isOffline(results);
    final wasOffline = state.deviceOffline;
    state = state.copyWith(deviceOffline: offline);
    if (wasOffline && !offline) {
      // Volvió la red: se espera un momento a que la conexión se estabilice,
      // se verifica el token con el servidor (por si se entró sin conexión),
      // se actualizan los datos y se envían los pendientes.
      state = state.copyWith(apiUnreachable: false);
      scheduleSync(
        const Duration(seconds: 2),
        refreshData: true,
        verifySession: true,
      );
    }
  }

  void onUserChanged(int? userId) {
    // El aviso puede llegar mientras Flutter dibuja la pantalla, y Riverpod no
    // deja cambiar un provider en ese momento: se hace justo después.
    Future.microtask(() {
      if (!mounted) return;
      _retry?.cancel();
      state = SyncState(deviceOffline: state.deviceOffline);
      if (userId != null) {
        refreshCounts();
        scheduleSync(const Duration(seconds: 1));
      }
    });
  }

  void scheduleSync(
    Duration delay, {
    bool refreshData = false,
    bool verifySession = false,
  }) {
    _retry?.cancel();
    _retry = Timer(delay, () {
      if (verifySession) _ref.read(authProvider.notifier).verifySession();
      if (refreshData) refreshOperationalData(_ref.invalidate);
      sync();
    });
  }

  /// Actualiza los contadores de la barra (pendientes, errores, fecha).
  Future<void> refreshCounts() async {
    if (!_enabled) return;
    final userId = _ref.read(currentUserIdProvider)!;
    final List<PendingChangeModel> changes;
    final DateTime? lastDownload;
    try {
      changes = await _ref
          .read(pendienteRepositoryProvider)
          .obtenerDelUsuario(userId);
      lastDownload = await _ref
          .read(ecoPuntoRepositoryProvider)
          .obtenerFechaDescarga();
    } catch (_) {
      // Si falla la base local, la barra se queda como estaba.
      return;
    }
    if (!mounted) return;
    state = state.copyWith(
      pending: changes.where((c) => c.error == null).length,
      failed: changes.where((c) => c.error != null).length,
      lastDownload: lastDownload,
    );
  }

  /// Envía los cambios pendientes a la API.
  Future<void> sync() async {
    if (!_enabled || _running || !mounted) return;
    _running = true;
    try {
      await _sync();
    } finally {
      _running = false;
    }
  }

  Future<void> _sync() async {
    await refreshCounts();
    if (!mounted || state.pending == 0 || state.deviceOffline) return;

    state = state.copyWith(syncing: true);
    var summary = const SyncSummary();
    try {
      summary = await _ref.read(ecoPointsOfflineServiceProvider).sync();
    } catch (_) {
      // Error inesperado de la base local: se intenta en la próxima ocasión.
    } finally {
      if (mounted) state = state.copyWith(syncing: false);
    }
    if (!mounted) return;

    if (summary.sent > 0 || summary.failed > 0) {
      state = state.copyWith(
        lastSent: summary.sent,
        lastSyncAt: DateTime.now(),
      );
      // Los datos cambiaron en el servidor: se vuelven a pedir.
      refreshOperationalData(_ref.invalidate);
    }
    await refreshCounts();
    // Si se cortó por falta de conexión, se reintenta en unos segundos.
    if (summary.offline && mounted && !state.deviceOffline) {
      scheduleSync(const Duration(seconds: 10));
    }
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }
}
