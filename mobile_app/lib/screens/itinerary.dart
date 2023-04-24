// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
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
import 'package:planit/screens/restaurantList.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ItineraryPage extends StatefulWidget {
  static String tag = '/ItineraryPage';
  final String itineraryID;
  final int numberOfDays;
  final String startDate;
  final String destination;
  const ItineraryPage({Key? key,required this.itineraryID, required this.numberOfDays, required this.startDate, required this.destination}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  List itinerary = [];

  @override
  void initState() {
    super.initState();
    getItinerary(widget.itineraryID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getItinerary(String itineraryID) async {
    await FirebaseFirestore.instance.collection("itineraries").doc(itineraryID).get().then((value) {
      setState(() {
        itinerary = value.data()!['Itinerary'];
        print(itinerary);
      });
    });
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
        title: text("ITINERARY", textColor: appWhite, isCentered: true, fontSize: textSizeLarge),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: deviceHeight * 0.02,),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   child: text("YOUR RECENT TRIPS(2)",
          //     textColor: appWhite,
          //     fontSize: 18.0,
          //     fontFamily: fontBold,
          //     maxLine: 2,
          //   ),
          // ),
          SizedBox(
            height: deviceHeight * 0.08,
            child: ListView.builder(
                itemCount: widget.numberOfDays,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  DateTime newDate = DateTime.parse(widget.startDate).add(Duration(days: index));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              selectedIndex == index ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: appWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: appWhite),
                                  //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: text((newDate.day).toString(), textColor: appColorPrimary),
                              )
                                  :
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appWhite),
                                    //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: text((newDate.day).toString()),
                                ),
                              ),
                            ],
                          ),
                          index != (widget.numberOfDays - 1) ? SizedBox(
                            width: deviceWidth * 0.02,
                            height: deviceHeight * 0.002,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.green),
                            ),
                          ) : Container(),
                          SizedBox(
                            width: deviceWidth * 0.005,
                          ),
                          index != (widget.numberOfDays - 1) ? SizedBox(
                            width: deviceWidth * 0.02,
                            height: deviceHeight * 0.002,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.green),
                            ),
                          ) : Container(),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: text("Day " + (index + 1).toString())
                      ),
                    ],
                  );
                }
            ),
          ),
          SizedBox(height: deviceHeight * 0.05,),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                  itemCount: itinerary.isEmpty ? 0 : itinerary[selectedIndex]['places']['Place'].length,
                  itemBuilder: (context, index){
                  // bool memory = true;
                  // String img = itinerary[selectedIndex]['places']['Image'][index];
                  // String new_img = "";
                  // if(img.startsWith("data:image/jpeg;base64,")){
                  //   memory = true;
                  //   new_img = img.substring(23);
                  // } else {
                  //   memory = false;
                  // }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: deviceHeight * 0.08,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: deviceHeight * 0.03,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        // border: Border.all(color: appWhite),
                                      ),
                                      child: text("${itinerary[selectedIndex]['places']['Arrival Time'][index].toString().split(".")[0]}:${(double.parse(itinerary[selectedIndex]['places']['Arrival Time'][index].toString().split(".")[1]) * 60 / 100).toString().split(".")[0]}", fontSize: textSizeSmall, isCentered: true),
                                    ),
                                    Spacer(),
                                    text("${(itinerary[selectedIndex]['places']['Avg time spent'][index] * 60).round().toString()} mins", fontSize: textSizeSmall, isCentered: true)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                // height: deviceHeight * 0.18,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: appWhite),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: Container(
                                        //     decoration: BoxDecoration(
                                        //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        //       image: memory ? DecorationImage(
                                        //         fit: BoxFit.cover,
                                        //         image: MemoryImage(base64Decode(new_img)),
                                        //       ) : DecorationImage(
                                        //         fit: BoxFit.cover,
                                        //         image: NetworkImage(img),
                                        //       ),
                                        //     ),
                                        //     child: Container(
                                        //       height: deviceHeight * 0.18,
                                        //     ),
                                        //   ),
                                        // ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage("assets/images/Mumbai.jpg"),
                                              ),
                                            ),
                                            child: Container(
                                              height: deviceHeight * 0.18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: deviceWidth * 0.03),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                              text(
                                                itinerary[selectedIndex]['places']['Place'][index],
                                                maxLine: 2,
                                                fontSize: textSizeSMedium,
                                                isBold: true,
                                              ),
                                              SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () async {
                                                        final String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=${itinerary[selectedIndex]['places']['Latitude'][index]},${itinerary[selectedIndex]['places']['Longitude'][index]}";
                                                        final Uri encodedURl = Uri.parse(googleMapslocationUrl);
                                                        await launchUrl(encodedURl);
                                                        // if (await canLaunch(encodedURl)) {
                                                        //   await launch(encodedURl);
                                                        // } else {
                                                        //   print('Could not launch $encodedURl');
                                                        //   throw 'Could not launch $encodedURl';
                                                        // }
                                                      },
                                                      child: Icon(Icons.location_on_outlined)
                                                  ),
                                                  SizedBox(width: deviceWidth * 0.05),
                                                  text("$rupees ${itinerary[selectedIndex]['places']['Avg Cost'][index].toString()}"),
                                                  SizedBox(width: deviceWidth * 0.05),
                                                  text(itinerary[selectedIndex]['places']['Rating'][index].toString()),
                                                  SizedBox(width: deviceWidth * 0.01),
                                                  Icon(Icons.star, color: Colors.yellow, size: 15.0,),
                                                  SizedBox(width: deviceWidth * 0.01),
                                                  // Icon(Icons.remove_red_eye_outlined),
                                                  // SizedBox(width: deviceWidth * 0.01),
                                                  // text("45"),
                                                ],
                                              ),
                                              SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                              text(
                                                itinerary[selectedIndex]['places']['Type'][index],
                                                maxLine: 2,
                                                fontSize: textSizeSMedium,
                                                isBold: true,
                                              ),
                                              SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                              GestureDetector(
                                                onTap: () async {
                                                  try {
                                                    final response = await http.post(
                                                      Uri.parse('http://$ipAddress/restaurants/${widget.destination}'),
                                                      headers: <String, String>{
                                                        'accept': 'application/json',
                                                        'Content-Type': 'application/json',
                                                      },
                                                      body: jsonEncode({
                                                        "latitude": itinerary[selectedIndex]['places']['Latitude'][index],
                                                        "longitude": itinerary[selectedIndex]['places']['Longitude'][index],
                                                      }),
                                                    );
                                                    var responseData = json.decode(response.body);
                                                    var result = responseData['result']['data'];
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return RestaurantList(
                                                            restaurantList: result,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  } catch(e) {
                                                    print(e);
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    text("Explore Lunch Options", fontSize: 12.0, maxLine: 1, isCentered: true, textColor: appColorAccent),
                                                    Expanded(
                                                      child: Icon(Icons.chevron_right_rounded, color: appColorAccent,),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: deviceHeight * 0.01,),
                      ],
                    );
                  }
              ),
            ),
          ),
          SizedBox(height: deviceHeight * 0.02,),
        ],
      ),
    );
  }
}