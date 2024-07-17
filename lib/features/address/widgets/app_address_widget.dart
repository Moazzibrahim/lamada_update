import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/features/address/domain/models/input_model.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/address/screens/select_location_screen.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_textfield_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AppAddressWidget extends StatefulWidget {
  const AppAddressWidget({
    super.key,
    required this.inputModel,
    required this.onUpdateAddress,
  });

  final InputModel inputModel;
  final void Function(bool) onUpdateAddress;

  @override
  State<AppAddressWidget> createState() => _AppAddressWidgetState();
}

class _AppAddressWidgetState extends State<AppAddressWidget> {

  late GoogleMapController controller;

  @override
  Widget build(BuildContext context) {

    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);


    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.inputModel.locationTextController.text = locationProvider.address ?? '';
        });

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color:ColorResources.cardShadowColor.withOpacity(0.2), blurRadius: Dimensions.radiusDefault)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge), child: Text(
              getTranslated('delivery_address', context)!,
              style: rubikMedium.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault),
            )),

            Text(getTranslated('address_type', context)!, style: rubikRegular.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            SizedBox(height: 30, child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: locationProvider.getAllAddressType.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () => locationProvider.updateAddressIndex(index, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.only(right: 17),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : ColorResources.borderColor),
                    color: locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor
                        : themeProvider.darkTheme ? Theme.of(context).cardColor : Colors.white.withOpacity(0.8),
                  ),
                  child: Row(children: [
                    CustomAssetImageWidget(
                      locationProvider.getAllAddressType[index].toLowerCase() == 'home' ? Images.houseSvg
                          : locationProvider.getAllAddressType[index].toLowerCase() == 'workplace' ? Images.buildingSvg : Images.buildingsSvg,
                      width: Dimensions.fontSizeSmall,
                      height: Dimensions.fontSizeSmall,
                      color: locationProvider.selectAddressIndex == index ? Colors.white : Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text(
                      getTranslated(locationProvider.getAllAddressType[index].toLowerCase(), context)!,
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: locationProvider.selectAddressIndex == index ? Colors.white : Theme.of(context).hintColor,
                      ),
                    ),
                  ]),
                ),
              ),
            )),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            /// Map section
            SizedBox(
              height: ResponsiveHelper.isMobile() ? 130 : 250,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                child: Stack(clipBehavior: Clip.none, children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: widget.inputModel.isEnableUpdate
                          ? LatLng(double.parse(widget.inputModel.address!.latitude!), double.parse(widget.inputModel.address!.longitude!))
                          : LatLng(locationProvider.position.latitude  == 0.0
                          ? double.parse(widget.inputModel.branches[0]!.latitude!): locationProvider.position.latitude, locationProvider.position.longitude == 0.0
                          ? double.parse(widget.inputModel.branches[0]!.longitude!): locationProvider.position.longitude),
                      zoom: 8,
                    ),
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: false,
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    onCameraIdle: () {

                      if(widget.inputModel.address != null && !widget.inputModel.fromCheckout) {
                        locationProvider.updatePosition(locationProvider.cameraPosition, true, null, context, true);
                        // _updateAddress = true;
                        widget.onUpdateAddress(true);
                      }else {
                        if(widget.inputModel.updateAddress) {
                          locationProvider.updatePosition(locationProvider.cameraPosition, true, null, context, true);
                        }else {
                          // _updateAddress = true;
                          widget.onUpdateAddress(true);
                        }
                      }
                    },
                    onCameraMove: ((position) {
                      locationProvider.cameraPosition = position;

                    }),

                    onMapCreated: (GoogleMapController createdController) {
                      controller = createdController;
                      if (!widget.inputModel.isEnableUpdate) {
                        locationProvider.checkPermission(() {
                          locationProvider.getCurrentLocation(context, true, mapController: controller);
                        });
                      }
                    },
                  ),

                  locationProvider.loading
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                      : const SizedBox(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child: const CustomAssetImageWidget(
                      Images.marker,
                      width: 25,
                      height: 35,
                    ),
                  ),

                  Positioned(bottom: 10, right: 0, child: InkWell(
                    onTap: () => locationProvider.checkPermission(() {
                      locationProvider.getCurrentLocation(context, true, mapController: controller);
                    }),
                    child: Container(
                      width: 30, height: 30,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        color: Colors.white,
                      ),
                      child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  )),

                  Positioned(top: 10, right: 0, child: InkWell(
                    onTap:() async {
                     await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelectLocationScreen(googleMapController: controller),
                      ));
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            /// for Address Field
            ProfileTextFieldWidget(
              isShowBorder: true,
              controller: widget.inputModel.locationTextController,
              focusNode: widget.inputModel.addressNode,
              nextFocus: widget.inputModel.stateNode,
              inputType: TextInputType.streetAddress,
              capitalization: TextCapitalization.words,
              level: getTranslated('delivery_address', context)!,
              hintText: getTranslated('afghanistan', context)!,
              isFieldRequired: false,
              isShowPrefixIcon: true,
              prefixIconUrl: Images.locationPlacemarkSvg,
              onValidate: (value) => value!.isEmpty
                  ? '${getTranslated('please_enter', context)!} ${getTranslated('delivery_address', context)!}' : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            /// for Street Field
            ProfileTextFieldWidget(
              isShowBorder: true,
              controller: widget.inputModel.streetNumberController,
              focusNode: widget.inputModel.stateNode,
              nextFocus: widget.inputModel.houseNode,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              capitalization: TextCapitalization.words,
              level: getTranslated('Address_details', context)!,
              hintText: getTranslated('address_line_02', context)!,
              isFieldRequired: false,
              isShowPrefixIcon: true,
              prefixIconUrl: Images.streetSvg,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              '${getTranslated('building', context)}/ ${getTranslated('floor', context)} ${getTranslated('number', context)}',
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              /// for House Field
              Expanded(child: ProfileTextFieldWidget(
                isShowBorder: true,
                controller: widget.inputModel.houseNumberController,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
                level: getTranslated('house_no', context)!,
                isFieldRequired: false,
                hintText: getTranslated('ex_2', context),
                focusNode: widget.inputModel.houseNode,
                nextFocus: widget.inputModel.floorNode,
              )),
              const SizedBox(width: Dimensions.paddingSizeLarge),

              /// for Floor Field
              Expanded(child: ProfileTextFieldWidget(
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
                level: getTranslated('flat_no', context)!,
                isFieldRequired: false,
                hintText: getTranslated('ex_2b', context),
                focusNode: widget.inputModel.floorNode,
                nextFocus: widget.inputModel.nameNode,
                controller: widget.inputModel.florNumberController,
              )),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),


          ]),
        );
      },
    );
  }
}
