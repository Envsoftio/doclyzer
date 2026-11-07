import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

/// Uses the same list-row and bottom-sheet patterns as account settings.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.description = false,
    this.settings = false,
    this.saving = false,
  });
  final String value;
  final ValueChanged<String>? onChanged;
  final bool description;
  final bool settings;
  final bool saving;

  Future<void> _choose(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  description
                      ? context.l10n.descriptionLanguage
                      : context.l10n.preferredLanguage,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  key: const Key('language-options'),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: supportedLanguageNames.length,
                  itemBuilder: (context, index) {
                    final entry = supportedLanguageNames.entries.elementAt(
                      index,
                    );
                    final selected = entry.key == supportedLanguage(value);
                    return Semantics(
                      selected: selected,
                      child: ListTile(
                        key: Key('language-${entry.key}'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        selected: selected,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        title: Text(entry.value),
                        trailing: selected
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(entry.key),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (context.mounted && selected != null && selected != value) {
      onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = description
        ? context.l10n.descriptionLanguage
        : context.l10n.preferredLanguage;
    final tile = ListTile(
      key: const Key('language-selector'),
      contentPadding: settings
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      enabled: onChanged != null && !saving,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.translate_rounded, size: 20, color: colors.primary),
      ),
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle: Text(supportedLanguageNames[supportedLanguage(value)]!),
      trailing: saving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right, size: 20),
      onTap: onChanged == null || saving ? null : () => _choose(context),
    );
    return settings
        ? tile
        : Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: tile,
          );
  }
}
