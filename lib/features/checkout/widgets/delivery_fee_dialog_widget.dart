import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_divider_widget.dart';
import 'package:flutter_restaurant/features/address/providers/zone_provider.dart';
import 'package:flutter_restaurant/features/cart/widgets/item_view_widget.dart';
import 'package:flutter_restaurant/features/order/providers/order_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/checkout_helper.dart';
import 'package:flutter_restaurant/helper/price_converter_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DeliveryFeeDialogWidget extends StatelessWidget {
  final double? amount;
  final double distance;
  final Function(double amount)? callBack;

  const DeliveryFeeDialogWidget(
      {super.key, required this.amount, required this.distance, this.callBack});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final ZoneProvider zoneProvider =
        Provider.of<ZoneProvider>(context, listen: false);
    double deliveryFee = zoneProvider
        .getDeliveryFeeForSelectedCity(); // Assuming you have a method to get the delivery fee

    double deliveryCharge = CheckOutHelper.getDeliveryChargeFromJson(
      deliveryFee: deliveryFee,
    );

    //  CheckOutHelper.getDeliveryCharge(
    //   distance: distance,
    //   shippingPerKm:
    //       splashProvider.configModel?.deliveryManagement?.shippingPerKm ?? 0,
    //   minShippingCharge:
    //       splashProvider.configModel?.deliveryManagement?.minShippingCharge ??
    //           0,
    //   defaultDeliveryCharge: splashProvider.configModel?.deliveryCharge ?? 0,
    // );
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context) ? 300 : 0),
      child: Consumer<OrderProvider>(builder: (context, order, child) {
        if (callBack != null) {
          callBack!(deliveryCharge);
        }

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Column(children: [
                Text(
                  '${getTranslated('delivery_fee_from_your_selected_address_to_branch', context)!}:',
                  style:
                      rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                CustomDirectionalityWidget(
                    child: Text(
                  PriceConverterHelper.convertPrice(deliveryCharge),
                  style: rubikBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge),
                )),
                const SizedBox(height: 20),
                ItemViewWidget(
                  title: getTranslated('subtotal', context)!,
                  subTitle: PriceConverterHelper.convertPrice(amount),
                ),
                const SizedBox(height: 10),
                ItemViewWidget(
                  title: getTranslated('delivery_fee', context)!,
                  subTitle:
                      '(+) ${PriceConverterHelper.convertPrice(deliveryCharge)}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall),
                  child: CustomDividerWidget(),
                ),
                ItemViewWidget(
                  title: getTranslated('total_amount', context)!,
                  subTitle: PriceConverterHelper.convertPrice(
                      amount! + deliveryCharge),
                  titleStyle: rubikMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).primaryColor),
                ),
              ]),
              const SizedBox(height: 30),
              CustomButtonWidget(
                  btnTxt: getTranslated('ok', context),
                  onTap: () {
                    context.pop();
                  }),
            ]),
          ),
        );
      }),
    );
  }
}
