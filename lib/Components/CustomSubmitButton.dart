import 'package:flutter/material.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';

class CustomSubmitButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final double minWidth;

  const CustomSubmitButton({@required this.text, this.onPressed, this.minWidth: double.infinity});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 44,
      minWidth: minWidth,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: onPressed,
        color: kPrimaryColor1,
        child: DefaultText(
          fontSize: 16,
          text: text,
          color: kPrimaryColor2,
        ),
      ),
    );
  }
}

class SocialMediaSubmitButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color buttonColor;
  final String icon;
  final Color textColor;

  const SocialMediaSubmitButton({this.text, this.onPressed, this.buttonColor, this.icon, this.textColor = Colors.white});
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 44,
      minWidth: double.infinity,
      child: RaisedButton.icon(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: buttonColor,
        onPressed: onPressed,
        textColor: textColor,
        label: AppText(
          fontSize: 12,
          text: text,
        ),
        icon: Image.asset('$iconURL/$icon', height: 22),
      ),
    );
  }
}
