import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/app/env.dart';
import 'package:mindow/core/design_system/aurore_theme.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/router/app_router.dart';

/// Root widget. Wires the Aurore theme, GoRouter, and generated localizations.
class MindowApp extends ConsumerWidget {
  const MindowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(envProvider).flavor;

    return MaterialApp.router(
      title: flavor.label,
      debugShowCheckedModeBanner: !flavor.isProduction,
      theme: AuroreTheme.light(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
