import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/helper/email_checker_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_restaurant/common/widgets/footer_widget.dart';
import 'package:flutter_restaurant/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/code_picker_widget.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController? _emailController;
  TextEditingController? _phoneNumberController;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.clearVerificationMessage();
    authProvider.setIsLoading = false;
    authProvider.setIsPhoneVerificationButttonLoading = false;

    _countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final ConfigModel configModel =  Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBarWidget()) : CustomAppBarWidget(context: context, title: getTranslated('forgot_password', context))) as PreferredSizeWidget?,
      body: Center(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          Center(child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Container(
              width: width > 700 ? 700 : width,
              padding: width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
              decoration: width > 700 ? BoxDecoration(
                color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {


                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 55),
                      
                      Center(
                        child: Image.asset(
                          Images.closeLock,
                          width: 142,
                          height: 142,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      configModel.phoneVerification!?
                      Center(child: Text(
                        getTranslated('please_enter_your_mobile_number_to', context)!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                      )):
                      Center(
                          child: Text(
                            getTranslated('please_enter_your_number_to', context)!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                          )),

                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 80),
                            Text(configModel.phoneVerification!
                                ?  getTranslated('mobile_number', context)! : getTranslated('email', context)!,
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            configModel.phoneVerification! ? Row(children: [
                              CodePickerWidget(
                                onChanged: (CountryCode countryCode) {
                                  _countryCode = countryCode.dialCode;
                                },
                                initialSelection: _countryCode,
                                favorite: [_countryCode!],
                                showDropDownButton: true,
                                padding: EdgeInsets.zero,
                                textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
                                showFlagMain: true,
                              ),

                              Expanded(child: CustomTextFieldWidget(
                                hintText: getTranslated('number_hint', context),
                                isShowBorder: true,
                                controller: _phoneNumberController,
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                              ),),
                            ]) : CustomTextFieldWidget(
                              hintText: getTranslated('demo_gmail', context),
                              isShowBorder: true,
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 24),

                            !auth.isForgotPasswordLoading && !auth.isPhoneNumberVerificationButtonLoading ? CustomButtonWidget(
                              btnTxt: getTranslated('send', context),
                              onTap: () async {
                                String? phoneOrEmail;

                                if(configModel.phoneVerification!) {
                                  if(_phoneNumberController!.text.trim().isNotEmpty) {
                                    phoneOrEmail = '$_countryCode${_phoneNumberController!.text.trim()}';

                                  }else{
                                    showCustomSnackBarHelper(getTranslated('enter_phone_number', context));
                                  }

                                }else{
                                  if(_emailController!.text.isEmpty) {
                                    showCustomSnackBarHelper(getTranslated('enter_email_address', context));

                                  }else if (EmailCheckerHelper.isNotValid(_emailController!.text.trim())) {
                                    showCustomSnackBarHelper(getTranslated('enter_valid_email', context));

                                  }else{
                                    phoneOrEmail = _emailController!.text;

                                  }
                                }

                                if(phoneOrEmail != null) {
                                  ResponseModel? response =  await auth.forgetPassword(config: configModel, phoneOrEmail: phoneOrEmail);

                                  if(response != null && response.isSuccess) {
                                    RouterHelper.getVerifyRoute('forget-password', phoneOrEmail);

                                  }else if(response != null && !response.isSuccess) {
                                    showCustomSnackBarHelper(response.message);

                                  }
                                }

                              },
                            ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )),

          if(ResponsiveHelper.isDesktop(context)) const FooterWidget()
        ]),
      )),
    );
  }
}
