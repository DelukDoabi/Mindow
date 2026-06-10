import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/features/gamification/domain/level_state.dart';
import 'package:mindow/features/gamification/garden_providers.dart';

final levelStateProvider = Provider<LevelState>((ref) {
  final validatedEvents = ref.watch(missionValidatedEventsProvider);
  return levelStateFromMissionValidatedEvents(validatedEvents);
});
