import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/language_model.dart';
import 'package:flutter_restaurant/features/language/domain/reposotories/language_repo.dart';

class LanguageProvider with ChangeNotifier {
  final LanguageRepo? languageRepo;

  LanguageProvider({this.languageRepo});

  int? _selectIndex = 0;

  int? get selectIndex => _selectIndex;

  void setSelectIndex(int? index, {bool isUpdate = true}) {
    _selectIndex = index;

    if(isUpdate) {
      notifyListeners();
    }
  }

  List<LanguageModel> _languages = [];

  List<LanguageModel> get languages => _languages;

  void searchLanguage(String query, BuildContext context) {
    if (query.isEmpty) {
      _languages.clear();
      _languages = languageRepo!.getAllLanguages(context: context);
      notifyListeners();
    } else {
      _selectIndex = -1;
      _languages = [];
      languageRepo!.getAllLanguages(context: context).forEach((product) async {
        if (product.languageName!.toLowerCase().contains(query.toLowerCase())) {
          _languages.add(product);
        }
      });
      notifyListeners();
    }
  }

  void initializeAllLanguages(BuildContext context) {
    _languages = [];
    _languages = languageRepo?.getAllLanguages(context: context) ?? [];
  }

  int getLanguageIndexByCode(String langCode) {
    for (int i = 0; i < _languages.length; i++) {
      if (langCode == _languages[i].languageCode) {
        return i;
      }
    }
    return 0;
  }
}
