import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/CachedImageContainer.dart';
import 'package:ticket_stopper/Components/InfoLabel.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/ChangePasswordScreen.dart';
import 'package:ticket_stopper/Screens/EditProfile.dart';

class UserProfileTab extends StatefulWidget {
  @override
  _UserProfileTabState createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  String logout = "$apiURL/logout";

  var deviceID;
  var userToken;
  var userName;
  var eMail;
  var profilePic;
  var firstName;
  var lastName;
  bool _loading = false;

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    var device_id = await getPrefData(key: 'device_id');
    var name = await getPrefData(key: 'name');
    var email = await getPrefData(key: 'email');
    var first_name = await getPrefData(key: 'first_name');
    var last_name = await getPrefData(key: 'last_name');
    var profile_pic = await getPrefData(key: 'profile_pic');

    print('user_token');
    print(user_token);
    setState(() {
      userToken = user_token;
      deviceID = device_id;
      userName = name;
      eMail = email;
      firstName = first_name;
      lastName = last_name;
      profilePic = profile_pic;
    });
  }

  Response response;
  Dio dio = Dio();
  var jsonData;
  void logoutByAPI() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        logout,
        data: {'device_id': deviceID},
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        clearPrefData();
        jsonData = jsonDecode(response.toString());
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
          Toasty.showtoast(jsonData['message']);
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      progressIndicator: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Row(
                    children: [
                      CachedImageContainer(
                        image: profilePic == "null" || profilePic == null || profilePic == "" ? '' : 'http://143.198.63.52/ticket_stopper/$profilePic',
                        width: 80,
                        height: 80,
                        circular: 8,
                        placeholder: '$iconURL/user-square.png',
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(text: '${firstName ?? ''} ${lastName ?? ''}', fontSize: 18),
                              ],
                            ),
                            AppText(
                              text: '${eMail ?? ''}',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            InfoLabel(
              text: 'My Information',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
              },
            ),
            SizedBox(height: 10),
            InfoLabel(
              text: 'Change Password',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
              },
            ),
            SizedBox(height: 10),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: AppText(text: 'Log Out', color: Colors.grey, fontSize: 12),
                ),
              ),
              onTap: () {
                logoutByAPI();
              },
            ),
          ],
        ),
      ),
    );
  }
}
