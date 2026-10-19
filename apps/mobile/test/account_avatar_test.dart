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
              ],
            ),
          ),
        ),
      );
      expect(find.text('V'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
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
  });
}
