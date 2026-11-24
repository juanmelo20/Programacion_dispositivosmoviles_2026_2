import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/providers/language_provider.dart';
import 'package:parcial_2/providers/theme_provider.dart';

/// Botón para cambiar entre modo claro y modo oscuro.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final t = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: t.darkMode,
      color: color,
      onPressed: () => ref.read(themeProvider.notifier).toggle(),
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
    );
  }
}

/// Selector de idioma: ES / EN.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(languageProvider).languageCode;

    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: const [
        ButtonSegment(value: 'es', label: Text('ES')),
        ButtonSegment(value: 'en', label: Text('EN')),
      ],
      selected: {code},
      onSelectionChanged: (selection) =>
          ref.read(languageProvider.notifier).changeLanguage(selection.first),
    );
  }
}
