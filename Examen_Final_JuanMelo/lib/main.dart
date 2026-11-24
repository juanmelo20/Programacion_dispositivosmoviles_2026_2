import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:parcial_2/config/router/router_config.dart';
import 'package:parcial_2/config/theme/app_theme.dart';
import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/language_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';
import 'package:parcial_2/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Abre la base de datos local (SQLite) antes de arrancar, como en el
  // ejemplo de clase. En Chrome no hay SQLite: la app usa solo la API.
  if (DatabaseHelper.isSupported) {
    try {
      await DatabaseHelper().database;
    } catch (_) {
      // Si falla, la app sigue funcionando con la API.
    }
  }
  runApp(
    ProviderScope(
      // Si una consulta falla, no se reintenta sola: la pantalla muestra el
      // error controlado y el botón "Reintentar".
      retry: (retryCount, error) => null,
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final AppLifecycleListener _lifecycleListener; 

  @override
  void initState() {
    super.initState();
    // Cada vez que la app vuelve a primer plano se revisa si el token sigue
    // vigente. Si venció, el guard manda al login.
    // También se envían los cambios hechos sin conexión.
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        ref.read(authProvider.notifier).verifySession();
        ref.read(syncProvider.notifier).sync();
      },
    );
    // Arranca la sincronización: escucha cuando el celular recupera la red.
    ref.read(syncProvider.notifier);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // El widget principal de la app, que contiene el router y el tema.
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de "debug" en la esquina superior derecha.
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // Cambia entre modo claro y oscuro según el valor de isDark.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // El esqueleto toma los colores del tema activo (claro u oscuro).
      builder: (context, child) => SkeletonizerConfig(
        data: SkeletonizerConfigData( 
          brightness: Theme.of(context).brightness,
          enableSwitchAnimation: true, 
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
