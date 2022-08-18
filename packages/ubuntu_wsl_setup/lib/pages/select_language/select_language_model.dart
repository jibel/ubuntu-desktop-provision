import 'dart:ui';

import 'package:diacritic/diacritic.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:subiquity_client/subiquity_client.dart';
import 'package:ubuntu_wizard/utils.dart';
import 'package:ubuntu_wsl_setup/services/language_fallback.dart';

import '../../l10n.dart';

/// View model for [SelectLanguagePage].
class SelectLanguageModel extends SafeChangeNotifier {
  /// Creates a model with the specified client.
  SelectLanguageModel(this._client, this._languageFallback);

  final SubiquityClient _client;
  final LanguageFallbackService _languageFallback;

  /// The index of the currently selected language.
  int get selectedLanguageIndex => _selectedLanguageIndex;
  int _selectedLanguageIndex = 0;
  set selectedLanguageIndex(int index) {
    if (_selectedLanguageIndex == index) return;
    _selectedLanguageIndex = index;
    notifyListeners();
  }

  var _languages = <LocalizedLanguage>[];

  /// Loads available languages.
  Future<void> loadLanguages() async {
    return loadLocalizedLanguages(supportedLocales).then((languages) {
      _languages = languages;
      _languages.sort((a, b) =>
          removeDiacritics(_languageFallback.displayNameFor(a)).compareTo(
              removeDiacritics(_languageFallback.displayNameFor(b))));
    }).then((_) => notifyListeners());
  }

  /// Returns the locale for the given language [index].
  Locale locale(int index) => _languages[index].locale;

  /// Returns the appropriate locale for the given language [index] considering
  /// that the referred language might lack font support, for which case we
  /// return the default locale to avoid issues in the UI.
  Locale uiLocale(int index) {
    final loc = _languages[index].locale;
    return _languageFallback.isLocaleBlocked(loc) ? kDefaultLocale : loc;
  }

  /// Applies the given [locale].
  Future<void> applyLocale(Locale locale) {
    return _client
        .setLocale('${locale.languageCode}_${locale.countryCode}.UTF-8');
  }

  /// Returns the number of languages.
  int get languageCount => _languages.length;

  /// Returns the name of the language at the given [index].
  /// To avoid issues with the UI in WSL, the international name of
  /// the language is returned in case it's blacklisted.
  String language(int index) =>
      _languageFallback.displayNameFor(_languages[index]);

  /// Selects the given [locale].
  void selectLocale(Locale locale) {
    _selectedLanguageIndex = _languages.findBestMatch(locale);
  }

  /// Returns the [locale] defined in Subiquity server.
  Future<Locale> getServerLocale() {
    return _client.locale().then(parseLocale);
  }
}
