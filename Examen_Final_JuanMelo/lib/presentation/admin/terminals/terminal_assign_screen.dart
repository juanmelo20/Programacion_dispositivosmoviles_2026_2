import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/model/admin/terminal_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/form_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/page_helpers.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';

enum _Destination { existing, created }

/// Agregar una terminal: se escribe el código que muestra su pantalla, se
/// confirma cuál es y se asigna a un punto ecológico (existente o nuevo).
///
/// Los contenedores no se crean a mano: el servidor los crea al asignar la
/// terminal a un punto (uno por categoría).
class TerminalAssignScreen extends ConsumerStatefulWidget {
  const TerminalAssignScreen({super.key});

  @override
  ConsumerState<TerminalAssignScreen> createState() =>
      _TerminalAssignScreenState();
}

class _TerminalAssignScreenState extends ConsumerState<TerminalAssignScreen> {
  final _codeKey = GlobalKey<FormState>();
  final _pointKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _zone = TextEditingController();
  final _description = TextEditingController();

  TerminalLookupModel? _found;
  _Destination _destination = _Destination.existing;
  int? _pointId;
  bool _searching = false;
  bool _assigning = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _zone.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Mensaje de un error; un código inválido o vencido llega como 404.
  String _message(AppLocalizations t, Object error) {
    if (error is ApiException && error.type == ApiErrorType.notFound) {
      return t.terminalCodeNotFound;
    }
    return t.actionErrorMessage(error);
  }

  Future<void> _search() async {
    final t = AppLocalizations.of(context)!;
    if (!(_codeKey.currentState?.validate() ?? false)) return;
    setState(() {
      _searching = true;
      _found = null;
    });
    try {
      final found = await ref
          .read(terminalServiceProvider)
          .lookup(_code.text.trim());
      if (mounted) setState(() => _found = found);
    } catch (error) {
      if (mounted) AppAlerts.error(context, _message(t, error));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _assign() async {
    final t = AppLocalizations.of(context)!;
    final creating = _destination == _Destination.created;
    if (creating) {
      if (!validateForm(
        context,
        _pointKey,
        missingRequired: _name.text.trim().isEmpty,
      )) {
        return;
      }
    } else if (_pointId == null) {
      AppAlerts.warning(context, t.terminalPickPoint);
      return;
    }

    setState(() => _assigning = true);
    try {
      final result = await ref
          .read(terminalServiceProvider)
          .assign(
            code: _code.text.trim(),
            locationId: creating ? null : _pointId,
            newPointName: creating ? _name.text.trim() : null,
            newPointZone: creating ? _zone.text : null,
            newPointDescription: creating ? _description.text : null,
          );
      if (!mounted) return;
      // Se actualizan terminales, puntos y contenedores (hay nuevos).
      refreshOperationalData(ref.invalidate);
      closePage<TerminalAssignResultModel>(
        context,
        fallback: AppRoutes.terminals,
        result: result,
      );
    } catch (error) {
      if (mounted) AppAlerts.error(context, _message(t, error));
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final found = _found;

    return Scaffold(
      appBar: AppBar(
        leading: pageBackButton(context, AppRoutes.terminals),
        title: Text(t.titleAssignTerminal),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _codeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.terminalCodeHelp, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: t.fieldTerminalCode,
                    prefixIcon: const Icon(Icons.pin_outlined),
                  ),
                  // Si se cambia el código, hay que buscar otra vez.
                  onChanged: (_) {
                    if (_found != null) setState(() => _found = null);
                  },
                  onFieldSubmitted: (_) => _search(),
                  validator: (value) =>
                      RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : t.terminalCodeInvalid,
                ),
                const SizedBox(height: 4),
                FilledButton.tonalIcon(
                  onPressed: _searching || _assigning ? null : _search,
                  icon: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(t.terminalFind),
                ),
              ],
            ),
          ),
          if (found != null) ...[
            const SizedBox(height: 20),
            _foundCard(t, theme, found),
            const SizedBox(height: 20),
            _destinationSection(t, theme),
          ],
        ],
      ),
    );
  }

  Widget _foundCard(
    AppLocalizations t,
    ThemeData theme,
    TerminalLookupModel found,
  ) {
    final scheme = theme.colorScheme;
    final terminal = found.terminal;
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.memory_rounded, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.terminalFound}: ${terminal.label}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  if (terminal.device != null)
                    Text(
                      terminal.device!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  if (found.isChange)
                    Text(
                      t.terminalAlreadyAt(terminal.locationName ?? ''),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destinationSection(AppLocalizations t, ThemeData theme) {
    final creating = _destination == _Destination.created;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.terminalWhere,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<_Destination>(
          segments: [
            ButtonSegment(
              value: _Destination.existing,
              icon: const Icon(Icons.place_outlined),
              label: Text(t.terminalExistingPoint),
            ),
            ButtonSegment(
              value: _Destination.created,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(t.terminalNewPoint),
            ),
          ],
          selected: {_destination},
          onSelectionChanged: (selection) =>
              setState(() => _destination = selection.first),
        ),
        const SizedBox(height: 16),
        if (creating) _newPointForm(t, theme) else _existingPoint(t, theme),
        const SizedBox(height: 20),
        SaveButton(
          saving: _assigning,
          onPressed: _assign,
          label: t.terminalAssign,
          icon: Icons.link_rounded,
        ),
      ],
    );
  }

  Widget _existingPoint(AppLocalizations t, ThemeData theme) {
    final points = ref.watch(locationsProvider(false));
    return points.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(t.actionErrorMessage(error)),
      data: (items) {
        // Solo los puntos que ya existen en el servidor.
        final available = items.where((p) => p.isAvailable).toList();
        if (available.isEmpty) {
          return Text(t.terminalNoPoints, style: theme.textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _pointId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: t.fieldEcoPoint,
                prefixIcon: const Icon(Icons.place_outlined),
              ),
              items: [
                for (final LocationModel point in available)
                  DropdownMenuItem(
                    value: point.id,
                    child: Text(
                      point.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _pointId = value),
            ),
            const SizedBox(height: 8),
            Text(
              t.terminalExistingHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _newPointForm(AppLocalizations t, ThemeData theme) {
    return Form(
      key: _pointKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: t.fieldName),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return t.fieldRequired;
              return Validators.isValidName(text) ? null : t.invalidName;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _zone,
            maxLength: 100,
            decoration: InputDecoration(labelText: t.fieldZone),
            validator: (value) =>
                (value?.trim().length ?? 0) > 100 ? t.invalidZone : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _description,
            maxLength: 255,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: t.fieldDescription),
            validator: (value) =>
                (value?.trim().length ?? 0) > 255 ? t.invalidDescription : null,
          ),
          const SizedBox(height: 4),
          Text(
            t.terminalNewPointHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
