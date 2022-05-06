import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/TextFieldVariant.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/ResetPasswordScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email;
  TextEditingController emailController = TextEditingController();
  String forgotPassword = "$apiURL/forgot_password";
  Response response;
  Dio dio = Dio();
  bool _loading = false;

  void forgotPass() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        forgotPassword,
        data: {
          'email': emailController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        var responseData = response.data;
        var jsonData = jsonDecode(responseData);
        if (jsonData['status'] == 1) {
          email = jsonData['email'];

          Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: emailController.text)));
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
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultText(text: 'Forgot Password'),
                          AppTextField(
                            controller: emailController,
                            labelText: 'Email',
                            input: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 50),
                          CustomSubmitButton(
                            text: 'Submit',
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_validate(email: emailController.text)) {
                                forgotPass();
                              }
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen()));
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

  bool _validate({String email}) {
    if (email.isEmpty) {
      Toasty.showtoast('Please Enter Your Email to Reset Password');
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      Toasty.showtoast('Please Enter Valid Email Address');
      return false;
    }
    return true;
  }
}
