import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_restaurant/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/search/providers/search_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchBarFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    final SearchProvider searchProvider = Provider.of<SearchProvider>(context, listen: false);

    searchProvider.initHistoryList();
    searchProvider.onChangeAutoCompleteTag();

    _searchBarFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _searchBarFocus.removeListener(_onFocusChange);
  }

  void _onFocusChange() {
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);


    return Scaffold(
      appBar: PreferredSize(preferredSize: const Size.fromHeight(100), child: ResponsiveHelper.isDesktop(context) ? const WebAppBarWidget() :
      Consumer<SearchProvider>(
          builder: (context, searchProvider, _) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: Dimensions.radiusSmall, spreadRadius: 1)],
            ),
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeExtraLarge + Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeSmall,
            ),
            child: Row(children: [

              IconButton(
                onPressed: ()=> context.pop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),

              Expanded(child: CustomTextFieldWidget(
                hintText: getTranslated('search_items_here', context),
                isShowBorder: true,
                controller: _searchController,
                focusNode: _searchBarFocus,
                inputAction: TextInputAction.search,
                isIcon: true,
                suffixIconUrl: Images.closeSvg,
                isShowSuffixIcon: true,
                onSuffixTap: () => _searchController.text = '',
                onSubmit:  (text) {
                  if (_searchController.text.isNotEmpty) {
                    searchProvider.saveSearchAddress(_searchController.text);
                    searchProvider.searchProduct(name: _searchController.text, offset: 1, context: context);
                    RouterHelper.getSearchResultRoute(_searchController.text.replaceAll(' ', '-'));
                  }
                },
                onChanged: ResponsiveHelper.isDesktop(context)
                    ? null : (text)=> searchProvider.onChangeAutoCompleteTag(searchText: text),
              )),

            ]),
          );
        }
      )),
      body: SafeArea(child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          /// for search bar


          /// for search result and history
          Expanded(child: SingleChildScrollView(
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: _searchController.text.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const SizedBox(height: Dimensions.paddingSizeDefault),

             if((searchProvider.autoCompletedName?.isNotEmpty ?? false)) SizedBox(child: ListView.builder(
                itemCount: min(searchProvider.autoCompletedName?.length ?? 0, 10),
               primary: false,
                shrinkWrap: true,
                // reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    searchProvider.searchProduct(name: searchProvider.autoCompletedName?[index] ?? '', offset: 1, context: context);
                    RouterHelper.getSearchResultRoute(searchProvider.autoCompletedName?[index].replaceAll(' ', '-') ?? '');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.history, size: Dimensions.paddingSizeDefault, color: Theme.of(context).hintColor),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Text(
                          searchProvider.autoCompletedName?[index] ?? '',
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                        ),
                      ]),

                      Icon(CupertinoIcons.arrow_up_left, size: Dimensions.fontSizeExtraLarge, color: Theme.of(context).hintColor),

                    ]),
                  ),
                ),
              )),


            ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              /// for resent search section
              const SizedBox(height: Dimensions.paddingSizeDefault),
              searchProvider.historyList.isNotEmpty ?
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(getTranslated('recent_searches', context)!, style: rubikBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),

                  InkWell(
                    onTap: searchProvider.clearSearchAddress,
                    child: Text(getTranslated('clear_all', context)!, style: rubikMedium.copyWith(
                      color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall,
                    )),
                  ),
                ]) : const SizedBox.shrink(),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              /// for recent search list section
              SizedBox(child: ListView.builder(
                itemCount: min(searchProvider.historyList.length, 10),
                primary: false,
                shrinkWrap: true,
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Column(children: [

                  InkWell(
                    onTap: () {
                      searchProvider.searchProduct(name: searchProvider.historyList[index], offset: 1, context: context,);
                      RouterHelper.getSearchResultRoute(searchProvider.historyList[index].replaceAll(' ', '-'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text(
                          searchProvider.historyList[index],
                          style: rubikMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                        ),

                        InkWell(
                          onTap: () {
                            searchProvider.removeHistoryItemByIndex(index);
                          },
                          child: Icon(Icons.close, size: Dimensions.fontSizeExtraLarge, color: Theme.of(context).hintColor),
                        ),

                      ]),
                    ),
                  ),

                  Divider(height: 0, color: Theme.of(context).dividerColor.withOpacity(0.3)),

                ]),
              )),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              /// for popular tags
              if(searchProvider.productSearchName?.isNotEmpty ?? false) Text(getTranslated('popular_tags', context)!, style: rubikBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomSingleChildListWidget(
                isWrap: true,
                wrapSpacing: Dimensions.paddingSizeSmall,
                itemCount: min((searchProvider.popularTag?.length ?? 0), 12),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: InkWell(
                      onTap: () {
                        searchProvider.searchProduct(
                          name: searchProvider.popularTag?[index] ?? '',
                          offset: 1, context: context,
                        );
                        RouterHelper.getSearchResultRoute(searchProvider.popularTag?[index].replaceAll(' ', '-') ?? '');
                      },
                      highlightColor: Colors.transparent,
                      child: Chip(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        backgroundColor: Colors.transparent,
                        label: Text(searchProvider.popularTag?[index] ?? '', style: rubikRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        )),
                        deleteIcon: Icon(Icons.close, color: Theme.of(context).hintColor, size: Dimensions.fontSizeLarge),
                        onDeleted: ()=> searchProvider.removePopularTagByIndex(index),
                        surfaceTintColor: Colors.transparent,
                        side: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2), width: 0.5),
                      ),
                    ),
                  );
                },
              ),


              const SizedBox(height: Dimensions.paddingSizeLarge),

              /// for recommended
              Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
                return (categoryProvider.categoryList?.isNotEmpty ?? false) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getTranslated('recommended', context)!, style: rubikBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: Dimensions.paddingSizeDefault,
                      mainAxisSpacing: Dimensions.paddingSizeDefault,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categoryProvider.categoryList?.length,
                    itemBuilder: (context, index) => Material(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () => RouterHelper.getCategoryRoute(categoryProvider.categoryList![index]),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                            shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              child: CustomImageWidget(
                                image: '${splashProvider.baseUrls?.categoryImageUrl}/${categoryProvider.categoryList?[index].image}',
                                placeholder: Images.placeholderImage,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text(
                            '${categoryProvider.categoryList?[index].name}',
                            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                ]) : const SizedBox();
              }),

            ]),
          )),

        ]),
      )))),
    );
  }
}
