import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Methods.dart';
import 'package:ticket_stopper/Screens/HomeScreen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File image;
  ImagePreviewScreen(this.image);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  String addTicketInformation = "$apiURL/add_ticket_information";
  Response response;
  Dio dio = Dio();
  var jsonData;
  var userToken;

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');

    setState(() {
      userToken = user_token;
    });
    print(userToken);
    print(widget.image.path.toString());
  }

  Future setUserData() async {
    setPrefData(key: 'ticket_picture', value: jsonData['data']['ticket_picture']);
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void uploadImage() async {
    String fileName = '';
    if (widget.image != null) {
      fileName = widget.image.path.split('/').last;
    }
    var data;
    data = FormData.fromMap({'ticket_picture': widget.image == null ? '' : await MultipartFile.fromFile(widget.image.path, filename: fileName)});

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
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          setUserData();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Upload a Photo'),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.file(widget.image, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomSubmitButton(
                text: 'Submit',
                minWidth: 280,
                onPressed: () {
                  uploadImage();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
