import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/domain/load_band.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/mental_load/presentation/backpack_painter.dart';

/// Animated backpack visualization that reflects the current Mental Load band.
///
/// Watches [mentalLoadProvider] and smoothly animates between the four
/// heaviness bands (léger → modéré → lourd → très lourd) as `totalKg`
/// crosses the 20/50/80 kg thresholds.
///
/// - Loading/error states: silent fixed-size placeholder (no blocking spinner).
/// - Reduce Motion: band change is immediate with no animation.
/// - Tap: invokes [onTap] (e.g. scroll the parent to the item list).
class BackpackWidget extends ConsumerStatefulWidget {
  const BackpackWidget({super.key, this.onTap});

  /// Called when the user taps the backpack. Typically scrolls to the item list.
  final VoidCallback? onTap;

  @override
  ConsumerState<BackpackWidget> createState() => _BackpackWidgetState();
}

class _BackpackWidgetState extends ConsumerState<BackpackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _bandAnimation;
  double _targetBandValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bandAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToBand(double newBandValue, {required bool reduceMotion}) {
    if (_targetBandValue == newBandValue) return;
    _targetBandValue = newBandValue;
    final current = _bandAnimation.value;
    if (reduceMotion) {
      _controller.stop();
      _bandAnimation = AlwaysStoppedAnimation(newBandValue);
      setState(() {});
      return;
    }
    _bandAnimation = Tween<double>(begin: current, end: newBandValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.reset();
    unawaited(_controller.forward());
  }

  String _bandName(LoadBand band, AppLocalizations l10n) => switch (band) {
    LoadBand.leger => l10n.loadBandLeger,
    LoadBand.modere => l10n.loadBandModere,
    LoadBand.lourd => l10n.loadBandLourd,
    LoadBand.tresLourd => l10n.loadBandTresLourd,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadAsync = ref.watch(mentalLoadProvider);

    return loadAsync.when(
      loading: () => const _BackpackPlaceholder(),
      error: (_, _) => const _BackpackPlaceholder(),
      data: (load) => _buildAnimated(context, load, l10n),
    );
  }

  Widget _buildAnimated(
    BuildContext context,
    MentalLoadProjection load,
    AppLocalizations l10n,
  ) {
    final band = LoadBand.fromKg(load.totalKg);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Schedule animation update post-frame to avoid setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animateToBand(band.animationValue, reduceMotion: reduceMotion);
      }
    });

    return Semantics(
      label: l10n.backpackSemanticLabel(_bandName(band, l10n)),
      button: true,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _bandAnimation,
          builder: (context, _) => SizedBox(
            height: 180,
            width: 180,
            child: CustomPaint(
              painter: BackpackPainter(
                bandValue: _bandAnimation.value,
                warmColor: AuroreColors.warm,
                glowColor: AuroreColors.warm.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixed-size placeholder shown during loading and error states.
///
/// Matches the backpack's 180×180 footprint so the layout does not shift.
class _BackpackPlaceholder extends StatelessWidget {
  const _BackpackPlaceholder();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 180, width: 180);
}
