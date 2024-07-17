import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/search/domain/models/cuisine_model.dart';
import 'package:flutter_restaurant/features/search/domain/reposotories/search_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:provider/provider.dart';


class SearchProvider with ChangeNotifier {
  final SearchRepo? searchRepo;

  SearchProvider({required this.searchRepo});

  int? _selectedPriceIndex;
  List<List<int>> _priceList = [];
  // final List<int> _priceList = [10, 100, 1000, 10000];

  double? _rating;
  List<String> _historyList = [];
  bool _isSearch = true;
  List<int>? _cuisineIds;
  List<CuisineModel>? _cuisineList;
  final TextEditingController _searchController = TextEditingController();
  int _searchLength = 0;
  bool _isLoading = false;
  ProductModel? _searchProductModel;
  List<String>? _productSearchName;
  List<String>? _autoCompletedName;
  List<String>? _popularTag;

  int? get selectedPriceIndex => _selectedPriceIndex;
  List<List<int>> get priceFilterList => _priceList;
  List<int>? get cuisineIds => _cuisineIds;
  List<CuisineModel>? get cuisineList => _cuisineList;
  List<String> get historyList => _historyList;
  TextEditingController  get searchController=> _searchController;
  int get searchLength => _searchLength;
  bool get isSearch => _isSearch;
  double? get rating => _rating;
  bool get isLoading => _isLoading;
  ProductModel? get searchProductModel=> _searchProductModel;
  List<String>? get productSearchName=> _productSearchName;
  List<String>? get autoCompletedName=> _autoCompletedName;
  List<String>? get popularTag=> _popularTag;




  searchDone(){
    _isSearch = !_isSearch;
    notifyListeners();
  }

  getSearchText(String searchText){
    _searchLength = searchText.length;
    notifyListeners();
  }

  void _setPriceIndex(int? index) {
    _selectedPriceIndex = index;
    notifyListeners();
  }



  void updatePriceFilter(int? index){
    if(index != _selectedPriceIndex){
      _setPriceIndex(index);

    }else{
      _setPriceIndex(null);
      debugPrint('Removed Price Filter');
    }
    // notifyListeners();
  }


  Future<void> getCuisineList({bool isReload = false}) async {
    if(isReload) {
      _cuisineList = null;
    }

    if(_cuisineList == null) {
      ApiResponseModel apiResponse = await searchRepo!.getCuisineList();

      if (apiResponse.response?.statusCode == 200 && apiResponse.response?.data != null) {
        _cuisineList = [];
        apiResponse.response?.data.forEach((v) {
          _cuisineList?.add(CuisineModel.fromMap(v));

        });
      }
      notifyListeners();
    }

  }

  Future<void> getProductSearchTagList({bool isReload = false}) async {
    if(isReload) {
      _productSearchName = null;
    }

    if(_productSearchName == null) {
      ApiResponseModel apiResponse = await searchRepo!.getProductSearchNameList();

      if (apiResponse.response?.statusCode == 200 && apiResponse.response?.data != null) {
        _productSearchName = apiResponse.response?.data.cast<String>();
      }
      notifyListeners();
    }
  }

  Future<void> getPoplarTagList({bool isReload = false}) async {
    if(isReload) {
      _popularTag = null;
    }

    if(_popularTag == null) {
      ApiResponseModel apiResponse = await searchRepo!.getPopularTagApi();

      if (apiResponse.response?.statusCode == 200 && apiResponse.response?.data != null) {
        _popularTag = apiResponse.response?.data.cast<String>();
      }
      notifyListeners();
    }
  }



  void onSelectCuisineList(int? id){
    if(id != null) {
      _cuisineIds ??= [];

      if(_cuisineIds?.contains(id) ?? false) {
        _cuisineIds?.remove(id);
      }else {
        _cuisineIds?.add(id);

      }
    }


    notifyListeners();
  }



  bool _isClear = true;
  String _searchText = '';



  bool get isClear => _isClear;

  String get searchText => _searchText;

  void setSearchText(String text) {
    _searchText = text;
    // notifyListeners();
  }

  void cleanSearchProduct() {
    _isClear = true;
    _searchText = '';
   // notifyListeners();
  }

  Future<void> searchProduct({
    required int offset,
    required String name,
    required BuildContext context,
    bool isUpdate = true,
    String? productType,
  }) async {
    _searchText = name;
    _isLoading = true;

    if(offset == 1) {
      _searchProductModel = null;

      if(isUpdate) {
        notifyListeners();
      }
    }



    if(isUpdate) {
      notifyListeners();
    }
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);


    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      name: name,  offset: offset, productType: productType,
      categoriesId: categoryProvider.selectedCategoryList,
      cuisineIds: _cuisineIds,
      minPrice: _selectedPriceIndex != null ? _priceList[_selectedPriceIndex!].first.toString(): null,
      maxPrice: _selectedPriceIndex != null ? _priceList[_selectedPriceIndex!].last.toString() : null,
      rating: _rating,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      if(offset == 1) {
        _searchProductModel = ProductModel.fromJson(apiResponse.response?.data);
        _createFilterPriceList(_searchProductModel?.productMaxPrice ?? 0);

      }else {
        _searchProductModel?.totalSize = ProductModel.fromJson(apiResponse.response?.data).totalSize;
        _searchProductModel?.offset = ProductModel.fromJson(apiResponse.response?.data).offset;
        _searchProductModel?.products?.addAll(ProductModel.fromJson(apiResponse.response?.data).products ?? []);
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  void initHistoryList() {
    _historyList = [];
    _historyList.addAll(searchRepo!.getSearchAddress());
  }

  void saveSearchAddress(String searchAddress) async {
    if (!_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
      searchRepo!.saveSearchAddress(searchAddress);
      // notifyListeners();
    }
  }

  void removeHistoryItemByIndex(int index){
    _historyList.removeAt(index);
    notifyListeners();
  }

  void clearSearchAddress() async {
    searchRepo!.clearSearchAddress();
    _historyList = [];
    notifyListeners();
  }

  void onChangeRating(double rate) {
    _rating = rate;
    notifyListeners();
  }

  void resetFilterData({bool isUpdate = true}) {
    _selectedPriceIndex = null;
    _rating = null;
    _cuisineIds = null;
    Provider.of<CategoryProvider>(Get.context!, listen: false).clearSelectedCategory();

    if(isUpdate) {
      notifyListeners();
    }

  }

  void onChangeAutoCompleteTag({String? searchText}) {
    List<String> data = searchText == null
        ? _historyList
        : [
      ...?_productSearchName,
      ..._historyList
    ];

    if (searchText != null) {
      String normalizedSearchText = searchText.toLowerCase().replaceAll(' ', '');

      _autoCompletedName = data
          .where((tag) => tag.toLowerCase().replaceAll(' ', '').contains(normalizedSearchText))
          .toList();

      notifyListeners();
    }
  }

  void removePopularTagByIndex(int i){
    _popularTag?.removeAt(i);
    notifyListeners();
  }

  void _createFilterPriceList(double amount) {
     _priceList = [];
    int digit = '${amount.ceil()}'.length;

    for (int i = 0; i < digit; i++) {

      int min = i == 0 ? 0 : int.parse('1${'0' * i}');
      int max = int.parse('1${'0' * (i + 1)}');

      _priceList.add([min, max]);
    }

  }



}
