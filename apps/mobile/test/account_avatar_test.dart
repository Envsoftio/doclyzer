import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/account/account_avatar.dart';
import 'package:mobile/features/account/account_repository.dart';

AccountProfile profile({
  String? name,
  String email = 'coder@example.com',
  String? photo,
}) => AccountProfile(
  id: 'user',
  email: email,
  displayName: name,
  avatarUrl: photo,
  createdAt: DateTime(2026),
);

void main() {
  testWidgets(
    'dashboard avatar shows the name initial and uses email as fallback',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccountAvatar(profile: profile(name: '  Vishnu  '), radius: 17),
                AccountAvatar(profile: profile(name: ' '), radius: 17),
                AccountAvatar(
                  profile: profile(name: 'Priya Mehta'),
                  radius: 21,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('V'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
      final initials = tester.widget<Text>(find.text('PM'));
      expect(initials.style?.fontSize, 21 * 1.1);
    },
  );

  testWidgets('dashboard avatar loads the uploaded image URL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountAvatar(
            profile: profile(
              name: 'Vishnu',
              photo: 'https://example.com/photo',
            ),
            radius: 17,
          ),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://example.com/photo');
    expect(find.text('V'), findsOneWidget);
  });

  testWidgets('avatar displays uploaded images from local storage data URLs', (
    tester,
  ) async {
    const photo =
        'data:application/octet-stream;base64,'
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
        'AAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountAvatar(
            profile: profile(name: 'Vishnu', photo: photo),
            radius: 21,
          ),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
    await tester.runAsync(() async {
      await precacheImage(image.image, tester.element(find.byType(Image)));
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('V'), findsNothing);
  });
}
