import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/features/onboarding/onboarding_answers.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mindow_onboarding_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('load returns empty answers when nothing is saved', () async {
    final repo = OnboardingRepository();

    expect(await repo.load(), const OnboardingAnswers());
  });

  test('save then load round-trips all selected values', () async {
    final repo = OnboardingRepository();
    const answers = OnboardingAnswers(
      ageRange: AgeRange.from35to44,
      familySituation: FamilySituation.withChildren,
      stressLevel: StressLevel.high,
      mindVolumeBucket: MindVolumeBucket.from20to50,
    );

    await repo.save(answers);

    expect(await repo.load(), answers);
  });

  test('save then load preserves partial (skipped) answers', () async {
    final repo = OnboardingRepository();
    const answers = OnboardingAnswers(
      mindVolumeBucket: MindVolumeBucket.upTo10,
    );

    await repo.save(answers);

    final loaded = await repo.load();
    expect(loaded.mindVolumeBucket, MindVolumeBucket.upTo10);
    expect(loaded.ageRange, isNull);
    expect(loaded.familySituation, isNull);
    expect(loaded.stressLevel, isNull);
  });

  test('isComplete is false until markComplete is called', () async {
    final repo = OnboardingRepository();

    expect(await repo.isComplete(), isFalse);

    await repo.markComplete();

    expect(await repo.isComplete(), isTrue);
  });

  test('isAiConsentGranted is false until consent is granted', () async {
    final repo = OnboardingRepository();

    expect(await repo.isAiConsentGranted(), isFalse);

    await repo.setAiConsent(granted: true);

    expect(await repo.isAiConsentGranted(), isTrue);
  });

  test('setAiConsent can revoke a previously granted consent', () async {
    final repo = OnboardingRepository();

    await repo.setAiConsent(granted: true);
    await repo.setAiConsent(granted: false);

    expect(await repo.isAiConsentGranted(), isFalse);
  });
}
