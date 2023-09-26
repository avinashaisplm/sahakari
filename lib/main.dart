import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sahakari/api/firebase-api.dart';
import 'package:sahakari/screens/content_screen.dart';
import 'package:sahakari/screens/otp_screen.dart';
import 'package:sahakari/screens/register_screen.dart';
import 'package:sahakari/utils/shared_prefs.dart';


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  await Firebase.initializeApp();
  await FirebaseAPI().initNotifications();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahakari App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute:  SharedPrefs().isRegistered          ? ContentScreen.routeName          : RegisterScreen.routeName,
      navigatorKey: navigatorKey,
      routes: {
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        OTPScreen.routeName: (context) => const OTPScreen(),
        ContentScreen.routeName: (context) => const ContentScreen(),
      },

    );
  }
}
