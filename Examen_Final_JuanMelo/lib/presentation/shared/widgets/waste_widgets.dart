import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';

/// Colores de la app para categorías y estados de llenado.
///
/// Las categorías siguen el código de colores de canecas en Colombia:
/// blanca = aprovechable, verde = orgánico, negra = no aprovechable.
class WasteColors {
  WasteColors._();

  static Color categoryBackground(String category) {
    switch (category) {
      case WasteCategory.organic:
        return const Color(0xFF2E7D32);
      case WasteCategory.nonRecyclable:
        return const Color(0xFF263238);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color categoryForeground(String category) {
    switch (category) {
      case WasteCategory.organic:
      case WasteCategory.nonRecyclable:
        return Colors.white;
      default:
        return const Color(0xFF455A64);
    }
  }

  /// Color para gráficas por categoría (visible en modo claro y oscuro).
  static Color categoryChart(String category) {
    switch (category) {
      case WasteCategory.organic:
        return const Color(0xFF43A047);
      case WasteCategory.nonRecyclable:
        return const Color(0xFF78909C);
      default:
        return const Color(0xFF29B6F6);
    }
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case WasteCategory.organic:
        return Icons.eco_rounded;
      case WasteCategory.nonRecyclable:
        return Icons.delete_outline_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }

  static Color status(BuildContext context, String status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case FillStatus.full:
        return dark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);
      case FillStatus.attention:
        return dark ? const Color(0xFFFFD54F) : const Color(0xFFE08B00);
      default:
        return dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    }
  }
}

/// Círculo con el ícono y el color de la caneca de la categoría.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 44});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = WasteColors.categoryBackground(category);
    final dark = Theme.of(context).brightness == Brightness.dark;
    // La caneca blanca lleva borde en modo claro y la negra en modo oscuro,
    // para que no se pierdan contra el fondo.
    final Border? border = switch (category) {
      WasteCategory.recyclable when !dark => Border.all(
        color: const Color(0xFFB0BEC5),
        width: 1.5,
      ),
      WasteCategory.nonRecyclable when dark => Border.all(
        color: Colors.white24,
        width: 1.5,
      ),
      _ => null,
    };
    // En el esqueleto se ve como un círculo gris (sin revelar la categoría).
    return Skeleton.leaf(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Icon(
          WasteColors.categoryIcon(category),
          size: size * 0.55,
          color: WasteColors.categoryForeground(category),
        ),
      ),
    );
  }
}

/// Etiqueta con el estado de llenado (Normal, Requiere atención, Lleno).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.label});

  final String status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = WasteColors.status(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        t.fillStatusName(status, fallback: label),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Barra de llenado con su porcentaje.
class FillBar extends StatelessWidget {
  const FillBar({
    super.key,
    required this.percentage,
    required this.status,
    this.height = 8,
    this.showLabel = true,
  });

  final double percentage;
  final String status;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = WasteColors.status(context, status);
    final value = (percentage / 100).clamp(0.0, 1.0);

    // En el esqueleto la barra se cambia por un "hueso" del mismo tamaño.
    final bar = Skeleton.replace(
      height: height,
      replacement: Bone(
        width: double.infinity,
        height: height,
        uniRadius: height / 2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: value,
          minHeight: height,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
        ),
      ),
    );

    if (!showLabel) return bar;
    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          child: Text(
            Formatters.percent(percentage, t.localeName),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Medidor circular grande del llenado (detalle del contenedor).
class FillGauge extends StatelessWidget {
  const FillGauge({
    super.key,
    required this.percentage,
    required this.status,
    this.size = 120,
  });

  final double percentage;
  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = WasteColors.status(context, status);

    return Skeleton.replace(
      width: size,
      height: size,
      replacement: Bone.circle(size: size),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            strokeWidth: 12,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              Formatters.percent(percentage, t.localeName),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta pequeña de texto (Activo, Inactivo, Retirado, Tú...).
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = color ?? scheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tint),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: tint, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
