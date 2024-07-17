import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/models/offline_payment_model.dart';
import 'package:flutter_restaurant/common/widgets/custom_loader_widget.dart';
import 'package:flutter_restaurant/features/address/domain/models/address_model.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/branch/providers/branch_provider.dart';
import 'package:flutter_restaurant/features/checkout/domain/enum/delivery_type_enum.dart';
import 'package:flutter_restaurant/features/checkout/providers/checkout_provider.dart';
import 'package:flutter_restaurant/features/checkout/widgets/delivery_fee_dialog_widget.dart';
import 'package:flutter_restaurant/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {
  static bool isWalletPayment(
      {required ConfigModel configModel,
      required bool isLogin,
      required double? partialAmount,
      required bool isPartialPayment}) {
    return configModel.walletStatus! &&
        configModel.isPartialPayment! &&
        isLogin &&
        (partialAmount == null) &&
        !isPartialPayment;
  }

  static double getDeliveryChargeFromJson({
    required double deliveryFee,
  }) {
    return deliveryFee;
  }

  static bool isPartialPayment(
      {required ConfigModel configModel,
      required bool isLogin,
      required UserInfoModel? userInfoModel}) {
    return isLogin &&
        configModel.isPartialPayment! &&
        configModel.walletStatus! &&
        (userInfoModel != null && userInfoModel.walletBalance! > 0);
  }

  static bool isPartialPaymentSelected(
      {required int? paymentMethodIndex,
      required PaymentMethod? selectedPaymentMethod}) {
    return (paymentMethodIndex == 1 && selectedPaymentMethod != null);
  }

  static List<Map<String, dynamic>> getOfflineMethodJson(
      List<MethodField>? methodList) {
    List<Map<String, dynamic>> mapList = [];
    List<String?> keyList = [];
    List<String?> valueList = [];

    for (MethodField methodField in (methodList ?? [])) {
      keyList.add(methodField.fieldName);
      valueList.add(methodField.fieldData);
    }

    for (int i = 0; i < keyList.length; i++) {
      mapList.add({'${keyList[i]}': '${valueList[i]}'});
    }

    return mapList;
  }

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }) {
    final BranchProvider branchProvider =
        Provider.of<BranchProvider>(Get.context!, listen: false);

    AddressModel? deliveryAddress;
    if (selectedAddress != null) {
      deliveryAddress = selectedAddress;
    } else if (lastOrderAddress != null) {
      deliveryAddress = lastOrderAddress;
    } else if (addressList != null && addressList.isNotEmpty) {
      deliveryAddress = addressList.first;
    }

    if (deliveryAddress != null &&
        !isAddressInCoverage(branchProvider.getBranch(), deliveryAddress)) {
      deliveryAddress = null;
    }

    return deliveryAddress;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) =>
      configModel?.deliveryManagement?.status ?? false;

  static Future<void> selectDeliveryAddress({
    required bool isAvailable,
    required int index,
    required ConfigModel? configModel,
    required LocationProvider locationProvider,
    required CheckoutProvider checkoutProvider,
    required bool fromAddressList,
  }) async {
    if (isAvailable) {
      locationProvider.updateAddressIndex(index, fromAddressList);
      checkoutProvider.setAddressIndex(index, isUpdate: false);

      if (CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        if (fromAddressList) {
          if (checkoutProvider.selectedPaymentMethod != null) {
            showCustomSnackBarHelper(
                getTranslated('your_payment_method_has_been', Get.context!),
                isError: false);
          }
          checkoutProvider.savePaymentMethod(index: null, method: null);
        }
        showDialog(
            context: Get.context!,
            builder: (context) => Center(
                    child: Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      CustomLoaderWidget(color: Theme.of(context).primaryColor),
                )),
            barrierDismissible: false);

        bool isSuccess = await checkoutProvider.getDistanceInMeter(
          LatLng(
            double.tryParse(
                    '${configModel?.branches?[checkoutProvider.branchIndex]?.latitude}') ??
                0,
            double.tryParse(
                    '${configModel?.branches?[checkoutProvider.branchIndex]?.longitude}') ??
                0,
          ),
          LatLng(
            double.tryParse(
                    '${locationProvider.addressList?[index].latitude}') ??
                0,
            double.tryParse(
                    '${locationProvider.addressList?[index].longitude}') ??
                0,
          ),
        );

        Navigator.pop(Get.context!);

        if (fromAddressList) {
          await showDialog(
              context: Get.context!,
              builder: (context) => DeliveryFeeDialogWidget(
                    amount: checkoutProvider.getCheckOutData?.amount,
                    distance: checkoutProvider.distance,
                    callBack: (deliveryCharge) {
                      checkoutProvider.getCheckOutData
                          ?.copyWith(deliveryCharge: deliveryCharge);
                    },
                  ));
        } else {
          checkoutProvider.getCheckOutData?.copyWith(
              deliveryCharge: getDeliveryCharge(
            distance: checkoutProvider.distance,
            shippingPerKm: configModel?.deliveryManagement?.shippingPerKm ?? 0,
            minShippingCharge:
                configModel?.deliveryManagement?.minShippingCharge ?? 0,
            defaultDeliveryCharge: configModel?.deliveryCharge ?? 0,
          ));
        }

        if (!isSuccess) {
          showCustomSnackBarHelper(
              getTranslated('failed_to_fetch_distance', Get.context!));
        } else {
          checkoutProvider.setAddressIndex(index);
        }
      }
    } else {
      showCustomSnackBarHelper(
          getTranslated('out_of_coverage_for_this_branch', Get.context!));
    }
  }

  static double getDeliveryCharge({
    required double distance,
    required double shippingPerKm,
    required double minShippingCharge,
    required double defaultDeliveryCharge,
    bool isTakeAway = false,
    bool kmWiseCharge = true,
  }) {
    double deliveryCharge = 0;
    if (!isTakeAway && kmWiseCharge) {
      deliveryCharge = distance * shippingPerKm;
      if (deliveryCharge < minShippingCharge) {
        deliveryCharge = minShippingCharge;
      }
    } else if (!isTakeAway && !kmWiseCharge) {
      deliveryCharge = defaultDeliveryCharge;
    }

    return deliveryCharge;
  }

  static selectDeliveryAddressAuto(
      {AddressModel? lastAddress,
      required bool isLoggedIn,
      required OrderType? orderType}) async {
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(Get.context!, listen: false);
    final CheckoutProvider checkoutProvider =
        Provider.of<CheckoutProvider>(Get.context!, listen: false);
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);

    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: checkoutProvider.addressIndex == -1
          ? null
          : locationProvider.addressList?[checkoutProvider.addressIndex],
      lastOrderAddress: lastAddress,
    );

    if (isLoggedIn &&
        orderType == OrderType.delivery &&
        deliveryAddress != null &&
        locationProvider.getAddressIndex(deliveryAddress) != null) {
      await CheckOutHelper.selectDeliveryAddress(
        isAvailable: true,
        index: locationProvider.getAddressIndex(deliveryAddress)!,
        configModel: splashProvider.configModel!,
        locationProvider: locationProvider,
        checkoutProvider: checkoutProvider,
        fromAddressList: false,
      );
    }
  }

  static bool isAddressInCoverage(
      Branches? currentBranch, AddressModel address) {
    bool isAvailable = currentBranch == null ||
        (currentBranch.latitude == null || currentBranch.latitude!.isEmpty);

    if (!isAvailable) {
      double distance = Geolocator.distanceBetween(
            double.parse(currentBranch.latitude!),
            double.parse(currentBranch.longitude!),
            double.parse(address.latitude!),
            double.parse(address.longitude!),
          ) /
          1000;

      isAvailable = distance < (currentBranch.coverage ?? 0);
    }

    return isAvailable;
  }
}
