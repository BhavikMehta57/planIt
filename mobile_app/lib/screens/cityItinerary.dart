// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
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
import 'package:planit/screens/itinerary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';

class CityItinerary extends StatefulWidget {
  static String tag = '/CityItinerary';
  final String city;
  const CityItinerary({Key? key, required this.city}) : super(key: key);

  @override
  _CityItineraryState createState() => _CityItineraryState();
}

class _CityItineraryState extends State<CityItinerary> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List allItineraries = [];
  List areasOfInterests = [];

  @override
  void initState() {
    super.initState();
    getItineraries(widget.city);
  }

  Future<void> getItineraries(String city) async {
    await FirebaseFirestore.instance.collection('itineraries').where('Destination', isEqualTo: city).get().then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
        await FirebaseFirestore.instance.collection('plannerInput').doc(value.docs[i]['ItineraryID']).get().then((value) {
          setState(() {
            areasOfInterests.add(value.data()!['Areas of Interest']);
          });
        });
        setState(() {
          allItineraries.add(value.docs[i]);
        });
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
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
        title: text("Itineraries for ${widget.city}", textColor: appWhite, isCentered: true, fontSize: textSizeLarge),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.03,),
                allItineraries.length == 0 ? Text(
                  'No Itineraries Found',
                  style: TextStyle(
                      color: appWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ) : ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: allItineraries.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ItineraryPage(
                                    itineraryID: allItineraries[index]["ItineraryID"],
                                    destination: allItineraries[index]["Destination"],
                                    startDate: allItineraries[index]["Start Date"],
                                    numberOfDays: allItineraries[index]["Number of Days"],
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            // height: deviceHeight * 0.15,
                            margin: EdgeInsets.symmetric(horizontal: 20),
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
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage("assets/images/${allItineraries[index]["Destination"]}.jpg"),
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          text(
                                            allItineraries[index]["Destination"],
                                            fontSize: 20.0,
                                            isBold: true,
                                          ),
                                          SizedBox(height: deviceHeight * 0.02,),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.people_outline),
                                              SizedBox(width: deviceWidth * 0.01),
                                              text(allItineraries[index]["Number of travellers"]),
                                              SizedBox(width: deviceWidth * 0.03),
                                              Icon(Icons.calendar_today_outlined),
                                              SizedBox(width: deviceWidth * 0.01),
                                              text(allItineraries[index]["Number of Days"].toString() + "D " + (allItineraries[index]["Number of Days"] - 1).toString() + "N"),
                                              SizedBox(width: deviceWidth * 0.03),
                                              // Icon(Icons.remove_red_eye_outlined),
                                              // SizedBox(width: deviceWidth * 0.01),
                                              // text("45"),
                                            ],
                                          ),
                                          SizedBox(height: deviceHeight * 0.02,),
                                          text("$rupees ${(allItineraries[index]["Number of Days"] * allItineraries[index]["Trip Cost"]).toInt()}"),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: deviceHeight * 0.01,),
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: areasOfInterests[index].map<Widget>((area) => Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(color: appWhite)
                                    ),
                                    child: text(area.toString()),
                                  )).toList(),
                                ),
                                SizedBox(height: deviceHeight * 0.01,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: deviceHeight * 0.02,)
                      ],
                    );
                  },
                ),
                // Expanded(
                //   child: ListView(
                //     children: [
                //       Container(
                //         height: deviceHeight * 0.15,
                //         margin: EdgeInsets.symmetric(horizontal: 20),
                //         decoration: BoxDecoration(
                //           border: Border.all(color: appWhite),
                //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //         ),
                //         child: Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Expanded(
                //               flex: 2,
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //                   image: DecorationImage(
                //                     fit: BoxFit.cover,
                //                     image: AssetImage("assets/images/Mumbai.jpg"),
                //                   ),
                //                 ),
                //                 child: Container(
                //                   height: deviceHeight * 0.15,
                //                 ),
                //               ),
                //             ),
                //             SizedBox(width: deviceWidth * 0.03),
                //             Expanded(
                //               flex: 3,
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.start,
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   text(
                //                     "Mumbai",
                //                     fontSize: 20.0,
                //                     isBold: true,
                //                   ),
                //                   SizedBox(height: deviceHeight * 0.02,),
                //                   Row(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: [
                //                       Icon(Icons.people_outline),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("4"),
                //                       SizedBox(width: deviceWidth * 0.03),
                //                       Icon(Icons.calendar_today_outlined),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("5D 4N"),
                //                       SizedBox(width: deviceWidth * 0.03),
                //                       Icon(Icons.remove_red_eye_outlined),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("45"),
                //                     ],
                //                   ),
                //                   SizedBox(height: deviceHeight * 0.02,),
                //                   text("$rupees 14000")
                //                 ],
                //               ),
                //             )
                //           ],
                //         ),
                //       ),
                //       SizedBox(height: deviceHeight * 0.02,),
                //       Container(
                //         height: deviceHeight * 0.15,
                //         margin: EdgeInsets.symmetric(horizontal: 20),
                //         decoration: BoxDecoration(
                //           border: Border.all(color: appWhite),
                //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //         ),
                //         child: Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Expanded(
                //               flex: 2,
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //                   image: DecorationImage(
                //                     fit: BoxFit.cover,
                //                     image: AssetImage("assets/images/Delhi.jpg"),
                //                   ),
                //                 ),
                //                 child: Container(
                //                   height: deviceHeight * 0.15,
                //                 ),
                //               ),
                //             ),
                //             SizedBox(width: deviceWidth * 0.03),
                //             Expanded(
                //               flex: 3,
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.start,
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   text(
                //                     "Agra",
                //                     fontSize: 20.0,
                //                     isBold: true,
                //                   ),
                //                   SizedBox(height: deviceHeight * 0.02,),
                //                   Row(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: [
                //                       Icon(Icons.people_outline),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("3"),
                //                       SizedBox(width: deviceWidth * 0.03),
                //                       Icon(Icons.calendar_today_outlined),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("3D 2N"),
                //                       SizedBox(width: deviceWidth * 0.03),
                //                       Icon(Icons.remove_red_eye_outlined),
                //                       SizedBox(width: deviceWidth * 0.01),
                //                       text("35"),
                //                     ],
                //                   ),
                //                   SizedBox(height: deviceHeight * 0.02,),
                //                   text("$rupees 10000")
                //                 ],
                //               ),
                //             )
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: deviceHeight * 0.02,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}