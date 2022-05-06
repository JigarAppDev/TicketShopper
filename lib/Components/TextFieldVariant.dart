import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_stopper/Constant.dart';

class AppPassField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  AppPassField({this.labelText, this.controller, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        obscureText: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins', fontSize: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: kUnderlineInputBorder,
          enabledBorder: kUnderlineInputBorder,
          focusedBorder: kUnderlineInputBorder,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final TextInputType input;
  final List<TextInputFormatter> inputFormatters;
  const AppTextField({this.labelText, this.input, this.controller, this.onChanged, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: TextField(
        controller: controller,
        keyboardType: input,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins', fontSize: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: kUnderlineInputBorder,
          enabledBorder: kUnderlineInputBorder,
          focusedBorder: kUnderlineInputBorder,
        ),
      ),
    );
  }
}
