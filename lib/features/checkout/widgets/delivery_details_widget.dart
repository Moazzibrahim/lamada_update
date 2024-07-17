import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/widgets/branch_list_widget.dart';
import 'package:flutter_restaurant/features/address/domain/models/address_model.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/branch/providers/branch_provider.dart';
import 'package:flutter_restaurant/features/cart/widgets/delivery_option_widget.dart';
import 'package:flutter_restaurant/features/checkout/domain/enum/delivery_type_enum.dart';
import 'package:flutter_restaurant/features/checkout/providers/checkout_provider.dart';
import 'package:flutter_restaurant/features/checkout/widgets/address_change_widget.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/checkout_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryDetailsWidget extends StatelessWidget {
  const DeliveryDetailsWidget({
    super.key,
    required this.currentBranch,
    required this.kmWiseCharge,
    required this.deliveryCharge,
    this.amount,
  });

  final Branches? currentBranch;
  final bool kmWiseCharge;
  final double? deliveryCharge;
  final double? amount;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final ScrollController branchListScrollController = ScrollController();

    return Consumer<LocationProvider>(builder: (context, locationProvider, _) {
      final CheckoutProvider checkoutProvider =
          Provider.of<CheckoutProvider>(context, listen: false);
      final SplashProvider splashProvider =
          Provider.of<SplashProvider>(context, listen: false);

      AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
        addressList: locationProvider.addressList,
        selectedAddress: checkoutProvider.addressIndex == -1
            ? null
            : locationProvider.addressList?[checkoutProvider.addressIndex],
        lastOrderAddress: null,
      );

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.5),
                blurRadius: Dimensions.radiusDefault)
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (checkoutProvider.orderType == OrderType.delivery) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    getTranslated('deliver_to', context)!,
                    style: rubikBold.copyWith(
                      fontSize: isDesktop
                          ? Dimensions.fontSizeLarge
                          : Dimensions.fontSizeDefault,
                      fontWeight: isDesktop ? FontWeight.w700 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () => ResponsiveHelper.showDialogOrBottomSheet(
                      context,
                      AddressChangeWidget(
                        amount: amount,
                        currentBranch: currentBranch,
                        kmWiseCharge: kmWiseCharge,
                      ),
                    ),
                    child: Text(
                      getTranslated('change', context)!,
                      style: rubikBold.copyWith(
                        color: ColorResources.getSecondaryColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: isDesktop
                    ? Dimensions.paddingSizeDefault
                    : Dimensions.paddingSizeSmall),
            deliveryAddress == null
                ? Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Flexible(
                            child: Text(
                              getTranslated('no_contact_info_added', context)!,
                              style: rubikRegular.copyWith(
                                  color: Theme.of(context).colorScheme.error),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _ContactItemWidget(
                          icon: deliveryAddress.addressType == 'Home'
                              ? Icons.home_outlined
                              : deliveryAddress.addressType == 'Workplace'
                                  ? Icons.work_outline
                                  : Icons.list_alt_outlined,
                          title: getTranslated(
                              deliveryAddress.addressType ?? '', context),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        _ContactItemWidget(
                            icon: Icons.person,
                            title: deliveryAddress.contactPersonName ?? ''),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        _ContactItemWidget(
                            icon: Icons.call,
                            title: deliveryAddress.contactPersonNumber ?? ''),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        const Divider(
                            height: Dimensions.paddingSizeDefault,
                            thickness: 0.5),
                        Text(
                          deliveryAddress.address ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: rubikRegular,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (deliveryAddress.houseNumber != null)
                                Flexible(
                                  child: Text(
                                    '${getTranslated('house', context)} - ${deliveryAddress.houseNumber}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: rubikRegular,
                                  ),
                                ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              if (deliveryAddress.floorNumber != null)
                                Flexible(
                                  child: Text(
                                    '${getTranslated('floor', context)} - ${deliveryAddress.floorNumber}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: rubikRegular,
                                  ),
                                ),
                            ]),
                      ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
          Text(
            getTranslated('delivery_type', context)!,
            style: rubikBold.copyWith(
              fontSize: isDesktop
                  ? Dimensions.fontSizeLarge
                  : Dimensions.fontSizeDefault,
              fontWeight: isDesktop ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Consumer<CheckoutProvider>(builder: (context, checkoutProvider, _) {
            if (isDesktop) {
              return Row(children: [
                Expanded(
                  child: (splashProvider.configModel?.homeDelivery ?? false)
                      ? DeliveryOptionWidget(
                          value: OrderType.delivery,
                          title: getTranslated('delivery', context)!,
                          deliveryCharge: deliveryCharge ?? 0,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeSmall,
                              top: Dimensions.paddingSizeLarge),
                          child: Row(children: [
                            Icon(
                              Icons.remove_circle_outline_sharp,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraLarge),
                            Flexible(
                              child: Text(
                                getTranslated(
                                    'home_delivery_not_available', context)!,
                                style: TextStyle(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                        ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                if (splashProvider.configModel?.selfPickup ?? false)
                  Expanded(
                    child: DeliveryOptionWidget(
                      value: OrderType.takeAway,
                      title: getTranslated('take_away', context)!,
                      deliveryCharge: deliveryCharge ?? 0,
                    ),
                  ),
              ]);
            } else {
              return Column(children: [
                (splashProvider.configModel?.homeDelivery ?? false)
                    ? DeliveryOptionWidget(
                        value: OrderType.delivery,
                        title: getTranslated('delivery', context)!,
                        deliveryCharge: deliveryCharge ?? 0,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeLarge),
                        child: Row(children: [
                          Icon(
                            Icons.remove_circle_outline_sharp,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraLarge),
                          Flexible(
                            child: Text(
                              getTranslated(
                                  'home_delivery_not_available', context)!,
                              style: TextStyle(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                if (splashProvider.configModel?.selfPickup ?? false)
                  DeliveryOptionWidget(
                    value: OrderType.takeAway,
                    title: getTranslated('take_away', context)!,
                    deliveryCharge: deliveryCharge ?? 0,
                  ),
              ]);
            }
          }),
          // Add branch list when 'Take Away' is selected
          if (checkoutProvider.orderType == OrderType.takeAway)
            Consumer<BranchProvider>(builder: (context, branchProvider, _) {
              return branchProvider.branchValueList?.isEmpty ?? false
                  ? const SizedBox()
                  : Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  isDesktop ? 0 : Dimensions.paddingSizeSmall),
                          child: BranchListWidget(
                              controller: branchListScrollController),
                        ),
                      ),
                    );
            }),
        ]),
      );
    });
  }
}

class _ContactItemWidget extends StatelessWidget {
  final IconData icon;
  final String? title;

  const _ContactItemWidget({
    required this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Flexible(
        child: Text(
          title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: rubikRegular,
        ),
      ),
    ]);
  }
}
