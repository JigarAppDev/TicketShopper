import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';

class DottedContainer extends StatelessWidget {
  final String icon;
  final String text;
  final Function onTap;
  final File image;

  DottedContainer({this.icon, this.text, this.onTap, this.image});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(10),
      color: kPrimaryColor2,
      dashPattern: [6, 6],
      child: image == null
          ? GestureDetector(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                height: 180,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Image.asset('$iconURL/$icon', height: 22),
                    ),
                    AppText(text: text, fontSize: 15, color: kPrimaryColor2)
                  ],
                ),
              ),
              onTap: onTap,
            )
          : Stack(
              children: [
                GestureDetector(
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: Image.file(image),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    child: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.edit,
                        color: kPrimaryColor2,
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(10))),
                    ),
                    onTap: onTap,
                  ),
                ),
              ],
            ),
    );
  }
}
