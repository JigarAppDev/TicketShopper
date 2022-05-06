import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_stopper/AndroidInAppPerchase/CheckInappPurchase.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/HomeScreen.dart';
import 'package:ticket_stopper/Screens/InAppPurchase.dart';
import 'package:ticket_stopper/Screens/LoginScreen.dart';
import 'inAppPurchaseAndroid.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String userToken;
  bool inAppStatus = false;

  @override
  void initState() {
    super.initState();
    initMethod();
  }

  getISSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    inAppStatus = preferences.getBool('inApp');
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  Future initMethod() async {
    await getData();
    if (Platform.isAndroid) {
      await checkInAppPurchase();
      if (userToken != null) {
        await apiCallGetData();
      }
      await getISSharedData();
    } else {
      if (userToken != null) {
        print('login token is:$userToken');
        await apiCallGetData();
      }
      await getISSharedData();
    }
  }

  savePurChase({int status}) {
    print('save Purcghase iap:--> $status');
    if (status == 0) {
      setState(() {
        print('save HomeScreen iap: true nu--> $status');
        saveSharedPrefData(value: false, key: 'inApp');
      });
    } else {
      setState(() {
        print('save HomeScreen iap: false nu --> $status');
        saveSharedPrefData(key: 'inApp', value: true);
      });
    }
  }

  Future apiCallGetData() async {
    try {
      Response response;
      var jsonData;
      Dio dio = Dio();
      var userToken = await getPrefData(key: 'user_token');
      print('Yes its InApp Api$userToken');
      var responseData;
      var data = {};

      response = await dio.post(
        GetFlag,
        data: data,
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      print('Response is$response');
      setState(() {
        jsonData = jsonDecode(response.toString());
        print('jsondata is $jsonData');
      });
      if (jsonData['status'].toString() == '1') {
        await savePurChase(status: jsonData['data']['is_purchase_profile']);
      } else {
        await savePurChase(status: jsonData['data']['is_purchase_profile']);
        Toasty.showtoast(jsonData['msg']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => userToken == null || userToken == 'null' || userToken == ''
            ? LoginScreen()
            : inAppStatus == true
                ? HomeScreen()
                : Platform.isAndroid
                    ? InAppPurchaseScreenAndroid()
                    : InAppPurchaseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('$iconURL/logo.png', height: 200, width: 200),
      ),
    );
  }

  Future getData() async {
    var user_token = await getPrefData(key: 'user_token');
    print('user_token');
    print(user_token);
    setState(() {
      userToken = user_token;
    });
  }
}
