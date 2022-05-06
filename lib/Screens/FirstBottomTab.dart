import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ticket_stopper/Components/TextVariant.dart';
import 'package:ticket_stopper/Constant.dart';
import 'package:ticket_stopper/Screens/EditTicketInformationScreen.dart';
import 'package:vibration/vibration.dart';

class FirstBottomTab extends StatefulWidget {
  @override
  _FirstBottomTabState createState() => _FirstBottomTabState();
}

class _FirstBottomTabState extends State<FirstBottomTab> with TickerProviderStateMixin {
  var userToken, ticketPicture;
  String ticketStatusList = '$apiURL/list_ticket_status_by_list';

  TabController _controller;
  bool get indexIsChanging => _indexIsChangingCount != 0;
  int _indexIsChangingCount = 0;

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    var ticket_picture = await getPrefData(key: 'ticket_picture');
    setState(() {
      userToken = user_token;
      ticketPicture = ticket_picture;
    });
    showTickets();
  }

  Response response;
  Dio dio = Dio();
  var jsonData;
  List jsonList = [];
  bool _loading = false;

  int ticketStatus = 1;

  void showTickets() async {
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        ticketStatusList,
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
        data: {
          'ticket_status': ticketStatus,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.data);
          print(jsonData);
        });

        if (jsonData['status'] == 1) {
          setState(() {
            jsonList = jsonData['data'];
          });
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

  List<Widget> list = [
    Tab(child: AppText(text: 'Ongoing')),
    Tab(child: AppText(text: 'Completed')),
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
    _controller = TabController(length: list.length, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      setState(() {
        jsonList = [];
      });
      if (_controller.index == 0) {
        setState(() {
          ticketStatus = 1;
          jsonList = [];
        });
        showTickets();
      } else {
        setState(() {
          ticketStatus = 2;
          jsonList = [];
        });
        showTickets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        color: Colors.transparent,
        progressIndicator: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor2))),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: AppBar(
                bottom: TabBar(
                  controller: _controller,
                  onTap: (index) {
                    Platform.isIOS ? Vibration.cancel() : Vibration.vibrate(duration: 50);
                  },
                  indicatorWeight: 3,
                  indicatorColor: kPrimaryColor2,
                  labelColor: kPrimaryColor2,
                  unselectedLabelColor: Colors.white,
                  labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimaryColor2),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, color: kPrimaryColor2),
                  tabs: list,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  jsonList.isNotEmpty
                      ? ListView.builder(
                          itemCount: jsonList.length,
                          itemBuilder: (context, index) {
                            // print(jsonList[index]['ticket_id']);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 16, right: 16, top: 8),
                              child: Stack(
                                children: [
                                  Image.asset('$iconURL/clipticket.png'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  AppText(text: jsonList[index]['ticket_name'] ?? '', fontSize: 16),
                                                  AppText(text: 'Car Model: ${jsonList[index]['car_model'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                  AppText(text: 'License Plate Number: ${jsonList[index]['licence_plat_number'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                  AppText(text: 'Ticket Number: ${jsonList[index]['ticket_number'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      AppText(text: '\$${jsonList[index]['ticket_amount'] ?? ''}', fontSize: 16, color: kPrimaryColor2),
                                                      AppText(text: '${jsonList[index]['ticket_date'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: GestureDetector(
                                      child: Container(
                                        height: 16,
                                        width: 16,
                                        decoration: BoxDecoration(color: kPrimaryColor2, borderRadius: BorderRadius.all(Radius.circular(20))),
                                        child: Icon(Icons.edit, color: Colors.white, size: 10),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditTicketInformationScreen(
                                              ticketId: jsonList[index]['ticket_id'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                      : jsonList.length == 0
                          ? Center(
                              child: AppText(text: 'No Ticket Found'),
                            )
                          : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1))),
                  jsonList.isNotEmpty
                      ? ListView.builder(
                          itemCount: jsonList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 16, right: 16, top: 8),
                              child: Stack(
                                children: [
                                  Image.asset('$iconURL/clipticket.png'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  AppText(text: jsonList[index]['ticket_name'] ?? '', fontSize: 16),
                                                  AppText(text: 'Car Model: ${jsonList[index]['car_model'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                  AppText(text: 'License Plate Number: ${jsonList[index]['licence_plat_number'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                  AppText(text: 'Ticket Number: ${jsonList[index]['ticket_number'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      AppText(text: '\$${jsonList[index]['ticket_amount'] ?? ''}', fontSize: 16, color: kPrimaryColor2),
                                                      AppText(text: '${jsonList[index]['ticket_date'] ?? ''}', fontSize: 11, color: Colors.grey),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                      : jsonList.length == 0
                          ? Center(
                              child: AppText(text: 'No Ticket Found'),
                            )
                          : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
