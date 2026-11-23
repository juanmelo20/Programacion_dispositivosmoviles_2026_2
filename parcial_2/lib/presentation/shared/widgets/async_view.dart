import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';

/// Dibuja el estado de una consulta a la API:

class AsyncView<T> extends StatefulWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    required this.skeleton,
    this.onRetry,
    this.fill = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  /// La misma pantalla con datos de ejemplo; Skeletonizer la convierte en
  /// esqueleto mientras llegan los datos reales.
  final Widget skeleton;
  final VoidCallback? onRetry;

  final bool fill;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  static const Duration _slowAfter = Duration(seconds: 5);

  Timer? _slowTimer;
  bool _slow = false;

  bool get _waiting => widget.value.isLoading && !widget.value.hasValue;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  void _syncTimer() {
    if (_waiting) {
      _slowTimer ??= Timer(_slowAfter, () {
        if (mounted) setState(() => _slow = true);
      });
    } else {
      _slowTimer?.cancel();
      _slowTimer = null;
      _slow = false;
    }
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;

    if (_waiting) return _buildSkeleton(context);

    if (value.hasError && !value.isLoading) {
      final error = value.error;
      final type = error is ApiException ? error.type : ApiErrorType.unknown;
      final message = AppLocalizations.of(context)!.errorMessage(type);
      return widget.fill
          ? ErrorView(message: message, onRetry: widget.onRetry)
          : ErrorView.compact(message: message, onRetry: widget.onRetry);
    }

    if (value.hasValue) {
      final content = widget.builder(value.requireValue);
      if (!value.isLoading || !widget.fill) return content;
      return Stack(
        children: [
          Positioned.fill(child: content),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        ],
      );
    }

    return _buildSkeleton(context);
  }

  Widget _buildSkeleton(BuildContext context) {
    final skeleton = Skeletonizer(enabled: true, child: widget.skeleton);
    final banner = AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: _slow ? const SlowConnectionBanner() : const SizedBox.shrink(),
    );

    if (!widget.fill) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [banner, skeleton],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        Expanded(child: skeleton),
      ],
    );
  }
}

/// Aviso de conexión lenta que aparece sobre el esqueleto.
class SlowConnectionBanner extends StatelessWidget {
  const SlowConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.network_check_rounded,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.slowConnection,
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
