import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sahakari/screens/otp_arguments.dart';
import 'package:sahakari/screens/content_screen.dart';
import 'package:sahakari/screens/user_arguments.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../utils/shared_prefs.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  static const routeName = '/validateOtp';

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var otp = '';
  String signature = "{{ app signature }}";

  @override
  void initState() {
    super.initState();
    _listenSmsCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  Widget build(BuildContext context) {
    final otpArguments =
    ModalRoute.of(context)!.settings.arguments as OtpScreenArguments;

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
                      'Validate Phone Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Enter the OTP received to the ${otpArguments.mobileNumber}',
                      style: const TextStyle(fontSize: 14),
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
                            color: Color.fromARGB(255, 238, 238, 238),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(0.13),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFieldPinAutoFill(
                        codeLength: 4,
                        onCodeChanged: (value) => {otp = value},
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          border: InputBorder.none,
                          hintText: 'Enter OTP',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Reference code: ${otpArguments.referenceCode}',
                      style: const TextStyle(fontSize: 12),
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
                          validateOTP(otpArguments).then((value) => {
                            if(value.success== true )
                              {
                                SharedPrefs().mobileNumber = otpArguments.mobileNumber,
                                SharedPrefs().mobileNo = value.mobileNo,
                                SharedPrefs().uniKey =value.uniqueID,
                                Navigator.pushNamedAndRemoveUntil(
                                  context, ContentScreen.routeName,
                                      (Route<dynamic> route) => false,arguments: value,
                                )
                              }
                            else{
                              _showMyDialog()
                            }


                          });
                        },
                        child: const Text(
                          'Validate',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
          )),
    );
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
                Text('Unable to validate OTP'),
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

  Future<ValidateResponse> validateOTP(OtpScreenArguments otpArguments) async {
    final response = await http.post(
      Uri.parse(
          'https://sahakariblazortest.azurewebsites.net/api/User/ValidateOTP'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String> {
        "MobileNo":otpArguments.mobileNumber.length == 13?otpArguments.mobileNumber.substring(3):otpArguments.mobileNumber,
        "OTPRef":otpArguments.referenceCode,
        "OTP":otp
      }),
    );

    if (response.statusCode == 200) {

      return ValidateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to validate OTP');
    }
  }
}


class ValidateResponse {
  final bool success;
  final String uniqueID;
  final String mobileNo;
  const ValidateResponse({required this.success,   required this.uniqueID,required this.mobileNo});
  factory ValidateResponse.fromJson(Map<String, dynamic> json) {
    return ValidateResponse(
        success:  json['success'],
        uniqueID: json['uniqueID'],
        mobileNo: json['mobileNo']
    );
  }
}