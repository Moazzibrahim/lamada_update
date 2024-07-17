import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/home/domain/models/banner_model.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/home/domain/reposotories/banner_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';

class BannerProvider extends ChangeNotifier {
  final BannerRepo? bannerRepo;
  BannerProvider({required this.bannerRepo});

  List<BannerModel>? _bannerList;
  final List<Product> _productList = [];

  List<BannerModel>? get bannerList => _bannerList;
  List<Product> get productList => _productList;

  Future<void> getBannerList(bool reload) async {
    if(bannerList == null || reload) {
      ApiResponseModel apiResponse = await bannerRepo!.getBannerList();
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _bannerList = [];
        apiResponse.response!.data.forEach((category) {
          BannerModel bannerModel = BannerModel.fromJson(category);
          if(bannerModel.productId != null) {
            getProductDetails(bannerModel.productId.toString());
          }
          _bannerList!.add(bannerModel);
        });
        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }
  }

  Future<Product?> getProductDetails(String productID) async {
    Product? product;
    ApiResponseModel apiResponse = await bannerRepo!.getProductDetails(productID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      product = Product.fromJson(apiResponse.response!.data);
      _productList.add(product);
    }
    return product;
  }
}