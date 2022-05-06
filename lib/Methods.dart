import 'package:flutter/material.dart';
import 'package:ticket_stopper/Constant.dart';

AppBar customAppBar(String title) {
  return AppBar(
    iconTheme: IconThemeData(color: kPrimaryColor2),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: kPrimaryColor2),
    ),
  );
}
