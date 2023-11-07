import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sahakari/utils/shared_prefs.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});
  static const routeName = '/content';
  @override
  State<ContentScreen> createState() => _ContentScreenState();


}

class _ContentScreenState extends State<ContentScreen> {
  late final WebViewController controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    registerFCM();
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            controller.runJavaScript('FlutterHelpers.setMobile("${SharedPrefs().mobileNo}","${SharedPrefs().uniKey}")');
          },
        ),
      )
      ..addJavaScriptChannel('unlock', onMessageReceived: (args){
if(args.message=='')
  {

  }
    })
      ..loadRequest(
        //Uri.parse('https://bolkirapp.azurewebsites.net/register'),
        Uri.parse('https://sahakariblazortest.azurewebsites.net/'),
      );
  }




  Future< bool> registerFCM() async
  {
    final response = await http.post(
      Uri.parse(
          'https://sahakariblazortest.azurewebsites.net/api/SMS/LogFCM'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String> {
        "MobileNo":SharedPrefs().mobileNumber,
        "FCMToken":SharedPrefs().fcmToken,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.zero,
                child:  AppBar(
                )
            ),
            body: Stack(
              children: [
                WebViewWidget(
                  controller: controller,
                ),
                if (loadingPercentage <100)
                  LinearProgressIndicator(
                    value: loadingPercentage / 100.0,
                  ),
              ],

            )
        )
    );

  }
}