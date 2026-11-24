import 'package:flutter/material.dart';

import 'package:parcial_2/l10n/app_localizations.dart';

/// Diálogo para confirmar una recolección con observaciones opcionales.
///
/// Devuelve el texto de las observaciones (puede ser vacío) si el usuario
/// confirma, o null si cancela.
Future<String?> showCollectionNotesDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CollectionNotesDialog(
      title: title,
      message: message,
      confirmText: confirmText,
    ),
  );
}

class _CollectionNotesDialog extends StatefulWidget {
  const _CollectionNotesDialog({
    required this.title,
    required this.message,
    required this.confirmText,
  });

  final String title;
  final String message;
  final String confirmText;

  @override
  State<_CollectionNotesDialog> createState() => _CollectionNotesDialogState();
}

class _CollectionNotesDialogState extends State<_CollectionNotesDialog> {
  static const int _maxNotes = 500;

  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_notes.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: const Icon(Icons.local_shipping_outlined),
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              minLines: 2,
              maxLength: _maxNotes,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: t.notesLabel),
              validator: (value) => (value?.trim().length ?? 0) > _maxNotes
                  ? t.notesTooLong
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(widget.confirmText)),
      ],
    );
  }
}
