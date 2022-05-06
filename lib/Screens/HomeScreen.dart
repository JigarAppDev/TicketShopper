import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/AddTicketButtonTab.dart';
import 'package:ticket_stopper/Screens/FirstBottomTab.dart';
import 'package:ticket_stopper/Screens/UserProfileTab.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(left: 50),
          child: Image.asset('$iconURL/clipboard1.png', height: 26),
        ),
        label: 'Receipts',
        activeIcon: Padding(
          padding: EdgeInsets.only(left: 50),
          child: Image.asset('$iconURL/clipboard2.png', height: 26),
        ),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.remove, color: Colors.transparent), label: ''),
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(right: 50),
          child: Image.asset('$iconURL/user1.png', height: 26),
        ),
        label: 'Profile',
        activeIcon: Padding(
          padding: EdgeInsets.only(right: 50),
          child: Image.asset('$iconURL/user2.png', height: 26),
        ),
      ),
    ];
  }

  PageController pageController = PageController(
    initialPage: 0,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        _onItemTapped(index);
      },
      children: <Widget>[
        FirstBottomTab(),
        AddTicketButtonTab(),
        UserProfileTab(),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.jumpToPage(index);
      Platform.isIOS ? Vibration.cancel() : Vibration.vibrate(duration: 30);
    });
  }

  @override
  void initState() {
    apiCallGetData();
    super.initState();
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
      setState(() {
        jsonData = jsonDecode(response.toString());
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Ticket Stopper',
            style: TextStyle(fontSize: 18, fontFamily: 'Acaslon', fontWeight: FontWeight.w700, color: kPrimaryColor2),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            pageController.jumpToPage(1);
            Platform.isIOS ? Vibration.cancel() : Vibration.vibrate(duration: 50);
          },
          child: Icon(Icons.add, size: 34, color: kPrimaryColor2),
          backgroundColor: Colors.white,
          elevation: 2,
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          // height: MediaQuery.of(context).size.height * 0.075,
          child: BottomNavigationBar(
            backgroundColor: kPrimaryColor1,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: buildBottomNavBarItems(),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
        body: buildPageView(),
      ),
    );
  }
}
