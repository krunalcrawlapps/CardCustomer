import 'package:card_app/database/database_helper.dart';
import 'package:card_app/utils/in_app_translation.dart';
import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _locale = SuppotedLanguage.english;
  String get locale => DatabaseHelper.shared.getLangauge ?? this._locale;

  AppTranslationsDelegate _newLocaleDelegate = AppTranslationsDelegate(
      newLocale: DatabaseHelper.shared.getLangauge ?? SuppotedLanguage.english);

  AppTranslationsDelegate get newLocaleDelegate => this._newLocaleDelegate;

  set newLocaleDelegate(AppTranslationsDelegate value) {
    this._newLocaleDelegate = value;
  }

  bool get isArabic => locale == SuppotedLanguage.arabic;

  set locale(String value) {
    this._locale = value;
    DatabaseHelper.shared.saveLanguage(value);
    newLocaleDelegate = AppTranslationsDelegate(newLocale: value);
    notifyListeners();
  }
}
