import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPrimaryColor1 = Color(0xFFFCC004);
const kPrimaryColor2 = Color(0xFF5D1911);
const kFacebookColor = Color(0xFF2672CA);
const kGooglePlusColor = Color(0xFFFD3951);
const kBGColor = Color(0xFFF0EFEF);

final String iconURL = 'assets/icons';
final String apiURL = 'http://143.198.63.52/ticket_stopper/api';
final BASE_URL = 'http://143.198.63.52/ticket_stopper/api/';
const ADD_RECIEPT = 'http://143.198.63.52/ticket_stopper/api/add_reciept';
const UPDATE_SUBSCRIPTION = 'http://143.198.63.52/ticket_stopper/api/update_subscription';
const GetFlag = 'http://143.198.63.52/ticket_stopper/api/edit_profile';

final kUnderlineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey));

final kOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.white),
  borderRadius: BorderRadius.circular(8),
);

class Toasty {
  static showtoast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }
}

Future saveSharedPrefData({String key, bool value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
}

const Color kThemeColor = Color(0xfffcc004);
Future setPrefData({String key, String value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future getPrefData({String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key);
  return data;
}

Future getPrefIntData({String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getInt(key);
  return data;
}

Future clearPrefData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
