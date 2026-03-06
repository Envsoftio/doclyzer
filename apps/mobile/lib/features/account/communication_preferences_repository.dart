const commPrefCategorySecurity = 'security';
const commPrefCategoryCompliance = 'compliance';
const commPrefCategoryProduct = 'product';

const mandatoryCategories = {commPrefCategorySecurity, commPrefCategoryCompliance};

class CommunicationPreferenceItem {
  const CommunicationPreferenceItem({
    required this.category,
    required this.enabled,
    required this.mandatory,
  });

  final String category;
  final bool enabled;
  final bool mandatory;
}

class CommunicationPreferences {
  const CommunicationPreferences({required this.preferences});

  final List<CommunicationPreferenceItem> preferences;
}

class CommunicationPreferencesException implements Exception {
  const CommunicationPreferencesException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class CommunicationPreferencesRepository {
  Future<CommunicationPreferences> getPreferences();

  Future<CommunicationPreferences> updatePreferences(
    Map<String, bool> updates,
  );
}
