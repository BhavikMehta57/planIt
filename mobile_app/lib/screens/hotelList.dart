// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:planit/main/appHome.dart';
import 'package:planit/main/shared_prefs.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planit/authentication/Login.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:planit/main/utils/Slider.dart';
import 'package:planit/main/utils/animation/fadeAnimation.dart';
import 'package:planit/main/utils/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:planit/screens/itinerary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HotelList extends StatefulWidget {
  static String tag = '/HotelList';
  final String city;
  final List hotelList;
  final String itineraryID;
  const HotelList({Key? key, required this.hotelList, required this.itineraryID, required this.city}) : super(key: key);

  @override
  _HotelListState createState() => _HotelListState();
}

class _HotelListState extends State<HotelList> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected;
  String? searchHotel = "";
  List allHotelsList = [];
  List filteredhotelsList = [];
  String? sort = "bestMatch";
  bool isPlanning = false;


  @override
  void initState() {
    super.initState();
    allHotelsList = List.from(widget.hotelList);
    filteredhotelsList = List.from(widget.hotelList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sortHotels() async {
    List tempHotelList = List.from(allHotelsList);
    if (sort == "bestMatch") {} else if (sort == "priceAscending") {
      tempHotelList.sort((a, b) => double.parse(a["Price"].toString().replaceAll(",", "")).compareTo(double.parse(b["Price"].toString().replaceAll(",", ""))));
    } else if (sort == "priceDescending") {
      tempHotelList.sort((a, b) => double.parse(b["Price"].toString().replaceAll(",", "")).compareTo(double.parse(a["Price"].toString().replaceAll(",", ""))));
    } else if (sort == "ratingAscending") {
      tempHotelList.sort((a, b) => double.parse(a["Rating"].toString()).compareTo(double.parse(b["Rating"].toString())));
    } else if (sort == "ratingDescending") {
      tempHotelList.sort((a, b) => double.parse(b["Rating"].toString()).compareTo(double.parse(a["Rating"].toString())));
    } else {}
    setState((){
      filteredhotelsList = List.from(tempHotelList);
    });
  }

  Future<void> sortFilteredHotels() async {
    List tempHotelList = List.from(filteredhotelsList);
    if (sort == "bestMatch") {} else if (sort == "priceAscending") {
      tempHotelList.sort((a, b) => double.parse(a["Price"].toString().replaceAll(",", "")).compareTo(double.parse(b["Price"].toString().replaceAll(",", ""))));
    } else if (sort == "priceDescending") {
      tempHotelList.sort((a, b) => double.parse(b["Price"].toString().replaceAll(",", "")).compareTo(double.parse(a["Price"].toString().replaceAll(",", ""))));
    } else if (sort == "ratingAscending") {
      tempHotelList.sort((a, b) => double.parse(a["Rating"].toString()).compareTo(double.parse(b["Rating"].toString())));
    } else if (sort == "ratingDescending") {
      tempHotelList.sort((a, b) => double.parse(b["Rating"].toString()).compareTo(double.parse(a["Rating"].toString())));
    } else {}
    setState((){
      filteredhotelsList = List.from(tempHotelList);
    });
  }

  Future<void> filterHotels(String searchValue) async {
    List tempHotelsList = List.from(allHotelsList);
    tempHotelsList.retainWhere((element) => element['Name'].toString().toLowerCase().contains(searchValue.toLowerCase()));
    setState(() {
      filteredhotelsList = List.from(tempHotelsList);
      selected = null;
    });
    await sortFilteredHotels();
  }

  showSuccessfulApplicationDialog(String title, String message){
    AwesomeDialog(
        dismissOnTouchOutside:false,
        context: _scaffoldKey.currentContext!,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        title: title,
        desc: message,
        btnOkOnPress: () {
          // Navigator.pop(context);
        },
        btnOkIcon: Icons.check_circle,
        btnCancelIcon: Icons.cancel,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback');
        }).show();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return isPlanning ? Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(color: appWhite,)),
            SizedBox(height: 20.0,),
            text("Please wait while we generate an itinerary for you...", fontSize: 24.0, fontFamily: fontBold, maxLine: 3, isCentered: true),
          ],
        ),
      ),
    ) : Scaffold(
      key: _scaffoldKey,
      backgroundColor: app_Background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: appWhite),
        backgroundColor: app_Background,
        title: text("PlanIt", textColor: appWhite, fontSize: textSizeLarge),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: selected != null ? FloatingActionButton.extended(
        onPressed: () async {
          try {
            setState(() {
              isPlanning = true;
            });
            final response = await http.post(
              Uri.parse('http://$ipAddress/itinerary/'),
              headers: <String, String>{
                'accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                "city": widget.city,
                "hotelName": filteredhotelsList[selected!]['Name'],
                "hotelLatitude": filteredhotelsList[selected!]['Latitude'].toString(),
                "hotelLongitude": filteredhotelsList[selected!]['Longitude'].toString(),
                "itineraryID": widget.itineraryID
              }),
            );
            var responseData = json.decode(response.body);
            var result = responseData['result']['data'];
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ItineraryPage(
                    itineraryID: result['itineraryID'],
                    destination: result["destination"],
                    startDate: result["startDate"],
                    numberOfDays: result["numberOfDays"],
                  );
                },
              ),
                    (Route<dynamic> route) => false);
            setState(() {
              isPlanning = false;
            });
          } catch(e) {
            const snackBar = SnackBar(
              content: Text('Planning Failed\nPlease check your internet connection'),
              duration: Duration(seconds: 10),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              isPlanning = false;
            });
          }
        },
        label: Row(
          children: [
            text("Proceed", fontSize: textSizeLargeMedium),
            SizedBox(width: deviceWidth * 0.01),
            Icon(Icons.arrow_forward_ios_outlined, color: appBlack),
          ],
        ),
      ) : Container(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: text(
                  "Select a hotel of your choice",
                  maxLine: 2,
                  isCentered: true,
                  fontSize: 16.0
              )
          ),
          SizedBox(height: deviceHeight * 0.02,),
          Row(
            children: [
              Expanded(
                child: EditText(
                  isPrefixIcon: false,
                  onPressed: (value) async {
                    searchHotel = value;
                    await filterHotels(value);
                  },
                  hintText: "Search Hotel by Name",
                  prefixIcon: fullnameIcon,
                  isPassword: false,
                  isPhone: false,
                  validatefunc: (String? value) {
                    return null;
                  },
                  // suffixIcon: Icons.search_outlined,
                  // suffixIconColor: appBlack,
                  // suffixIconOnTap: () async {
                  //
                  // },
                ),
              ),
              Container(
                  margin: EdgeInsets.only(right: 20),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: appWhite),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(context: context, builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            color: appColorPrimary,
                            child: Column(
                              children: [
                                text("Sort By", fontSize: textSizeLarge),
                                ListTile(
                                  title: text("Best Match"),
                                  trailing: Radio(value: "bestMatch", groupValue: sort, onChanged: (value) async {
                                    setState(() {
                                      sort = value.toString();
                                    });
                                  }),
                                ),
                                ListTile(
                                  title: text("Price: Low to High"),
                                  trailing: Radio(value: "priceAscending", groupValue: sort, onChanged: (value) async {
                                    setState(() {
                                      sort = value.toString();
                                    });
                                  }),
                                ),
                                ListTile(
                                  title: text("Price: High to Low"),
                                  trailing: Radio(value: "priceDescending", groupValue: sort, onChanged: (value) async {
                                    setState(() {
                                      sort = value.toString();
                                    });
                                  }),
                                ),
                                ListTile(
                                  title: text("Rating: Best to Worst"),
                                  trailing: Radio(value: "ratingDescending", groupValue: sort, onChanged: (value) async {
                                    setState(() {
                                      sort = value.toString();
                                    });
                                  }),
                                ),
                                ListTile(
                                  title: text("Rating: Worst to Best"),
                                  trailing: Radio(value: "ratingAscending", groupValue: sort, onChanged: (value) async {
                                    setState(() {
                                      sort = value.toString();
                                    });
                                  }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                  child: filterButton("Sort", () async {
                                    if (searchHotel == "") {
                                      await sortHotels();
                                    } else {
                                      await sortFilteredHotels();
                                    }
                                    Navigator.pop(context);
                                  }, appWhite, deviceHeight),
                                )
                              ],
                            ),
                          );
                        });
                      });
                    },
                    child: Icon(
                      Icons.sort_rounded,
                      color: appWhite,
                    ),
                  )
              )
            ],
          ),
          SizedBox(height: deviceHeight * 0.03,),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredhotelsList.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          selected = index;
                        });
                        print(filteredhotelsList[selected!]['Name']);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: deviceHeight * 0.15,
                        decoration: selected == index ? BoxDecoration(
                          border: Border.all(color: appColorAccent, width: 3.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ) : BoxDecoration(
                          border: Border.all(color: appWhite),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(filteredhotelsList[index]["Image"]),
                                  ),
                                ),
                                child: Container(
                                  height: deviceHeight * 0.15,
                                ),
                              ),
                            ),
                            SizedBox(width: deviceWidth * 0.03),
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  text(
                                    filteredhotelsList[index]["Name"],
                                    isBold: true,
                                    maxLine: 2
                                  ),
                                  SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: deviceWidth * 0.02),
                                      Icon(Icons.map_outlined),
                                      Spacer(),
                                      text("${filteredhotelsList[index]["Rating"].toString()} / 10"),
                                      SizedBox(width: deviceWidth * 0.02),
                                    ],
                                  ),
                                  SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                  RichText(
                                    text: TextSpan(
                                        text: "$rupees ${filteredhotelsList[index]["Price"]} ",
                                        style: TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 16.0
                                        ),
                                        children:[
                                          TextSpan(
                                            text: "per room per night",
                                            style: TextStyle(
                                                color: appWhite,
                                                fontSize: 12.0
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = () {
                                              // final Uri toLaunch = Uri(scheme: 'https', host: 'docs.google.com', path: 'document/d/1Kym9trNo720_SX4TpY5IMdkIImOeH8YKw_jnGmnoJ9o/edit');
                                              // launchInWebViewOrVC(toLaunch);
                                            },
                                          ),
                                        ]
                                    ),
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: deviceHeight * 0.15 * 0.02,)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02,),
                  ],
                );
              },
            )
          ),
          SizedBox(height: deviceHeight * 0.02,),
        ],
      ),
    );
  }
}