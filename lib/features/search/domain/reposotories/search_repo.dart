import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  SearchRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getSearchProductList({
    required String name,
    required int offset,
    String? minPrice,
    String? maxPrice,
    List<int>? categoriesId,
    List<int>? cuisineIds,
    double? rating,
    String? productType,

  }) async {

    final data = {
      if (name.isNotEmpty) 'name': name,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (categoriesId != null && categoriesId.isNotEmpty) 'category_id': categoriesId,
      if (cuisineIds != null && cuisineIds.isNotEmpty) 'cuisine_id': cuisineIds,
      if (rating != null) 'rating': rating,
      if (productType != null) 'product_type': productType,
    };



    try {
      final response = await dioClient!.post('${AppConstants.searchUri}?limit=10&offset=$offset', data: data);

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for save home address
  Future<void> saveSearchAddress(String searchAddress) async {
    try {
      List<String> searchKeywordList = sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      if (!searchKeywordList.contains(searchAddress)) {
        searchKeywordList.add(searchAddress);
      }
      await sharedPreferences!.setStringList(AppConstants.searchAddress, searchKeywordList);
    } catch (e) {
      rethrow;
    }
  }

  List<String> getSearchAddress() {
    return sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
  }

  Future<bool> clearSearchAddress() async {
    return sharedPreferences!.setStringList(AppConstants.searchAddress, []);
  }


  Future<ApiResponseModel> getCuisineList() async {
    try {
      final response = await dioClient!.get(AppConstants.cuisineListUri);

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getProductSearchNameList() async {
    try {
      final response = await dioClient!.get(AppConstants.productSearchTagUri);

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getPopularTagApi() async {
    try {
      final response = await dioClient!.get(AppConstants.getPopularTagApi);

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
