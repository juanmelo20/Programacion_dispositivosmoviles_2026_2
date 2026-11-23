import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/app_logo.dart';
import 'package:parcial_2/providers/auth_provider.dart';

/// Primera pantalla: revisa si existe un token y si sigue vigente
/// (introspección con /auth/me). El guard del router decide luego si va al
/// login o a la zona privada.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final error = auth.sessionCheckError;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 96),
              const SizedBox(height: 24),
              Text(
                t.appTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.appSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: error == null
                    ? Column(
                        key: const ValueKey('checking'),
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(t.checkingSession),
                        ],
                      )
                    : Column(
                        key: const ValueKey('error'),
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.sessionCheckFailed,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.errorMessage(error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => ref
                                .read(authProvider.notifier)
                                .restoreSession(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(t.retry),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                ref.read(authProvider.notifier).logout(),
                            child: Text(t.goToLogin),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
