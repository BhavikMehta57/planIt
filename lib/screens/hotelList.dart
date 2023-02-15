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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    return Scaffold(
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
          final response = await http.post(
            Uri.parse('http://192.168.29.232:8000/itinerary/'),
            headers: <String, String>{
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "city": widget.city,
              "hotelName": widget.hotelList[selected!]['Name'],
              "hotelLatitude": widget.hotelList[selected!]['Latitude'].toString(),
              "hotelLongitude": widget.hotelList[selected!]['Longitude'].toString(),
              "itineraryID": widget.itineraryID
            }),
          );
          var responseData = json.decode(response.body);
          var result = responseData['result']['data'];
          Navigator.push(
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
          );
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: text("Search",
              textColor: appWhite,
              fontSize: 18.0,
              fontFamily: fontBold,
              maxLine: 2,
            ),
          ),
          SizedBox(height: deviceHeight * 0.03,),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.hotelList.length,
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
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return ItineraryPage(
                        //         itineraryID: widget.hotelList[index]["ItineraryID"],
                        //         destination: widget.hotelList[index]["Destination"],
                        //         itinerary: widget.hotelList[index]["Itinerary"],
                        //         startDate: widget.hotelList[index]["Start Date"],
                        //         numberOfDays: widget.hotelList[index]["Number of Days"],
                        //       );
                        //     },
                        //   ),
                        // );
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
                                    image: NetworkImage(widget.hotelList[index]["Image"]),
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
                                    widget.hotelList[index]["Name"],
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
                                      text("${widget.hotelList[index]["Rating"].toString()} / 10"),
                                      SizedBox(width: deviceWidth * 0.02),
                                    ],
                                  ),
                                  SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                  RichText(
                                    text: TextSpan(
                                        text: "$rupees ${widget.hotelList[index]["Price"]} ",
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