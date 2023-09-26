import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahakari/screens/otp_arguments.dart';
import 'package:sahakari/screens/otp_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;

import 'content_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneNumberTextController =
  TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   scheduleMicrotask(() {
  //     _tryPasteCurrentPhone();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.all(25),
                alignment: Alignment.center,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Image.asset(
                      'assets/logo.png',
                      width: 150,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Register',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Enter your phone number to get started, '
                          'we will send you an OTP to verify',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xffeeeeee),
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ],
                        border: Border.all(
                            width: 1, color: Colors.black.withOpacity(0.13)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Stack(
                        children: [
                          PhoneFieldHint(
                            controller: _phoneNumberTextController,
                            autoFocus: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        onPressed: () {
                          final phoneNumber = _phoneNumberTextController.text;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),

                              );
                            },
                          );
                          setState(() {
                            requestOTP(phoneNumber).then((otpResponse) => {
                              if ( otpResponse != null && otpResponse.isSmsSent)
                                {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    OTPScreen.routeName,
                                    arguments: OtpScreenArguments(
                                      otpResponse.otpReference,
                                      phoneNumber,
                                    ),
                                  )
                                }
                              else{
                                _showMyDialog().then((value) =>
                                    Navigator.of(context, rootNavigator: true).pop())
                              }
                            });
                          });
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                )),
          )),
    );
  }

  // Future _tryPasteCurrentPhone() async {
  //   // if (!mounted) return;
  //   // try {
  //   SmsAutoFill autofill = SmsAutoFill();
  //   String? selectedPhoneNumber = await autofill.hint;
  //   //   if (selectedPhoneNumber == null) return;
  //   //   if (!mounted) return;
  //   _phoneNumberTextController.value =
  //       TextEditingValue(text: selectedPhoneNumber ?? '');
  //   // } on PlatformException catch (e) {
  //   //   if (kDebugMode) {
  //   //     print('Failed to get mobile number because of: ${e.message}');
  //   //   }
  //   // }
  // }

  Future<OtpResponse?> requestOTP(String phoneNumber) async {
    final pNumber= phoneNumber.substring(phoneNumber.length-10);
    String sign = await SmsAutoFill().getAppSignature;
    final response = await http.post(
      Uri.parse(
          'https://sahakariblazortest.azurewebsites.net/api/User/RequestOTP'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String> {
        "MobileNo":pNumber,
        "UniqueId":sign,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return OtpResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Unable to get OTP'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class OtpResponse {
  final String otpReference;
  final String? error;
  final bool isSmsSent;
  final String mobileNo;
  final DateTime? expiry;
  const OtpResponse({required this.otpReference,  this.error , required this.isSmsSent,required this.mobileNo,required this.expiry});
  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
        otpReference: json['otpRef'],
        error: json['error'],
        isSmsSent: json['otpSent'],
        mobileNo:json['mobileNo'],
        expiry:DateTime.tryParse(json['expiry']));
  }
}