import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';

/// A modal bottom sheet that lets the user edit or delete a [Preoccupation].
///
/// Opens via [showEditPreoccupationSheet].  On save:
///   - [BrainDumpRepository.updatePreoccupation] is called (offline-first).
///   - The projection revision is bumped immediately so the list rebuilds.
///   - If content changed, AI re-analysis is triggered fire-and-forget
///     (NFR-11: only if content differs — avoids redundant Groq calls).
///
/// On delete:
///   - Confirmation [AlertDialog] is shown (UX safety guardrail).
///   - [BrainDumpRepository.deletePreoccupation] is called on confirm.
///   - The projection revision is bumped immediately.
class EditPreoccupationSheet extends ConsumerStatefulWidget {
  /// Creates the edit sheet for [item].
  const EditPreoccupationSheet({super.key, required this.item});

  /// The preoccupation being edited or deleted.
  final Preoccupation item;

  @override
  ConsumerState<EditPreoccupationSheet> createState() =>
      _EditPreoccupationSheetState();
}

class _EditPreoccupationSheetState
    extends ConsumerState<EditPreoccupationSheet> {
  late final TextEditingController _controller;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.content);
    _canSave = widget.item.content.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canSave = _controller.text.trim().isNotEmpty;
    if (canSave != _canSave) setState(() => _canSave = canSave);
  }

  Future<void> _save() async {
    final newContent = _controller.text.trim();
    if (newContent.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final contentChanged = newContent != widget.item.content.trim();

    await ref
        .read(brainDumpRepositoryProvider)
        .updatePreoccupation(widget.item.id, newContent);

    ref.read(projectionRevisionProvider.notifier).bump();

    // Re-analyse asynchronously only when content actually changed (NFR-11).
    if (contentChanged) {
      unawaited(
        ref.read(analysisServiceProvider).analyzePreoccupation(
              id: widget.item.id,
              content: newContent,
            ),
      );
    }

    navigator.pop();
    if (!mounted) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.editSuccess)));
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteConfirmCta),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(brainDumpRepositoryProvider)
        .deletePreoccupation(widget.item.id);

    ref.read(projectionRevisionProvider.notifier).bump();

    navigator.pop();
    if (!mounted) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Lift sheet above keyboard.
      padding: EdgeInsets.only(
        left: AuroreSpacing.xl,
        right: AuroreSpacing.xl,
        top: AuroreSpacing.xl,
        bottom: AuroreSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editSheetTitle, style: textTheme.titleMedium),
          const SizedBox(height: AuroreSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _canSave ? _save() : null,
          ),
          const SizedBox(height: AuroreSpacing.lg),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(l10n.editSheetSaveButton),
          ),
          const SizedBox(height: AuroreSpacing.sm),
          OutlinedButton(
            onPressed: _confirmDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.editSheetDeleteButton),
          ),
        ],
      ),
    );
  }
}

/// Opens [EditPreoccupationSheet] as a modal bottom sheet for [item].
Future<void> showEditPreoccupationSheet(
  BuildContext context, {
  required Preoccupation item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => EditPreoccupationSheet(item: item),
  );
}
