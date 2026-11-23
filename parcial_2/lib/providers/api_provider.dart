import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/dio_client.dart';
import 'package:parcial_2/helpers/session_events.dart';
import 'package:parcial_2/helpers/token.dart';
import 'package:parcial_2/services/admin/collection/collection_service.dart';
import 'package:parcial_2/services/admin/container/container_service.dart';
import 'package:parcial_2/services/admin/event/event_service.dart';
import 'package:parcial_2/services/admin/location/location_service.dart';
import 'package:parcial_2/services/admin/profile/profile_service.dart';
import 'package:parcial_2/services/admin/report/report_service.dart';
import 'package:parcial_2/services/admin/terminal/terminal_service.dart';
import 'package:parcial_2/services/admin/user/user_service.dart';
import 'package:parcial_2/services/auth/auth_service.dart';

/// Almacenamiento seguro del token.
final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(),
);

/// Avisos de la sesión .
final Provider<SessionEvents> sessionEventsProvider = Provider<SessionEvents>((
  ref,
) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create(
    tokenStorage: ref.watch(tokenStorageProvider),
    onUnauthorized: ref.watch(sessionEventsProvider).notifyUnauthorized,
  );
  ref.onDispose(dio.close);
  return dio;
});

/// Servicio de autenticación.
final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider), ref.watch(tokenStorageProvider));
});

// Servicios de cada módulo. Todos usan el mismo Dio (con su interceptor).
final containerServiceProvider = Provider<ContainerService>(
  (ref) => ContainerService(ref.watch(dioProvider)),
);

final collectionServiceProvider = Provider<CollectionService>(
  (ref) => CollectionService(ref.watch(dioProvider)),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.watch(dioProvider)),
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(ref.watch(dioProvider)),
);

final terminalServiceProvider = Provider<TerminalService>(
  (ref) => TerminalService(ref.watch(dioProvider)),
);

final userServiceProvider = Provider<UserService>(
  (ref) => UserService(ref.watch(dioProvider)),
);

final eventServiceProvider = Provider<EventService>(
  (ref) => EventService(ref.watch(dioProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(dioProvider)),
);
