import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';

/// The Mental Backpack home: the single place a user sets a worry down.
///
/// The capture input is reachable in one tap (UX-DR12) and writes through the
/// offline-first sync engine: a submit appends a `preoccupation.captured` event
/// to the local outbox and the item appears immediately in pending state, with
/// no wait on the network or AI (NFR-1, NFR-3). The animated backpack and kg
/// figure land in later stories — here the list stays intentionally minimal.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
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
    final canSubmit = _controller.text.trim().isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await ref.read(brainDumpRepositoryProvider).capturePreoccupation(content);
    _controller.clear();
    ref.invalidate(openPreoccupationsProvider);

    if (!mounted) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.captureSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final preoccupations = ref.watch(openPreoccupationsProvider);

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.go(Routes.settings),
                  color: AuroreColors.inkMuted,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
              Text(
                l10n.homeWelcomeTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AuroreSpacing.lg),
              Expanded(
                child: preoccupations.when(
                  data: (items) => items.isEmpty
                      ? _EmptyBackpack(message: l10n.homeEmptyBackpack)
                      : _PreoccupationList(
                          items: items,
                          pendingLabel: l10n.capturePendingLabel,
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      _EmptyBackpack(message: l10n.homeEmptyBackpack),
                ),
              ),
              const SizedBox(height: AuroreSpacing.lg),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _canSubmit ? _submit() : null,
                decoration: InputDecoration(
                  hintText: l10n.captureInputPlaceholder,
                ),
              ),
              const SizedBox(height: AuroreSpacing.md),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: Text(l10n.captureSubmitButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The calm empty-state shown when the backpack holds nothing yet.
class _EmptyBackpack extends StatelessWidget {
  const _EmptyBackpack({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Text(
        message,
        style: textTheme.bodyLarge?.copyWith(color: AuroreColors.inkMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// A minimal list of captured Preoccupations, most recent first.
class _PreoccupationList extends StatelessWidget {
  const _PreoccupationList({required this.items, required this.pendingLabel});

  final List<Preoccupation> items;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AuroreSpacing.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AuroreColors.glass,
            borderRadius: BorderRadius.circular(AuroreRadii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AuroreSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(item.content, style: textTheme.bodyLarge),
                ),
                if (item.isPending) ...[
                  const SizedBox(width: AuroreSpacing.md),
                  Text(
                    pendingLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: AuroreColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
