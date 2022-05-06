import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/CustomTextField.dart';
import 'package:ticket_stopper/Components/DottedContainer.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Methods.dart';
import 'package:ticket_stopper/Screens/ImagePreviewScreen.dart';

class TicketInformationScreen extends StatefulWidget {
  @override
  _TicketInformationScreenState createState() => _TicketInformationScreenState();
}

class _TicketInformationScreenState extends State<TicketInformationScreen> {
  String setDate;
  String addTicketInformation = "$apiURL/add_ticket_information";
  DateTime selectedDate = DateTime.now();
  TextEditingController ticketDate = TextEditingController();
  TextEditingController ticketName = TextEditingController();
  TextEditingController ticketAmount = TextEditingController();
  TextEditingController ticketNumber = TextEditingController();
  TextEditingController licensePlateNumber = TextEditingController();
  TextEditingController carModel = TextEditingController();

  Response response;
  Dio dio = Dio();
  var jsonData;
  var userToken;
  File image;

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });

  }

  Future setUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ticket_id', jsonData['data']['ticket_id']);
  }

  void addTicket() async {
    try {
      response = await dio.post(
        addTicketInformation,
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
        data: {
          'ticket_name': ticketName.text,
          'car_model': carModel.text,
          'ticket_amount': ticketAmount.text,
          'licence_plat_number': licensePlateNumber.text,
          'ticket_date': ticketDate.text,
          'ticket_number': ticketNumber.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          setUserData();
          Navigator.popAndPushNamed(context, '/home');
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 10) {
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
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    _imgFromCamera() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(image)));
      });
    }

    _imgFromGallery() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(image)));
      });
    }

    void _showPicker(context) {
      showDialog(
        context: context,
        builder: (BuildContext bctx) {
          return AlertDialog(
            title: AppText(text: "From where do you want to take the photo?", fontSize: 14),
            content: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: AppText(text: 'Gallery', fontSize: 16),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: AppText(text: 'Camera', fontSize: 16),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: customAppBar('Ticket Information'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(label: 'Name', controller: ticketName, input: TextInputType.name),
                    CustomTextField(label: 'Car Model', controller: carModel, input: TextInputType.name),
                    CustomTextField(
                      label: 'Ticket Amount',
                      controller: ticketAmount,
                      input: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    CustomTextField(label: 'License Plate Number', controller: licensePlateNumber, input: TextInputType.name),
                    CustomTextField(
                      label: 'Ticket Date',
                      input: TextInputType.name,
                      controller: ticketDate,
                      onTap: () {
                        selectDate(context);
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                    CustomTextField(label: 'Ticket Number', controller: ticketNumber, input: TextInputType.name),
                    SizedBox(height: 8),
                    DottedContainer(
                      text: 'Upload Ticket Image',
                      icon: 'upload.png',
                      onTap: () {
                        _showPicker(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          CustomSubmitButton(
              text: 'Submit',
              minWidth: 280,
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_validate(
                  ticketname: ticketName.text,
                  carmodel: carModel.text,
                  ticketamount: ticketAmount.text,
                  licenseplatenumber: licensePlateNumber.text,
                  ticketdate: ticketDate.text,
                  ticketnumber: ticketNumber.text,
                )) {
                  addTicket();
                  // print('GOT TICKET ID>>>>> ' + jsonData['data']['ticket_id'].toString());
                }
              }),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: kPrimaryColor1,
            accentColor: kPrimaryColor1,
            colorScheme: ColorScheme.light(primary: kPrimaryColor1),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );
    if (newSelectedDate != null) {
      selectedDate = newSelectedDate;
      ticketDate.text = DateFormat("dd MMMM, yyyy").format(selectedDate);
      setState(() {});
      print(ticketDate.text);
    }
  }

  bool _validate({String ticketname, String carmodel, String ticketamount, String licenseplatenumber, String ticketdate, String ticketnumber}) {
    if (ticketname.isEmpty && carmodel.isEmpty && ticketamount.isEmpty && licenseplatenumber.isEmpty && ticketdate.isEmpty && ticketnumber.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (ticketname.isEmpty) {
      Toasty.showtoast('Please Enter Name');
      return false;
    } else if (carmodel.isEmpty) {
      Toasty.showtoast('Please Enter Car Model');
      return false;
    } else if (ticketamount.isEmpty) {
      Toasty.showtoast('Please Enter Ticket Amount');
      return false;
    } else if (licenseplatenumber.isEmpty) {
      Toasty.showtoast('Please Enter License Plate Number');
      return false;
    } else if (ticketdate.isEmpty) {
      Toasty.showtoast('Please Enter Ticket Date');
      return false;
    } else if (ticketnumber.isEmpty) {
      Toasty.showtoast('Please Enter Ticket Number');
      return false;
    } else {
      return true;
    }
  }
}
