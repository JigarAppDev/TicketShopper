import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/TextFieldVariant.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  ResetPasswordScreen({this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String text = "";

  final TextEditingController otp = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confpass = TextEditingController();

  String resetPassword = "$apiURL/reset_password";
  Response response;
  Dio dio = Dio();
  bool _loading = false;

  void resetPass() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        resetPassword,
        data: {'email': widget.email, 'new_pass': password.text, 'temp_pass': otp.text},
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        var responseData = response.data;
        var jsonData = jsonDecode(responseData);
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          Toasty.showtoast(jsonData['message']);
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
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
                // SizedBox(height: MediaQuery.of(context).size.height * 0.16),
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
                          DefaultText(text: 'Enter Your OTP'),
                          AppTextField(
                            controller: otp,
                            labelText: 'Enter OTP',
                            input: TextInputType.numberWithOptions(decimal: true, signed: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[.]')),
                            ],
                            onChanged: (String newVal) {
                              if (newVal.length <= 6) {
                                text = newVal;
                              } else {
                                otp.text = text;
                              }
                            },
                          ),
                          AppPassField(
                            controller: password,
                            labelText: 'New Password',
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                          ),
                          AppPassField(
                            controller: confpass,
                            labelText: 'Confirm New Password',
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                          ),
                          SizedBox(height: 40),
                          CustomSubmitButton(
                            text: 'Submit',
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_validate(otp: otp.text, password: password.text, confpass: confpass.text)) {
                                resetPass();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validate({String otp, String password, String confpass}) {
    if (otp.isEmpty) {
      Toasty.showtoast('Please Enter Your OTP');
      return false;
    } else if (password.isEmpty) {
      Toasty.showtoast('Please Enter Password');
      return false;
    } else if (confpass.isEmpty) {
      Toasty.showtoast('Please Re-Enter Your Password');
      return false;
    } else if (password != confpass) {
      Toasty.showtoast('Password do not Match');
      return false;
    } else {
      return true;
    }
  }
}
