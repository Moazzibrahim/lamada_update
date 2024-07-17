
import 'package:flutter_restaurant/common/enums/product_sort_type_enum.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/features/refer_and_earn/domain/models/review_body_model.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';

class ProductRepo {
  final DioClient? dioClient;

  ProductRepo({required this.dioClient});

  Future<ApiResponseModel> getLatestProductList(int offset, ProductSortType type) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.latestProductUri}?limit=15&&offset=$offset&sort_by=${type.name.camelCaseToSnakeCase()}',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponseModel> getRecommendedProductApi(int offset) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.recommendedProductUri}?limit=100&&offset=$offset',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponseModel> getPopularProductList(int offset) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.popularProductUri}?limit=10&&offset=$offset&product_type=all',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getFlavorFulMenuProductApi(int offset) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.setMenuUri}?limit=12&&offset=$offset',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }





  Future<ApiResponseModel> submitReview(ReviewBody reviewBody, List<XFile>? files, ) async {
    try {
      final response = await dioClient!.postMultipart(AppConstants.reviewUri, data: reviewBody.toJson(), files: files, fileKey: files != null ? 'attachment' : null);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    try {
      final response = await dioClient!.post(AppConstants.deliverManReviewUri, data: reviewBody);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getFrequentlyBoughtProductApi(int offset) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.frequentlyBoughtApi}?limit=4&&offset=$offset',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }

  Future<ApiResponseModel> getReorderProductApi(int? orderId) async {
    try {
      final response = await dioClient!.post(AppConstants.getReorderProducts, data: {'order_id' : '$orderId'});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }

  }



}
