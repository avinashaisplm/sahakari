import 'package:shared_preferences/shared_preferences.dart';

const String keyMobileNumber = "mobileNumber";

class SharedPrefs {
  static  late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get mobileNumber => _sharedPrefs.getString(keyMobileNumber) ?? "";

  set mobileNumber(String value) {
    value = value.length == 13 ?value.substring(3):value;
    _sharedPrefs.setString(keyMobileNumber, value);
  }

  String get uniKey => _sharedPrefs.getString('uniKey') ?? "";
  set uniKey(String value) {
    _sharedPrefs.setString('uniKey', value);
  }


  String get fcmToken => _sharedPrefs.getString('fcmToken') ?? "";
  set fcmToken(String value)
  {
    _sharedPrefs.setString('fcmToken', value);
  }

  bool get isRegistered => _sharedPrefs.getString(keyMobileNumber) != null;



String get mobileNo => _sharedPrefs.getString('mobileNo') ?? "";

set mobileNo(String value) {
  _sharedPrefs.setString('mobileNo', value);
}
}