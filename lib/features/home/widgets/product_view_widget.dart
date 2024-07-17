import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/paginated_list_widget.dart';
import 'package:flutter_restaurant/common/widgets/product_shimmer_widget.dart';
import 'package:flutter_restaurant/common/widgets/title_widget.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/product_type_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/home/enums/view_change_to_enum.dart';
import 'package:flutter_restaurant/features/home/providers/sorting_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/sorting_button_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductViewWidget extends StatelessWidget {
  final ProductType productType;
  final ScrollController scrollController;
  const ProductViewWidget({super.key, required this.productType, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final double width = MediaQuery.sizeOf(context).width;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {

        /// for Shimmer
        if(productProvider.latestProductModel == null) {
          return Column(children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Shimmer(enabled: true, child: Container(
                height: 20, width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                ),
              )),

              Padding(
                padding: EdgeInsets.only(right: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
                child: Shimmer(enabled: true, child: Container(
                  height: 20, width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                  ),
                )),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
                crossAxisCount: isDesktop ? 5 : ResponsiveHelper.isTab(context) ? 4 : 2,
                mainAxisExtent: !isDesktop ? 240 : 250,
              ),
              itemCount: 12,
              itemBuilder: (BuildContext context, int index) {
                return const ProductShimmerWidget(isEnabled: true, width: double.minPositive, isList: false);
              },
              padding: EdgeInsets.zero,
            ),
          ]);
        }

        return Column(children: [

          TitleWidget(
            title: getTranslated(isDesktop ? 'latest_item' : 'all_foods', context),
            trailingIcon: const SortingButtonWidget(),
            isShowTrailingIcon: true,
          ),
          SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),



          PaginatedListWidget(
            scrollController: scrollController,
            onPaginate: (int? offset) async {
              await productProvider.getLatestProductList(offset ?? 1, false);
            },
            totalSize: productProvider.latestProductModel?.totalSize,
            offset: productProvider.latestProductModel?.offset,
            limit: productProvider.latestProductModel?.limit,
            itemView: Consumer<ProductSortProvider>(builder: (context, sortingProvider, child) => GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
                crossAxisCount: isDesktop ? sortingProvider.viewChangeTo == ViewChangeTo.gridView ? 5 : 2
                    : ResponsiveHelper.isTab(context) ? sortingProvider.viewChangeTo == ViewChangeTo.gridView ? 4 : 2
                    : sortingProvider.viewChangeTo == ViewChangeTo.gridView ? 2 : 1,
                mainAxisExtent: ResponsiveHelper.isMobile() ? 260 : sortingProvider.viewChangeTo == ViewChangeTo.gridView ? 300 : 165,
              ),
              itemCount: productProvider.latestProductModel?.products?.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => ProductCardWidget(
                product: productProvider.latestProductModel!.products![index],
                quantityPosition: sortingProvider.viewChangeTo == ViewChangeTo.listView
                    ? QuantityPosition.right : isDesktop
                    ? QuantityPosition.center : QuantityPosition.left,
                productGroup: sortingProvider.viewChangeTo == ViewChangeTo.listView
                    ? ResponsiveHelper.isMobile()
                    ? ProductGroup.common : ProductGroup.setMenu
                    : ProductGroup.common,
                isShowBorder: true,
                imageHeight: ! ResponsiveHelper.isMobile() ? sortingProvider.viewChangeTo == ViewChangeTo.listView ? 150 : 200 : 160,
                imageWidth: (isDesktop || ResponsiveHelper.isTab(context)) && sortingProvider.viewChangeTo == ViewChangeTo.listView ? 200 : width,
              ),
            )),
          ),



          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          /// for see more button

      ]);
      },
    );
  }
}
