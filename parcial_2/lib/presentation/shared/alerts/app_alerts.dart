import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AlertType { error, warning, success, info }

/// Alertas visuales de la app.
class AppAlerts {
  AppAlerts._();

  static void show(
    BuildContext context,
    String message, {
    AlertType type = AlertType.info,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (IconData icon, Color background, Color foreground) = switch (type) {
      AlertType.error => (
        Icons.error_outline_rounded,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      AlertType.warning => (
        Icons.warning_amber_rounded,
        isDark ? const Color(0xFF4D3B00) : const Color(0xFFFFF3CD),
        isDark ? const Color(0xFFFFE08A) : const Color(0xFF664D03),
      ),
      AlertType.success => (
        Icons.check_circle_outline_rounded,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      AlertType.info => (
        Icons.info_outline_rounded,
        scheme.inverseSurface,
        scheme.onInverseSurface,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, type: AlertType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: AlertType.warning);

  static void success(BuildContext context, String message) =>
      show(context, message, type: AlertType.success);

  /// Bloquea la pantalla con un indicador de carga mientras se ejecuta
  /// [task] (por ejemplo, guardar en la API) y devuelve su resultado. Si la
  /// tarea falla, el error sigue hacia el `catch` de quien la llamó.
  ///
  /// [status] y [fraction] permiten mostrar el avance de una tarea larga
  /// (ej. "Registrando 2 de 5…").
  static Future<T> progress<T>(
    BuildContext context,
    Future<T> Function() task, {
    String? message,
    ValueListenable<String>? status,
    ValueListenable<double?>? fraction,
  }) async {
    BuildContext? dialogContext;
    var done = false;
    var closed = false;

    void close() {
      final ctx = dialogContext;
      if (closed || ctx == null || !ctx.mounted) return;
      closed = true;
      final route = ModalRoute.of(ctx);
      final navigator = Navigator.of(ctx);
      if (route == null || route.isCurrent) {
        navigator.pop();
      } else {
        navigator.removeRoute(route);
      }
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          // Si la tarea terminó antes de dibujar el diálogo, se cierra ya.
          if (done) {
            WidgetsBinding.instance.addPostFrameCallback((_) => close());
          }
          return PopScope(
            canPop: false,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (fraction == null)
                          const CircularProgressIndicator()
                        else
                          ValueListenableBuilder<double?>(
                            valueListenable: fraction,
                            builder: (context, value, _) =>
                                LinearProgressIndicator(value: value),
                          ),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(message, textAlign: TextAlign.center),
                        ],
                        if (status != null) ...[
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String>(
                            valueListenable: status,
                            builder: (context, value, _) =>
                                Text(value, textAlign: TextAlign.center),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    try {
      return await task();
    } finally {
      done = true;
      close();
    }
  }

  /// Diálogo de confirmación. Devuelve true si el usuario acepta.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    IconData icon = Icons.help_outline_rounded,
    bool destructive = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
