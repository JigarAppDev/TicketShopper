import 'package:flutter/material.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';

class InfoLabel extends StatelessWidget {
  final String text;
  final Function onTap;
  InfoLabel({this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(text: text, color: Colors.grey, fontSize: 12),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
