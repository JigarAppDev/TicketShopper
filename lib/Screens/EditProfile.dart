import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/CachedImageContainer.dart';
import 'package:ticket_stopper/Components/CustomSubmitButton.dart';
import 'package:ticket_stopper/Components/CustomTextField.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Methods.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String text = '';
  String editProfile = "$apiURL/edit_profile";
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController eMail = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  File image;
  _imgFromGallery() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 80);

    setState(() {
      image = File(pickedImage.path);
    });
  }

  var userToken;

  @override
  void initState() {
    super.initState();
    print(image);
    getProfile();
  }

  Response response;
  Dio dio = Dio();
  var getProfileData;
  var jsonData;
  String username;
  String firstname;
  String lastname;
  String email;
  String phonenumber;
  String profilepic;
  bool _loading = false;

  Future getProfile() async {
    setState(() {
      _loading = true;
    });
    var data = ({});

    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });

    response = await dio.post(
      editProfile,
      data: jsonEncode(data),
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
        _loading = false;
        getProfileData = json.decode(response.data);
      });
      if (getProfileData['status'] == 1) {
        setState(() {
          username = getProfileData['data']['name'];
          firstname = getProfileData['data']['first_name'];
          lastname = getProfileData['data']['last_name'];
          email = getProfileData['data']['email'];
          phonenumber = getProfileData['data']['phone_number'];
          profilepic = getProfileData['data']['profile_pic'];
          firstName = TextEditingController(text: firstname ?? '');
          lastName = TextEditingController(text: lastname ?? '');
          eMail = TextEditingController(text: email ?? '');
          phoneNumber = TextEditingController(text: phonenumber ?? '');
        });
      } else {
        Toasty.showtoast(getProfileData['message']);
      }
    }
  }

  Future setUserData() async {
    await setPrefData(key: 'first_name', value: jsonData['data']['first_name']);
    await setPrefData(key: 'last_name', value: jsonData['data']['last_name']);
    await setPrefData(key: 'email', value: jsonData['data']['email']);
    await setPrefData(key: 'profile_pic', value: jsonData['data']['profile_pic']);
  }

  void editUserProfile() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
      _loading = true;
    });
    String fileName = '';
    if (image != null) {
      fileName = image.path.split('/').last;
    }

    var data;
    image == null
        ? data = FormData.fromMap({
            'token': userToken,
            'name': username,
            'first_name': firstName.text,
            'last_name': lastName.text,
            'email': eMail.text,
            'phone_number': phoneNumber.text,
          })
        : data = FormData.fromMap({
            'token': userToken,
            'name': username,
            'first_name': firstName.text,
            'last_name': lastName.text,
            'email': eMail.text,
            'phone_number': phoneNumber.text,
            'profile_pic': image == null ? '' : await MultipartFile.fromFile(image.path, filename: fileName),
          });
    try {
      response = await dio.post(
        editProfile,
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
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        print('>>>>>>>>>>>>>>>' + jsonData.toString());
        if (jsonData['status'] == 1) {
          setUserData();
          Navigator.popAndPushNamed(context, '/home');
          Toasty.showtoast(jsonData['message']);
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Edit Profile'),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1)),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 112,
                          width: 112,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: profilepic == null || profilepic == "null" || profilepic == "" || image != null
                                    ? CircleAvatar(
                                        radius: 56,
                                        backgroundColor: Colors.white,
                                        child: image != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(60),
                                                child: Image.file(
                                                  image,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(60),
                                                child: Image.asset(
                                                  '$iconURL/no-user.png',
                                                  height: 120,
                                                  width: 120,
                                                ),
                                              ),
                                      )
                                    : CachedImageContainer(
                                        image: 'http://143.198.63.52/ticket_stopper/$profilepic',
                                        width: 112,
                                        height: 112,
                                        circular: 56,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              GestureDetector(
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Image.asset('$iconURL/camera.png', height: 42),
                                  ),
                                ),
                                onTap: () {
                                  _imgFromGallery();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppText(text: username ?? '', color: Colors.grey),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: 'First Name',
                        hintText: 'Enter Your First Name',
                        controller: firstName,
                        input: TextInputType.name,
                      ),
                      CustomTextField(
                        label: 'Last Name',
                        hintText: 'Enter Your Last Name',
                        controller: lastName,
                        input: TextInputType.name,
                      ),
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Enter Your Email',
                        controller: eMail,
                        input: TextInputType.emailAddress,
                      ),
                      CustomTextField(
                        label: 'Phone Number',
                        hintText: 'Enter Your Phone Number',
                        controller: phoneNumber,
                        input: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[.]')),
                        ],
                        onChanged: (String newVal) {
                          if (newVal.length <= 12) {
                            text = newVal;
                          } else {
                            phoneNumber.text = text;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomSubmitButton(
                text: 'Save',
                minWidth: 280,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  editUserProfile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
