import 'package:flutter/material.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';

/// Ícono que representa cada perfil.
IconData roleIcon(UserRole role) {
  switch (role) {
    case UserRole.administrador:
      return Icons.admin_panel_settings_rounded;
    case UserRole.recolector:
      return Icons.local_shipping_rounded;
    case UserRole.interesado:
      return Icons.insights_rounded;
    case UserRole.desconocido:
      return Icons.person_off_rounded;
  }
}

/// Etiqueta con el perfil del usuario (Administrador, Recolector, Interesado).
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, this.inverted = false});

  final UserRole role;

  /// true = colores claros para ponerla sobre un fondo verde.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final background = inverted
        ? scheme.onPrimary.withValues(alpha: 0.2)
        : scheme.secondaryContainer;
    final foreground = inverted
        ? scheme.onPrimary
        : scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon(role), size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            t.roleName(role),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
