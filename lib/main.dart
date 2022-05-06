import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/EditTicketInformationScreen.dart';
import 'package:ticket_stopper/Screens/HomeScreen.dart';
import 'package:ticket_stopper/Screens/LoginScreen.dart';
import 'package:ticket_stopper/Screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticket Stopper',
      theme: ThemeData(
        primaryColor: kPrimaryColor1,
        scaffoldBackgroundColor: kBGColor,
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(color: Colors.transparent),
          textStyle: TextStyle(color: Colors.transparent),
        ),
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/edit': (context) => EditTicketInformationScreen(),
      },
    );
  }
}
