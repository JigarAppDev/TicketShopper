import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_stopper/AndroidInAppPerchase/AndroidInAppPerchaseUpdate.dart';
import 'package:ticket_stopper/Components/process_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constant.dart';
import 'HomeScreen.dart';

class InAppPurchaseScreenAndroid extends StatefulWidget {
  @override
  _InAppPurchaseScreenAndroidState createState() => _InAppPurchaseScreenAndroidState();
}

class _InAppPurchaseScreenAndroidState extends State<InAppPurchaseScreenAndroid> {
  int cardID = 1;
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _platformVersion = 'Unknown';
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists = ['t1_299_mn', 't2_599_mn', 't3_1199_mn'];

  final List<String> _androidProductLists = ['t1_299_mn', 't2_599_mn', 't3_1199_mn'];
  static Circle processIndicator = Circle();

  @override
  void initState() {
    print("Ankdroid");
    super.initState();
    initPlatformState();
    _getProduct();
  }

  @override
  void dispose() async {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
      _purchaseUpdatedSubscription.cancel();
      _purchaseUpdatedSubscription = null;
      _purchaseErrorSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
    await FlutterInappPurchase.instance.endConnection;
  }

  Future _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    print('========items======');
    print("items: $items");
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      if (Platform.isAndroid) {
        print('Purchased');
        print(productItem);
        updateAndroidPurchase(context: context, progress: processIndicator);
      } else {
        print('this is a ios platform subscription!');
        print('purchase Item 88 : $productItem');
        if (productItem.transactionId != null) {
          sendReceiptToServer();
          print('sdbfh dhfj dshf sdfhfs:${productItem.transactionId}');
        }
      }
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
      processIndicator.hide(context);
    });
  }

  _requestPurchase(IAPItem item) async {
    print('itemAnkit');
    print(item.productId);
    try {
      await FlutterInappPurchase.instance.requestPurchase(item.productId);
      processIndicator.hide(context);
    } on Exception catch (e) {
      print("exAnkit");
      print(e);
    }
  }

  void sendReceiptToServer() async {
    try {
      Response response;
      var jsonData;
      Dio dio = Dio();
      var userToken = await getPrefData(key: 'user_token');
      List<PurchasedItem> items = await FlutterInappPurchase.instance.getAvailablePurchases();
      print(items.first);
      print('Yes its InApp Api$userToken');
      var responseData;
      var data = {
        'receipt_data': items.first.transactionReceipt,
      };

      print('my data is@$data');

      response = await dio.post(
        ADD_RECIEPT,
        data: data,
        options: Options(
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      setState(() {
        jsonData = jsonDecode(response.toString());
      });
      if (jsonData['status'].toString() == '1') {
        await saveSharedPrefData(key: 'inApp', value: true);
        processIndicator.hide(context);
        Toasty.showtoast(jsonData['msg']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        await saveSharedPrefData(key: 'inApp', value: true);
        processIndicator.hide(context);
        Toasty.showtoast(jsonData['msg']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void funcOpenMailComposer() async {
    final mailtoLink = Mailto(
      to: ['support@ticketsstopper.com'],
      cc: ['', ''],
      subject: '',
      body: '',
    );
    await launch('$mailtoLink');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/icons/in_app_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      'Ticket Stopper',
                      style: TextStyle(fontSize: 26, color: Colors.white, fontFamily: 'Acaslon'),
                    ),
                    Image.asset('assets/icons/logo.png', height: 140, width: 140),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            /*   'We Created The Fastest Way To Complete\nYour Defensive Driving.\nOur System Was Designed To Work Hard So\nYou Don\'t Have To',*/
                            'Pick one tier below to cover any parking tickets\nfor a year. Renews each year.\nMust have the app for at least one month\nto submit a claim.\nCancel anytime. Questions? ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Poppins'),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'send email ',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Poppins'),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  funcOpenMailComposer();
                                },
                                child: Text(
                                  'support@ticketsstopper.com',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Colors.blue.shade400, fontFamily: 'Poppins'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.44,
            color: Color(0xfff0efef),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: cardID == 1 ? 4 : 3,
                        child: GestureDetector(
                          child: SizedBox(
                            height: cardID == 1 ? 184 : 164,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: cardID == 1 ? 160 : 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cardID == 1 ? kThemeColor : Colors.transparent),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '\$2.99\nmonth',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 1 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                      Text(
                                        'tickets up to\n\$70.00',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 1 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      )
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardID == 1 ? kThemeColor : Colors.white,
                                      border: Border.all(color: cardID == 1 ? kThemeColor : Colors.black54),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 3),
                                      child: Text(
                                        'Tier 1',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, color: cardID == 1 ? Colors.white : Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              cardID = 1;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: cardID == 2 ? 4 : 3,
                        child: GestureDetector(
                          child: SizedBox(
                            height: cardID == 2 ? 184 : 164,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: cardID == 2 ? 160 : 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cardID == 2 ? kThemeColor : Colors.transparent),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '\$5.99\nmonth',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 2 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                      Text(
                                        'tickets up to\n\$140.00',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 2 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      )
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardID == 2 ? kThemeColor : Colors.white,
                                      border: Border.all(color: cardID == 2 ? kThemeColor : Colors.black54),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 3),
                                      child: Text(
                                        'Tier 2',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, color: cardID == 2 ? Colors.white : Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              cardID = 2;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: cardID == 3 ? 4 : 3,
                        child: GestureDetector(
                          child: SizedBox(
                            height: cardID == 3 ? 184 : 164,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: cardID == 3 ? 160 : 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: cardID == 3 ? kThemeColor : Colors.transparent),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '\$11.99\nmonth',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 3 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                      Text(
                                        'tickets up to\n\$200.00',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: cardID == 3 ? 14 : 12, color: Colors.black54, fontFamily: 'Poppins'),
                                      )
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardID == 3 ? kThemeColor : Colors.white,
                                      border: Border.all(color: cardID == 3 ? kThemeColor : Colors.black54),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 3),
                                      child: Text(
                                        'Tier 3',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, color: cardID == 3 ? Colors.white : Colors.black54, fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              cardID = 3;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        processIndicator.show(context);
                        await _getProduct();
                        // androidPurchase(context: context);
                        print("_items[0]");
                        print(_items[0]);
                        if (cardID == 1) {
                          _requestPurchase(_items[0]);
                        } else if (cardID == 2) {
                          _requestPurchase(_items[1]);
                        } else if (cardID == 3) {
                          _requestPurchase(_items[2]);
                        }
                      } else {
                        print('cardID');
                        print(cardID);
                        processIndicator.show(context);
                        if (cardID == 1) {
                          _requestPurchase(_items[1]);
                        } else if (cardID == 2) {
                          _requestPurchase(_items[2]);
                        } else if (cardID == 3) {
                          _requestPurchase(_items[0]);
                        }
                      }
                    },
                    child: Text('Continue', style: TextStyle(fontSize: 16, color: Color(0xff5d1911))),
                    style: ElevatedButton.styleFrom(minimumSize: Size(260, 44), primary: kThemeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Terms and Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(decoration: TextDecoration.underline, fontSize: 13, color: Color(0xffaeaeae), fontFamily: 'Poppins'),
                      ),
                      Text(
                        'Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(decoration: TextDecoration.underline, fontSize: 13, color: Color(0xffaeaeae), fontFamily: 'Poppins'),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future getSharedPrefData({String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key);
  return data;
}
