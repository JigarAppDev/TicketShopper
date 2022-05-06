import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/CustomTextField.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Methods.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController password = TextEditingController();
  final TextEditingController newpass = TextEditingController();
  final TextEditingController repass = TextEditingController();

  String changePassword = '$apiURL/change_password';
  Response response;
  Dio dio = Dio();
  var jsonData;
  var userToken;
  bool _loading = false;

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });
  }

  Future changePass() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        changePassword,
        data: {'current_password': password.text, 'new_password': newpass.text},
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        setState(() {
          _loading = false;
          jsonData = jsonDecode(responseData);
        });
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          Toasty.showtoast(jsonData['message']);
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Change Password'),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    UnLabeledPassField(hintText: "Current Password", controller: password),
                    UnLabeledPassField(hintText: "New Password", controller: newpass),
                    UnLabeledPassField(hintText: "Confirm Password", controller: repass),
                  ],
                ),
              ),
              CustomSubmitButton(
                text: 'Submit',
                minWidth: 280,
                onPressed: () {
                  if (_validate(currentPassword: password.text, newPassword: newpass.text, rePassword: repass.text)) {
                    changePass();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validate({String currentPassword, String newPassword, String rePassword}) {
    if (currentPassword.isEmpty && newPassword.isEmpty && rePassword.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (currentPassword.isEmpty) {
      Toasty.showtoast('Please Enter Your Current Password');
      return false;
    } else if (newPassword.isEmpty) {
      Toasty.showtoast('Please Enter Your New Password');
      return false;
    } else if (rePassword.isEmpty) {
      Toasty.showtoast('Please Re-Enter Your Password');
      return false;
    } else if (newPassword != rePassword) {
      Toasty.showtoast('Password do not Match');
      return false;
    } else {
      return true;
    }
  }
}
