import 'package:flutter/material.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';

class LabeledContainer extends StatelessWidget {
  final String label;
  final String value;

  LabeledContainer({this.label, this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: AppText(
            text: label,
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AppText(text: value, fontSize: 12),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
