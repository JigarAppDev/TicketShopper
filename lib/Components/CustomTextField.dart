import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    this.controller,
    this.input,
    this.label,
    this.maxLines,
    this.fieldHeight = 44,
    this.focusNode,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.initialValue,
  });

  final TextEditingController controller;
  final TextInputType input;
  final Function(String) onChanged;
  final List<TextInputFormatter> inputFormatters;
  final String label;
  final int maxLines;
  final double fieldHeight;
  final FocusNode focusNode;
  final String hintText;
  final Function onTap;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: AppText(text: label, color: Colors.grey, fontSize: 12),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 4),
          child: Container(
            height: fieldHeight,
            child: TextFormField(
              focusNode: focusNode,
              maxLines: maxLines,
              controller: controller,
              keyboardType: input,
              onChanged: onChanged,
              onTap: onTap,
              inputFormatters: inputFormatters,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: kOutlineInputBorder,
                enabledBorder: kOutlineInputBorder,
                errorBorder: kOutlineInputBorder,
                focusedErrorBorder: kOutlineInputBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UnLabeledPassField extends StatelessWidget {
  const UnLabeledPassField(
      {this.controller,
      this.input,
      this.maxLines,
      this.fieldHeight = 44,
      this.focusNode,
      this.hintText,
      this.inputFormatters});
  final TextEditingController controller;
  final TextInputType input;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final double fieldHeight;
  final FocusNode focusNode;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 4),
          child: Container(
            child: TextField(
              obscureText: true,
              focusNode: focusNode,
              controller: controller,
              inputFormatters: inputFormatters,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: kOutlineInputBorder,
                enabledBorder: kOutlineInputBorder,
                errorBorder: kOutlineInputBorder,
                focusedErrorBorder: kOutlineInputBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
