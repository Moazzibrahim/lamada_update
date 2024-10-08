import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/setmenu/domain/reposotories/set_menu_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';

class SetMenuProvider extends ChangeNotifier {
  final SetMenuRepo? setMenuRepo;

  SetMenuProvider({required this.setMenuRepo});

  List<Product>? _setMenuList;
  final int _currentIndex = 0;
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;

  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;

  List<Product>? get setMenuList => _setMenuList;
  int get getCurrentIndex => _currentIndex;

  Future<void> getSetMenuList(bool reload) async {
    if (setMenuList == null || reload) {
      ApiResponseModel apiResponse = await setMenuRepo!.getSetMenuList();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _setMenuList = [];
        apiResponse.response!.data.forEach((setMenu) =>
            _setMenuList!.add(Product.fromJson(setMenu)));
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
      notifyListeners();
    }
  }

  updateSetMenuCurrentIndex(int index, int totalLength) {
    if(index > 0) {
      _pageFirstIndex = false;
      notifyListeners();
    }else{
      _pageFirstIndex = true;
      notifyListeners();
    }
    if(index + 1  == totalLength) {
      _pageLastIndex = true;
      notifyListeners();
    }else {
      _pageLastIndex = false;
      notifyListeners();
    }
  }



}