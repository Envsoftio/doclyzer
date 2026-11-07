import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../l10n/l10n.dart';
import 'language_selector.dart';

class LocalizedDescription extends StatefulWidget {
  const LocalizedDescription({
    super.key,
    required this.english,
    required this.load,
    required this.builder,
  });
  final String english;
  final Future<String> Function(String locale) load;
  final Widget Function(String text) builder;

  @override
  State<LocalizedDescription> createState() => _LocalizedDescriptionState();
}

class _LocalizedDescriptionState extends State<LocalizedDescription> {
  String? _preferred;
  String _language = 'en';
  Future<String>? _translation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final preferred = supportedLanguage(
      Localizations.localeOf(context).languageCode,
    );
    if (_preferred != preferred) {
      _preferred = preferred;
      _select(preferred, rebuild: false);
    }
  }

  @override
  void didUpdateWidget(covariant LocalizedDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.english != widget.english) _select(_language, rebuild: false);
  }

  void _select(String value, {bool rebuild = true}) {
    void update() {
      _language = value;
      _translation = value == 'en' ? null : widget.load(value);
    }

    if (rebuild) {
      setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LanguageSelector(value: _language, onChanged: _select, description: true),
      const SizedBox(height: 12),
      if (_language == 'en')
        widget.builder(widget.english)
      else
        FutureBuilder<String>(
          key: ValueKey('$_language:${widget.english}'),
          future: _translation,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(context.l10n.translationLoading),
                ],
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              final changed =
                  snapshot.error is ApiException &&
                  (snapshot.error as ApiException).code ==
                      'NARRATIVE_SOURCE_CHANGED';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    changed
                        ? context.l10n.sourceChanged
                        : context.l10n.translationFailed,
                  ),
                  TextButton(
                    onPressed: () => _select(_language),
                    child: Text(context.l10n.tryAgain),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.builder(snapshot.data!),
                const SizedBox(height: 12),
                Text(
                  context.l10n.translationNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
    ],
  );
}
