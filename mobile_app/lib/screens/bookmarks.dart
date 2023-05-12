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

class Bookmarks extends StatefulWidget {
  static String tag = '/Bookmarks';

  const Bookmarks({Key? key}) : super(key: key);

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> bookMarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBookmarkList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getBookmarkList() async {
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.email).collection("bookmarks").get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        bookMarks.add(value.docs[i].data()['ItineraryID']);
      }
    });
    print(bookMarks);
    setState(() {
      isLoading = false;
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
        title: text("Bookmarked Itineraries", textColor: appWhite, isCentered: true, fontSize: textSizeLarge),
        elevation: 0.0,
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(color: appWhite,),) : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.03,),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("itineraries")
                      .where("ItineraryID", whereIn: bookMarks)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData){
                      print("Connection state: has no data");
                      return Column(
                        children: const [
                          SizedBox(
                            height:10.0,
                          ),
                          Center(
                            child: CircularProgressIndicator(color: appWhite,),
                          )
                        ],
                      );
                    }
                    else if(snapshot.connectionState == ConnectionState.waiting){
                      print("Connection state: waiting");
                      return Column(
                        children: const [
                          SizedBox(
                            height:10.0,
                          ),
                          Center(
                            child: CircularProgressIndicator(color: appWhite,),
                          )
                        ],
                      );
                    }
                    else{
                      print("Connection state: hasdata");
                      if(snapshot.data!.docs.isEmpty){
                        return Center(
                            child: Column(
                                children: const [
                                  Text(
                                    'No Itineraries Found',
                                    style: TextStyle(
                                        color: appWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ]
                            )
                        );
                      }
                      else{
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
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
                                            itineraryID: snapshot.data!.docs[index]["ItineraryID"],
                                            destination: snapshot.data!.docs[index]["Destination"],
                                            startDate: snapshot.data!.docs[index]["Start Date"],
                                            numberOfDays: snapshot.data!.docs[index]["Number of Days"],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: deviceHeight * 0.15,
                                    margin: EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
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
                                                image: AssetImage("assets/images/${snapshot.data!.docs[index]["Destination"]}.jpg"),
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
                                                snapshot.data!.docs[index]["Destination"],
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
                                                  text(snapshot.data!.docs[index]["Number of travellers"]),
                                                  SizedBox(width: deviceWidth * 0.03),
                                                  Icon(Icons.calendar_today_outlined),
                                                  SizedBox(width: deviceWidth * 0.01),
                                                  text(snapshot.data!.docs[index]["Number of Days"].toString() + "D " + (snapshot.data!.docs[index]["Number of Days"] - 1).toString() + "N"),
                                                  SizedBox(width: deviceWidth * 0.03),
                                                  // Icon(Icons.remove_red_eye_outlined),
                                                  // SizedBox(width: deviceWidth * 0.01),
                                                  // text("45"),
                                                ],
                                              ),
                                              SizedBox(height: deviceHeight * 0.02,),
                                              text("$rupees ${(snapshot.data!.docs[index]["Number of Days"] * snapshot.data!.docs[index]["Trip Cost"]).toInt()}"),
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
                        );
                      }
                    }
                  }
              ),
              SizedBox(height: deviceHeight * 0.02,),
            ],
          ),
        ),
      ),
    );
  }
}