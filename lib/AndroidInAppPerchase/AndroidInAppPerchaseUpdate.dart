import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ticket_stopper/Screens/HomeScreen.dart';
import '../Constant.dart';
import 'package:ticket_stopper/Components/process_indicator.dart';

void updateAndroidPurchase({BuildContext context, Circle progress}) async {
  try {
    Response response;
    var jsonData;
    Dio dio = Dio();
    var userToken = await getPrefData(key: 'user_token');
    var data = {'is_purchase_profile': '1'};

    response = await dio.post(
      UPDATE_SUBSCRIPTION,
      data: data,
      options: Options(
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $userToken',
        },
      ),
    );
    jsonData = jsonDecode(response.toString());
    print('Json Data is $jsonData');

    if (jsonData['status'].toString() == '1') {
      saveSharedPrefData(key: 'switch', value: true);
      progress.hide(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print('else.......Condition');
      await saveSharedPrefData(key: 'inApp', value: true);
      Toasty.showtoast(jsonData['msg']);
      progress.hide(context);
    }
  } catch (e) {
    print(e.toString());
  }
}

void updatePurchaseState(
    {BuildContext context, Circle progress, String purchaseState}) async {
  try {
    Response response;
    var jsonData;
    Dio dio = Dio();
    var userToken = await getPrefData(key: 'user_token');
    var data = {'is_purchase_profile': purchaseState};

    response = await dio.post(
      UPDATE_SUBSCRIPTION,
      data: data,
      options: Options(
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $userToken',
        },
      ),
    );
    jsonData = jsonDecode(response.toString());
    print('Json Data is $jsonData');

    if (jsonData['status'].toString() == '1') {
      progress.hide(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
      Toasty.showtoast(jsonData['msg']);
    } else {
      Toasty.showtoast(jsonData['msg']);
      progress.hide(context);
    }
  } catch (e) {
    print(e.toString());
  }
}
