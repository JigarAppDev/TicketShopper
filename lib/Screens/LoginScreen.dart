import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/GoogleSignIn.dart';
import 'package:ticket_stopper/Components/TextFieldVariant.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/ForgotPasswordScreen.dart';
import 'package:ticket_stopper/Screens/InAppPurchase.dart';
import 'package:ticket_stopper/Screens/SignUpScreen.dart';

import 'inAppPurchaseAndroid.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double latitude;
  double longitude;
  String login = "$apiURL/login";
  String thirdPartyLogin = "$apiURL/login_by_thirdparty";
  String deviceToken;
  int deviceType;
  var jsonData;
  var deviceID;
  var userToken;
  var userID;
  bool _loading = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> getDeviceTypeId() async {
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      deviceType = 1;
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceID = androidDeviceInfo.androidId;
      print('Device Type: ${deviceType.toString()}, ' + 'Device ID: $deviceID');
    } else {
      deviceType = 2;
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor;
      print('Device Type: ${deviceType.toString()}, ' + 'Device ID: $deviceID');
    }
  }

  getDeviceToken(int len) {
    var random = Random();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    deviceToken = base64UrlEncode(values);
    print('Device Token: ' + deviceToken);
  }

  Response response;
  Dio dio = Dio();

  void loginUser() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        login,
        data: {
          'email': email.text,
          'password': password.text,
          'device_id': deviceID,
          'device_token': deviceToken,
          'device_type': deviceType,
          'latitude': '0.00',
          'longitude': '0.00',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
          print('jsondata----->Simple Login $jsonData');
        });
        if (jsonData['status'] == 1) {
          setUserData();
          await apiCallGetData(jsonData['data']['user_token']);
          await getISSharedData();
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getISSharedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool inAppStatus = preferences.getBool('inApp') ?? false;

    print('In App Purchase in Splash is IN LOFGIN $inAppStatus');
    if (inAppStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Platform.isAndroid ? InAppPurchaseScreenAndroid() : InAppPurchaseScreen()));
    }
  }

  savePurChase({int status}) {
    print('save Purcghase iap:--> $status');
    if (status == 0) {
      setState(() {
        saveSharedPrefData(value: false, key: 'inApp');
      });
    } else {
      setState(() {
        saveSharedPrefData(key: 'inApp', value: true);
      });
    }
  }

  void loginByThirdParty({String fgName, String fgEmail, String thirdPartyID, String profilePic, loginType}) async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        thirdPartyLogin,
        data: {
          'name': fgName,
          'email': fgEmail,
          'thirdparty_id': thirdPartyID,
          'login_type': loginType,
          'device_id': deviceID,
          'profile_pic': profilePic,
          'device_token': deviceToken,
          'device_type': deviceType,
          'latitude': '0.00',
          'longitude': '0.00',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
          print('jsondata:$jsonData');
        });
        if (jsonData['status'] == 1) {
          print(jsonData['data']['profile_pic'].toString());
          setUserData();
          await apiCallGetData(jsonData['data']['user_token']);
          await getISSharedData();

          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 13) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  var userData;
  int type;

  Future apiCallGetData(String token) async {
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
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response is$response');
      setState(() {
        jsonData = jsonDecode(response.toString());
      });
      if (jsonData['status'].toString() == '1') {
        print('iff.......Condition');
        await savePurChase(status: jsonData['data']['is_purchase_profile']);
      } else {
        Toasty.showtoast(jsonData['msg']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      setState(() {
        type = 1;
      });

      userData = await FacebookAuth.instance.getUserData();
      print('FB LOGIN DATA >>>>>>>>>>>>>>>> ' + userData.toString());
      var fgName = userData['name'];
      var fgEmail = userData['email'];
      var thirdPartyID = userData['id'];
      var profilePic = userData['picture']['data']['url'];

      if (fgName != null && fgEmail != null && thirdPartyID != null && profilePic != null) {
        loginByThirdParty(
          fgName: fgName,
          fgEmail: fgEmail,
          thirdPartyID: thirdPartyID,
          profilePic: profilePic,
          loginType: '1',
        );
      }
    } else {}
  }

  Future appleSignIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    String username = credential.givenName == null ? 'user@' + credential.userIdentifier.substring(0, 4) : credential.givenName;
    var thirdpartyId = credential.userIdentifier;
    var userEmail = credential.email == null ? credential.userIdentifier.substring(0, 8) + '@gmail.com' : credential.email;
    var profilepic = '';

    loginByThirdParty(
      fgName: username,
      fgEmail: userEmail,
      thirdPartyID: thirdpartyId,
      profilePic: profilepic,
      loginType: '3',
    );
  }

  Future setUserData() async {
    await setPrefData(key: 'user_id', value: jsonData['data']['id'].toString());
    await setPrefData(key: 'user_token', value: jsonData['data']['user_token'].toString());
    await setPrefData(key: 'device_id', value: deviceID);
    await setPrefData(key: 'name', value: type == 1 || type == 2 ? jsonData['data']['name'].toString() : '');
    await setPrefData(key: 'email', value: jsonData['data']['email'].toString());
    await setPrefData(key: 'profile_pic', value: jsonData['data']['profile_pic']);
    await setPrefData(key: 'first_name', value: jsonData['data']['first_name']);
    await setPrefData(key: 'last_name', value: jsonData['data']['last_name']);
  }

  @override
  void initState() {
    super.initState();
    getDeviceToken(200);
    getDeviceTypeId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('$iconURL/logo.png', height: 90),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultText(text: 'Login'),
                          AppTextField(
                            controller: email,
                            labelText: 'Email',
                            input: TextInputType.emailAddress,
                          ),
                          AppPassField(
                            controller: password,
                            labelText: 'Password',
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              child: AppText(text: 'Forgot Password?', color: Colors.grey.shade600, fontSize: 12),
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          CustomSubmitButton(
                            text: 'Login',
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_validate(email: email.text, password: password.text)) {
                                loginUser();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: AppText(text: 'Don\'t have an account? Sign up', color: kPrimaryColor2, fontSize: 12),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                  },
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: kPrimaryColor2, thickness: 1)),
                      AppText(text: '  Or  ', color: kPrimaryColor2, fontSize: 12),
                      Expanded(child: Divider(color: kPrimaryColor2, thickness: 1)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Column(
                    children: [
                      SocialMediaSubmitButton(
                          text: 'Connect with Facebook',
                          icon: 'fb.png',
                          buttonColor: kFacebookColor,
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _login();
                          }),
                      SizedBox(height: 10),
                      SocialMediaSubmitButton(
                        text: 'Connect with Google',
                        icon: 'google.png',
                        buttonColor: kGooglePlusColor,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          signInWithGoogle().then((result) {
                            if (result != null) {
                              setState(() {
                                type = 2;
                              });
                              loginByThirdParty(
                                fgName: fgName,
                                fgEmail: fgEmail,
                                thirdPartyID: thirdPartyID,
                                profilePic: profilePic,
                                loginType: '2',
                              );
                            }
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      Platform.isIOS
                          ? SignInWithAppleButton(
                              onPressed: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                appleSignIn();
                              },
                            )
                          : Container(),
                      // SocialMediaSubmitButton(
                      //     text: 'Connect with Apple',
                      //     icon: 'apple.png',
                      //     textColor: Colors.black,
                      //     buttonColor: Colors.white,
                      //     onPressed: () {
                      //       FocusScope.of(context).requestFocus(FocusNode());
                      //       appleSignIn();
                      //     }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validate({String email, String password}) {
    if (email.isEmpty && password.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (email.isEmpty) {
      Toasty.showtoast('Please Enter Your Email Address');
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      Toasty.showtoast('Please Enter Valid Email Address');
      return false;
    } else if (password.isEmpty) {
      Toasty.showtoast('Please Enter Your Password');
      return false;
    } else {
      return true;
    }
  }
}
