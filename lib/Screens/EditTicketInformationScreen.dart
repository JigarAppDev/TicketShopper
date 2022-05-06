import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_stopper/Components/CachedImageContainer.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/CustomTextField.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Methods.dart';

class EditTicketInformationScreen extends StatefulWidget {
  final int ticketId;

  const EditTicketInformationScreen({this.ticketId});
  @override
  _EditTicketInformationScreenState createState() => _EditTicketInformationScreenState();
}

class _EditTicketInformationScreenState extends State<EditTicketInformationScreen> {
  String setDate;
  String editTicketInfo = "$apiURL/edit_ticket_information";
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
  var getTicketData;
  var userToken;
  String ticketname, ticketpic;
  String carmodel;
  String ticketamount;
  String licenseplatenumber;
  String ticketdate;
  String ticketnumber;

  bool _saving = false;
  File image;
  String filename = '';

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });
    print(userToken);
  }

  Future setUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ticket_id', jsonData['data']['ticket_id']);
  }

  Future getTicket() async {
    setState(() {
      _saving = true;
    });
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });

    response = await dio.post(
      editTicketInfo,
      data: {
        'ticket_id': widget.ticketId,
      },
      options: Options(
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $userToken',
        },
      ),
    );

    if (response != null) {
      setState(() {
        _saving = false;
        getTicketData = json.decode(response.data);
      });
      if (getTicketData['status'] == 1) {
        setState(() {
          ticketpic = getTicketData['data']['ticket_picture'];
          ticketname = getTicketData['data']['ticket_name'];
          carmodel = getTicketData['data']['car_model'];
          ticketamount = getTicketData['data']['ticket_amount'];
          licenseplatenumber = getTicketData['data']['licence_plat_number'];
          ticketdate = getTicketData['data']['ticket_date'];
          ticketnumber = getTicketData['data']['ticket_number'];
          ticketName = TextEditingController(text: ticketname ?? '');
          carModel = TextEditingController(text: carmodel ?? '');
          ticketAmount = TextEditingController(text: ticketamount ?? '');
          licensePlateNumber = TextEditingController(text: licenseplatenumber ?? '');
          ticketDate = TextEditingController(text: ticketdate ?? '');
          ticketNumber = TextEditingController(text: ticketnumber ?? '');
        });
      } else {
        Toasty.showtoast(getTicketData['message']);
      }
    }
  }

  void editTicket() async {
    var data;
    setState(() {
      _saving = true;
    });
    data = image == null
        ? FormData.fromMap({
            'ticket_id': widget.ticketId,
            'ticket_name': ticketName.text,
            'car_model': carModel.text,
            'ticket_amount': ticketAmount.text,
            'licence_plat_number': licensePlateNumber.text,
            'ticket_date': ticketDate.text,
            'ticket_number': ticketNumber.text,
          })
        : FormData.fromMap({
            'ticket_id': widget.ticketId,
            'ticket_picture': image == null ? '' : await MultipartFile.fromFile(image.path, filename: filename),
            'ticket_name': ticketName.text,
            'car_model': carModel.text,
            'ticket_amount': ticketAmount.text,
            'licence_plat_number': licensePlateNumber.text,
            'ticket_date': ticketDate.text,
            'ticket_number': ticketNumber.text,
          });
    try {
      response = await dio.post(
        editTicketInfo,
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          _saving = false;
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
    getTicket();
    print(ticketpic);
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    _imgFromCamera() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        filename = image.path.split('/').last;
        print(filename);
      });
    }

    _imgFromGallery() async {
      final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 80);

      setState(() {
        image = File(pickedImage.path);
        filename = image.path.split('/').last;
        print(filename);
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
      appBar: customAppBar('Edit Ticket Information'),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        progressIndicator: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1)),
        child: Column(
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
                      DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(10),
                        color: kPrimaryColor2,
                        dashPattern: [6, 6],
                        child: Stack(
                          children: [
                            ticketpic == null || ticketpic == '' || ticketpic == 'null' || image != null
                                ? SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: image == null || ticketpic == null || ticketpic == ''
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            child: Image.asset('$iconURL/no-image.png', fit: BoxFit.cover),
                                          )
                                        : GestureDetector(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              child: Image.file(image, fit: BoxFit.contain),
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
                                  )
                                : GestureDetector(
                                    child: CachedImageContainer(
                                      image: 'http://143.198.63.52/ticket_stopper/$ticketpic',
                                      height: 180,
                                      circular: 10, // topCorner: 10,
                                      // bottomCorner: 10,
                                      width: double.infinity,
                                      // fit: BoxFit.cover,
                                      // placeholder: '$iconURL/no-image.png',
                                    ),
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: CachedImageContainer(
                                            image: 'http://143.198.63.52/ticket_stopper/$ticketpic',
                                            circular: 0,
                                          ),
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
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(10))),
                                ),
                                onTap: () {
                                  _showPicker(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            CustomSubmitButton(
                text: 'Update',
                minWidth: 280,
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  editTicket();
                  // print('GOT TICKET ID>>>>> ' + jsonData['data']['ticket_id'].toString());
                }),
            SizedBox(height: 10),
          ],
        ),
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
    }
  }
}
