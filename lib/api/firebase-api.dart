import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sahakari/main.dart';
import 'package:sahakari/screens/content_screen.dart';
import 'package:sahakari/utils/shared_prefs.dart';

class FirebaseAPI
{
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    SharedPrefs().fcmToken =fcmToken==null?'':fcmToken;
    print('Token: $fcmToken');
    initPushNotifications();
  }


  void handleMessage(RemoteMessage? message)
  {
    if(message == null)
    {
      return;
    }
    navigatorKey.currentState?.pushNamed(ContentScreen.routeName,  arguments: message,);
  }

  Future initPushNotifications() async
  {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
   // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }
}

