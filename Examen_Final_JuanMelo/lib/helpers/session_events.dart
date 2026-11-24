import 'dart:async';

class SessionEvents {
  final StreamController<void> _unauthorized =
      StreamController<void>.broadcast();

  /// Se emite cada vez que una ruta protegida responde 401.
  Stream<void> get unauthorized => _unauthorized.stream;

  void notifyUnauthorized() {
    if (!_unauthorized.isClosed) _unauthorized.add(null);
  }

  void dispose() => _unauthorized.close();
}
