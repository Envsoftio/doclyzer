import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/profiles/in_memory_profiles_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/profiles/screens/profile_list_screen.dart';

Widget _wrap(
  ProfilesRepository repo, {
  VoidCallback? onCreateProfile,
  void Function(Profile)? onEditProfile,
  VoidCallback? onBack,
}) {
  return MaterialApp(
    home: ProfileListScreen(
      profilesRepository: repo,
      onCreateProfile: onCreateProfile ?? () {},
      onEditProfile: onEditProfile ?? (_) {},
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  testWidgets('renders empty state with Add Profile button',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-create-new')), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders profile list after create', (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-list-item-${profile.id}')), findsOneWidget);
  });

  testWidgets('active profile shows Active chip, inactive shows Set Active button',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository(maxProfiles: 2);
    final first = await repo.createProfile(name: 'Vishnu');
    final second = await repo.createProfile(name: 'Amma');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-active-chip-${first.id}')), findsOneWidget);
    expect(find.byKey(Key('profile-activate-${first.id}')), findsNothing);
    expect(find.byKey(Key('profile-activate-${second.id}')), findsOneWidget);
  });

  testWidgets('tapping Set Active activates that profile',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository(maxProfiles: 2);
    await repo.createProfile(name: 'Vishnu');
    final second = await repo.createProfile(name: 'Amma');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-activate-${second.id}')));
    await tester.pumpAndSettle();

    final profiles = await repo.getProfiles();
    final activatedSecond = profiles.firstWhere((p) => p.id == second.id);
    expect(activatedSecond.isActive, isTrue);

    expect(find.byKey(Key('profile-active-chip-${second.id}')), findsOneWidget);
  });

  testWidgets('tapping Add Profile calls onCreateProfile',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    var called = false;

    await tester.pumpWidget(_wrap(repo, onCreateProfile: () => called = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-create-new')));
    await tester.pumpAndSettle();

    expect(called, isTrue);
  });

  testWidgets('tapping edit button calls onEditProfile with the profile',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');
    Profile? editedProfile;

    await tester.pumpWidget(_wrap(repo, onEditProfile: (p) => editedProfile = p));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-edit-${profile.id}')));
    await tester.pumpAndSettle();

    expect(editedProfile, isNotNull);
    expect(editedProfile!.id, equals(profile.id));
  });

  testWidgets('tapping back calls onBack', (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    var called = false;

    await tester.pumpWidget(_wrap(repo, onBack: () => called = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(called, isTrue);
  });

  testWidgets('shows Upgrade CTA when at profile limit', (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository(maxProfiles: 1);
    await repo.createProfile(name: 'Me');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-upgrade-cta')), findsOneWidget);
    expect(find.byKey(const Key('profile-create-new')), findsNothing);
  });

  testWidgets('delete icon button is present for each profile',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-delete-${profile.id}')), findsOneWidget);
  });

  testWidgets('tapping delete shows confirmation dialog',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-delete-${profile.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-delete-dialog')), findsOneWidget);
    expect(find.byKey(const Key('profile-delete-confirm')), findsOneWidget);
    expect(find.byKey(const Key('profile-delete-cancel')), findsOneWidget);
  });

  testWidgets('tapping Cancel in delete dialog does not delete profile',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-delete-${profile.id}')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-delete-cancel')));
    await tester.pumpAndSettle();

    final profiles = await repo.getProfiles();
    expect(profiles, hasLength(1));
    expect(find.byKey(Key('profile-list-item-${profile.id}')), findsOneWidget);
  });

  testWidgets('tapping Delete in dialog removes profile from list',
      (WidgetTester tester) async {
    final repo = InMemoryProfilesRepository(maxProfiles: 2);
    final first = await repo.createProfile(name: 'Vishnu');
    final second = await repo.createProfile(name: 'Amma');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-delete-${first.id}')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-list-item-${first.id}')), findsNothing);
    expect(find.byKey(Key('profile-list-item-${second.id}')), findsOneWidget);
    final profiles = await repo.getProfiles();
    expect(profiles, hasLength(1));
  });
}
