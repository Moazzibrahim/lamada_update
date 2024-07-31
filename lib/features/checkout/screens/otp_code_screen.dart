// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

import 'package:flutter_restaurant/features/auth/screens/login_screen.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final String controller;
  const ForgetPasswordScreen({super.key, required this.controller});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Future<void> _sendForgetPasswordRequest() async {
    setState(() {
      _isLoading = true;
    });

    final String user = _controller.text;
    const String url =
        'https://App.lamadafood.com/api/v1/auth/otp_customer_confermation';

    try {
      if (user.isEmpty) {
        throw Exception('OTP code cannot be empty');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'otp': user,
          'phone': widget.controller,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("OTP verification successful");

          RouterHelper.getDashboardRoute('home',
              action: RouteAction.pushNamedAndRemoveUntil);
          showCustomSnackBarHelper(
              getTranslated('registration_successful', Get.context!),
              isError: false);
        } else {
          throw Exception(responseBody['faild'] ?? 'Failed to verify OTP');
        }
      } else {
        throw Exception(
            'Failed to send OTP. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'OTP ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            RichText(
              text: TextSpan(
                text:
                    'Don\'t worry! That happens. Please register your phone to which we will send your One Time Password ',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '(OTP)',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Pinput(
              controller: _controller,
              length: 5,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 25),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      onPressed: _sendForgetPasswordRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 130,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
