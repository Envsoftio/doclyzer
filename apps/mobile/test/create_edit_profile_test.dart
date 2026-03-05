import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/profiles/in_memory_profiles_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/profiles/screens/create_edit_profile_screen.dart';

Widget _wrapCreate(
  InMemoryProfilesRepository repo, {
  VoidCallback? onComplete,
  VoidCallback? onBack,
}) {
  return MaterialApp(
    home: CreateEditProfileScreen(
      profilesRepository: repo,
      onComplete: onComplete ?? () {},
      onBack: onBack ?? () {},
    ),
  );
}

Widget _wrapEdit(
  InMemoryProfilesRepository repo,
  Profile profile, {
  VoidCallback? onComplete,
  VoidCallback? onBack,
}) {
  return MaterialApp(
    home: CreateEditProfileScreen(
      profilesRepository: repo,
      existingProfile: profile,
      onComplete: onComplete ?? () {},
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  group('Create mode', () {
    testWidgets('renders empty form with Create Profile button',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      await tester.pumpWidget(_wrapCreate(repo));

      expect(find.byKey(const Key('profile-name-field')), findsOneWidget);
      expect(find.byKey(const Key('profile-dob-field')), findsOneWidget);
      expect(find.byKey(const Key('profile-relation-field')), findsOneWidget);
      expect(find.text('Create Profile'), findsWidgets);
    });

    testWidgets('submitting with empty name shows error',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      await tester.pumpWidget(_wrapCreate(repo));

      await tester.tap(find.byKey(const Key('profile-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-form-error')), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('submitting with valid name calls createProfile and onComplete',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      var completed = false;

      await tester.pumpWidget(
          _wrapCreate(repo, onComplete: () => completed = true));

      await tester.enterText(
          find.byKey(const Key('profile-name-field')), 'Vishnu');
      await tester.tap(find.byKey(const Key('profile-submit')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      final profiles = await repo.getProfiles();
      expect(profiles.length, equals(1));
      expect(profiles.first.name, equals('Vishnu'));
    });

    testWidgets('submitting with optional fields creates profile correctly',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();

      await tester.pumpWidget(_wrapCreate(repo));

      await tester.enterText(
          find.byKey(const Key('profile-name-field')), 'Amma');
      await tester.enterText(
          find.byKey(const Key('profile-dob-field')), '1960-05-15');
      await tester.enterText(
          find.byKey(const Key('profile-relation-field')), 'parent');
      await tester.tap(find.byKey(const Key('profile-submit')));
      await tester.pumpAndSettle();

      final profiles = await repo.getProfiles();
      expect(profiles.first.dateOfBirth, equals('1960-05-15'));
      expect(profiles.first.relation, equals('parent'));
    });

    testWidgets('tapping back calls onBack', (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      var called = false;

      await tester
          .pumpWidget(_wrapCreate(repo, onBack: () => called = true));

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('shows upgrade message when at profile limit', (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository(maxProfiles: 1);
      await repo.createProfile(name: 'Existing');

      await tester.pumpWidget(_wrapCreate(repo));

      await tester.enterText(find.byKey(const Key('profile-name-field')), 'Second');
      await tester.tap(find.byKey(const Key('profile-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-form-error')), findsOneWidget);
      expect(find.text('Free plan allows 1 profile. Upgrade to add more.'), findsOneWidget);
    });
  });

  group('Edit mode', () {
    testWidgets('renders form pre-filled with existing profile data',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      final profile = await repo.createProfile(
        name: 'Vishnu',
        relation: 'self',
      );

      await tester.pumpWidget(_wrapEdit(repo, profile));

      final nameField =
          tester.widget<TextField>(find.byKey(const Key('profile-name-field')));
      expect(nameField.controller!.text, equals('Vishnu'));

      final relationField = tester
          .widget<TextField>(find.byKey(const Key('profile-relation-field')));
      expect(relationField.controller!.text, equals('self'));
    });

    testWidgets('shows Update Profile button in edit mode',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      final profile = await repo.createProfile(name: 'Vishnu');

      await tester.pumpWidget(_wrapEdit(repo, profile));

      expect(find.text('Update Profile'), findsOneWidget);
    });

    testWidgets('submitting calls updateProfile and onComplete',
        (WidgetTester tester) async {
      final repo = InMemoryProfilesRepository();
      final profile = await repo.createProfile(name: 'Vishnu');
      var completed = false;

      await tester
          .pumpWidget(_wrapEdit(repo, profile, onComplete: () => completed = true));

      await tester.enterText(
          find.byKey(const Key('profile-name-field')), 'Vishnu Updated');
      await tester.tap(find.byKey(const Key('profile-submit')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      final profiles = await repo.getProfiles();
      expect(profiles.first.name, equals('Vishnu Updated'));
    });
  });
}
