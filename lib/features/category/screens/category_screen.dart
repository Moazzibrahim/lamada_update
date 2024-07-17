import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/filter_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/footer_widget.dart';
import 'package:flutter_restaurant/common/widgets/no_data_widget.dart';
import 'package:flutter_restaurant/common/widgets/product_shimmer_widget.dart';
import 'package:flutter_restaurant/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;
  final String? categoryBannerImage;
  const CategoryScreen({super.key, required this.categoryId, this.categoryName, this.categoryBannerImage});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  int _tabIndex = 0;
  String _type = 'all';

 @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
   final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

   categoryProvider.getCategoryList(false);
   categoryProvider.getSubCategoryList(widget.categoryId);
 }

  @override
  Widget build(BuildContext context) {
   final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
   final productProvider = Provider.of<ProductProvider>(context, listen: false);

   final Size size = MediaQuery.sizeOf(context);
   final double realSpaceNeeded = (size.width - Dimensions.webScreenWidth) / 2;
   final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBarWidget()) : null,
      body: Consumer<CategoryProvider>(
        builder: (context, category, child) {
          return category.isLoading || category.categoryList == null ?
          _categoryShimmer(context, size.height, category) :
          CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [

            SliverAppBar(
              backgroundColor: Theme.of(context).cardColor,
              expandedHeight: 200,
              toolbarHeight: 50 + MediaQuery.of(context).padding.top,
              pinned: true,
              floating: false,
              leading: isDesktop?const SizedBox():SizedBox(width:isDesktop ? 1170: MediaQuery.of(context).size.width,
                  child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => context.pop())),
              flexibleSpace: Container(color:Theme.of(context).canvasColor,
                margin: isDesktop? EdgeInsets.symmetric(horizontal: realSpaceNeeded) : const EdgeInsets.symmetric(horizontal: 0),
                width: isDesktop ? Dimensions.webScreenWidth : MediaQuery.of(context).size.width,
                child: FlexibleSpaceBar(
                  title: Text(widget.categoryName ?? '', style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor,
                  )),
                  titlePadding: EdgeInsets.only(
                    bottom: 54 + (MediaQuery.of(context).padding.top/2),
                    left: 50,
                    right: 50,
                  ),
                  background: Container(height: 50, width : isDesktop ? Dimensions.webScreenWidth : MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 50),
                    child: CustomImageWidget(
                      placeholder: Images.categoryBanner, fit: BoxFit.cover,
                      image: '${splashProvider.baseUrls?.categoryBannerImageUrl}/${widget.categoryBannerImage}',
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30.0),
                child: category.subCategoryList != null?Container(
                  width:  isDesktop ? Dimensions.webScreenWidth : MediaQuery.of(context).size.width,
                  color: Theme.of(context).cardColor,
                  child: TabBar(
                    controller: TabController(initialIndex: _tabIndex,
                        length: category.subCategoryList!.length+1, vsync: this),
                    isScrollable: true,
                    unselectedLabelColor: Theme.of(context).hintColor.withOpacity(0.7),
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                    tabs: _tabs(category),
                    onTap: (int index) {
                      _type = 'all';
                      _tabIndex = index;
                      if(index == 0) {
                        category.getCategoryProductList(widget.categoryId);
                      }else {
                        category.getCategoryProductList(category.subCategoryList![index-1].id.toString());
                      }
                    },
                  ),
                ):const SizedBox(),
              ),
            ),

            SliverToBoxAdapter(child: Column(children: [
              FilterButtonWidget(
                type: _type,
                items: productProvider.productTypeList,
                onSelected: (selected) {
                  _type = selected;
                 category.getCategoryProductList(category.selectedSubCategoryId, type: _type);
                },
              ),

              ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height < 600 ?  size.height : size.height - 600),
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: category.categoryProductModel != null ? (category.categoryProductModel?.products?.isNotEmpty ?? false) ?
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisCount: isDesktop ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      mainAxisExtent: isDesktop ? 260 : 260,
                    ),
                    itemCount: category.categoryProductModel?.products?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return ProductCardWidget(
                        product: category.categoryProductModel!.products![index],
                        imageWidth: double.maxFinite,
                      );
                    },
                  ) : const NoDataWidget(isFooter: false)
                    : GridView.builder(
                    shrinkWrap: true,
                    itemCount: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisCount: isDesktop ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      mainAxisExtent: isDesktop ? 260 : 260,
                    ),
                    itemBuilder: (context, index) {
                      return const ProductShimmerWidget(isEnabled: true, isList: false, width: double.maxFinite);
                    },
                  ),
                ),
              ),

              if(isDesktop) const FooterWidget(),
            ])),

          ]);
        },
      ),
    );
  }

  SingleChildScrollView _categoryShimmer(BuildContext context, double height, CategoryProvider category) {
   final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(child: Column(children: [
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: !isDesktop && height < 600 ? height : height - 400),
        child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(children: [
          Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(height: 200, width: double.infinity, color: Theme.of(context).shadowColor),
          ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 10,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
              crossAxisCount: isDesktop ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
              mainAxisExtent: isDesktop ? 260 : 260,
            ),
            itemBuilder: (context, index) {
              return ProductShimmerWidget(isEnabled: category.categoryProductModel == null, isList: false, width: double.maxFinite);
            },
          ),
        ]))),
      ),
      if(isDesktop) const FooterWidget(),
    ]));
  }

  List<Tab> _tabs(CategoryProvider category) {
    List<Tab> tabList = [];
    tabList.add(const Tab(text: 'All'));
    for (var subCategory in category.subCategoryList!) {
      tabList.add(Tab(text: subCategory.name));
    }
    return tabList;
  }
}
