import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/profiles/screens/profile_list_screen.dart';
import 'fakes.dart';

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
    final repo = FakeProfilesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-create-new')), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders profile list after create', (WidgetTester tester) async {
    final repo = FakeProfilesRepository();
    final profile = await repo.createProfile(name: 'Vishnu');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-list-item-${profile.id}')), findsOneWidget);
  });

  testWidgets('active profile shows Active chip, inactive shows Set Active button',
      (WidgetTester tester) async {
    final repo = FakeProfilesRepository(maxProfiles: 2);
    final first = await repo.createProfile(name: 'Vishnu');
    final second = await repo.createProfile(name: 'Amma');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-active-chip-${first.id}')), findsOneWidget);
    expect(find.byKey(Key('profile-activate-${second.id}')), findsOneWidget);
  });

  testWidgets('tapping delete shows confirmation dialog',
      (WidgetTester tester) async {
    final repo = FakeProfilesRepository();
    final profile = await repo.createProfile(name: 'ToDelete');

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('profile-delete-${profile.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-delete-dialog')), findsOneWidget);
    expect(find.text('Delete profile?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-delete-cancel')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile-list-item-${profile.id}')), findsOneWidget);
  });
}
