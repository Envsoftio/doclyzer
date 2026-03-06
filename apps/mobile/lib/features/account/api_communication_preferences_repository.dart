import '../../core/api_client.dart';
import 'communication_preferences_repository.dart';

class ApiCommunicationPreferencesRepository
    implements CommunicationPreferencesRepository {
  ApiCommunicationPreferencesRepository(this._client);

  final ApiClient _client;

  @override
  Future<CommunicationPreferences> getPreferences() async {
    final data = await _client.get('v1/account/communication-preferences');
    final d = data['data'] as Map<String, dynamic>;
    return _prefsFromJson(d);
  }

  @override
  Future<CommunicationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    final body = <String, dynamic>{};
    if (updates.containsKey(commPrefCategoryProduct)) {
      body['productEmails'] = updates[commPrefCategoryProduct];
    }
    final data = await _client.patch(
      'v1/account/communication-preferences',
      body: body,
    );
    final d = data['data'] as Map<String, dynamic>;
    return _prefsFromJson(d);
  }

  CommunicationPreferences _prefsFromJson(Map<String, dynamic> json) {
    final prefs = (json['preferences'] as List<dynamic>)
        .map((e) => _itemFromJson(e as Map<String, dynamic>))
        .toList();
    return CommunicationPreferences(preferences: prefs);
  }

  CommunicationPreferenceItem _itemFromJson(Map<String, dynamic> json) {
    return CommunicationPreferenceItem(
      category: json['category'] as String,
      enabled: json['enabled'] as bool? ?? true,
      mandatory: json['mandatory'] as bool? ?? false,
    );
  }
}
