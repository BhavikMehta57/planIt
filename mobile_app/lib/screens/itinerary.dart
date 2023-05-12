// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  bool editState = false;
  bool isBookmarked = false;
  int selectedPlace = 0;
  int selectedExtraPlace = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getItinerary(widget.itineraryID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> swapPlace(int index, int extraIndex) async {
    itinerary[selectedIndex]['places'].forEach((k,v) {
      if (k != "Arrival Time" && k != "Leaving Time") {
        if (itinerary[selectedIndex]['extra'].containsKey(k)) {
          v[index] = itinerary[selectedIndex]['extra'][k][extraIndex];
          print(v[index].toString() + " swapped to " + itinerary[selectedIndex]['extra'][k][extraIndex].toString());
        }
      }
    });
    setState((){});
  }

  Future<void> deletePlace(int index) async {
    itinerary[selectedIndex]['places'].forEach((k,v) {
      v.removeAt(index);
    });
    setState((){});
  }

  Future<void> saveItinerary(String itineraryID) async {
    await FirebaseFirestore.instance.collection("itineraries").doc(itineraryID).get().then((value) {
      setState(() {
        itinerary = value.data()!['Itinerary'];
        print(itinerary);
      });
    });
  }

  Future<void> getItinerary(String itineraryID) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.email).collection("bookmarks").doc(widget.itineraryID).get().then((value) {
      if (value.exists) {
        isBookmarked = true;
      }
    });
    await FirebaseFirestore.instance.collection("itineraries").doc(itineraryID).get().then((value) {
      itinerary = value.data()!['Itinerary'];
    });
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
        automaticallyImplyLeading: !editState,
        backgroundColor: app_Background,
        title: text("ITINERARY", textColor: appWhite, isCentered: true, fontSize: textSizeLarge),
        elevation: 0,
        actions: editState ? [
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0))
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            child: Column(
                              children: [
                                text('Select one of the following places to swap:', fontSize: textSizeNormal, maxLine: 3),
                                SizedBox(height: 5,),
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: itinerary.isEmpty ? 0 : itinerary[selectedIndex]['extra']['Place'].length,
                                    itemBuilder: (context, index){
                                      bool show = true;
                                      double open_time = double.parse(itinerary[selectedIndex]['extra']['Open Time'][index].toString().split(":")[0]) + (double.parse(itinerary[selectedIndex]['extra']['Open Time'][index].toString().split(":")[1]) / 60);
                                      double close_time = double.parse(itinerary[selectedIndex]['extra']['Close Time'][index].toString().split(":")[0]) + (double.parse(itinerary[selectedIndex]['extra']['Close Time'][index].toString().split(":")[1]) / 60);
                                      if (double.parse(itinerary[selectedIndex]['places']['Arrival Time'][selectedPlace]) > open_time && double.parse(itinerary[selectedIndex]['places']['Arrival Time'][selectedPlace]) < close_time) {
                                        show = true;
                                      } else {
                                        show = false;
                                      }
                                      bool memory = true;
                                      String img = itinerary[selectedIndex]['extra']['Images'][index];
                                      String new_img = "";
                                      if(img.startsWith("data:image/jpeg;base64,")){
                                        memory = true;
                                        new_img = img.substring(23);
                                      } else {
                                        memory = false;
                                      }
                                      return show ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 11,
                                                child: Container(
                                                  // height: deviceHeight * 0.18,
                                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: appWhite),
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Column(
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
                                                                    image: memory ? DecorationImage(
                                                                      fit: BoxFit.cover,
                                                                      image: MemoryImage(base64Decode(new_img)),
                                                                    ) : DecorationImage(
                                                                      fit: BoxFit.cover,
                                                                      image: NetworkImage(img),
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
                                                                    SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                                                    Container(
                                                                      margin: EdgeInsets.only(right: 25),
                                                                      child: text(
                                                                        itinerary[selectedIndex]['extra']['Place'][index],
                                                                        maxLine: 2,
                                                                        fontSize: textSizeSMedium,
                                                                        isBold: true,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                                                    Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        itinerary[selectedIndex]['extra']['Avg Cost'][index].toString() == "0.0" ? text("Free") : text("$rupees ${itinerary[selectedIndex]['extra']['Avg Cost'][index].toString()}"),
                                                                        SizedBox(width: deviceWidth * 0.05),
                                                                        text(itinerary[selectedIndex]['extra']['Rating'][index].toString()),
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
                                                                      itinerary[selectedIndex]['extra']['Type'][index],
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
                                                                              "latitude": itinerary[selectedIndex]['extra']['Latitude'][index],
                                                                              "longitude": itinerary[selectedIndex]['extra']['Longitude'][index],
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
                                                                          text("Food Options", fontSize: 14.0, maxLine: 1, isCentered: true, textColor: appColorAccent),
                                                                          Icon(Icons.chevron_right_rounded, color: appColorAccent,)
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
                                                      Positioned(
                                                        right: 2,
                                                        top: 2,
                                                        child: GestureDetector(
                                                            onTap: () async {
                                                              final String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=${itinerary[selectedIndex]['extra']['Latitude'][index]},${itinerary[selectedIndex]['extra']['Longitude'][index]}";
                                                              final Uri encodedURl = Uri.parse(googleMapslocationUrl);
                                                              await launchUrl(encodedURl);
                                                              // if (await canLaunch(encodedURl)) {
                                                              //   await launch(encodedURl);
                                                              // } else {
                                                              //   print('Could not launch $encodedURl');
                                                              //   throw 'Could not launch $encodedURl';
                                                              // }
                                                            },
                                                            child: Icon(Icons.directions_outlined)
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: Checkbox(
                                                      value: selectedExtraPlace == index,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          selectedExtraPlace = index;
                                                        });
                                                      })
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: deviceHeight * 0.02,),
                                        ],
                                      ) : Container();
                                    }
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                                  child: filterButton("SWAP", () async {
                                    await swapPlace(selectedPlace, selectedExtraPlace);
                                    Navigator.pop(context);
                                  }, appWhite, deviceHeight),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  });
            },
            child: Icon(Icons.swap_horiz_rounded, color: appWhite,),
          ),
          SizedBox(width: 20.0,),
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                      title: text('Confirm Remove', fontSize: textSizeNormal),
                      content: text('Are you sure you want to remove the place?\nThis action cannot be undone.', fontSize: textSizeSmall, maxLine: 2),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: filterButton("No", () {
                                Navigator.pop(context);
                              }, appWhite, deviceHeight),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: filterButton("Yes", () async {
                                await deletePlace(selectedPlace);
                                Navigator.pop(context);
                              }, appWhite, deviceHeight),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            },
            child: Icon(Icons.delete, color: appWhite,),
          ),
          SizedBox(width: 20.0,),
          GestureDetector(
            onTap: () async {
              setState(() {
                editState = !editState;
              });
            },
            child: Icon(Icons.check, color: appWhite,),
          ),
          SizedBox(width: 10.0,),
        ] : [
          isBookmarked ? Icon(Icons.bookmark_added, color: appWhite,) : GestureDetector(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.email).collection("bookmarks").doc(widget.itineraryID).set({
                "ItineraryID": widget.itineraryID,
                "numberOfDays": widget.numberOfDays,
                "startDate": widget.startDate,
                "destination" : widget.destination,
              });
              setState(() {
                isBookmarked = true;
                isLoading = false;
              });
            },
            child: Icon(Icons.bookmark_add_outlined, color: appWhite,),
          ),
          SizedBox(width: 20.0,),
          GestureDetector(
            onTap: () async {
              setState(() {
                editState = !editState;
              });
            },
            child: Icon(Icons.edit, color: appWhite,),
          ),
          SizedBox(width: 10.0,),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(color: appWhite,),) : WillPopScope(
        onWillPop: () async {
          if (editState) {
            return false;
          } else {
            return true;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.02,),
              SizedBox(
                height: deviceHeight * 0.1,
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
                                      border: Border.all(color: appWhite),
                                      borderRadius: BorderRadius.circular(10.0)
                                      //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: text("${(newDate.day).toString()}/${(newDate.month).toString()}/${(newDate.year).toString()}", textColor: appColorPrimary),
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
                                          border: Border.all(color: appWhite),
                                          borderRadius: BorderRadius.circular(10.0)
                                        //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      ),
                                      child: text("${(newDate.day).toString()}/${(newDate.month).toString()}/${(newDate.year).toString()}"),
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 25),
                                child: text("Day " + (index + 1).toString())
                            ),
                          ),
                        ],
                      );
                    }
                ),
              ),
              SizedBox(height: deviceHeight * 0.02,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(child: text("Average cost for the day: ", maxLine: 2)),
                    SizedBox(width: 5,),
                    text("$rupees ${itinerary[selectedIndex]['dayCost']} / pp")
                  ],
                ),
              ),
              SizedBox(height: deviceHeight * 0.02,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: itinerary.isEmpty ? 0 : itinerary[selectedIndex]['places']['Place'].length,
                      itemBuilder: (context, index){
                      bool memory = true;
                      String img = itinerary[selectedIndex]['places']['Images'][index];
                      String new_img = "";
                      if(img.startsWith("data:image/jpeg;base64,")){
                        memory = true;
                        new_img = img.substring(23);
                      } else {
                        memory = false;
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
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
                                flex: 8,
                                child: GestureDetector(
                                  onLongPress: () async {
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        backgroundColor: appWhite,
                                        builder: (context) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              color: appWhite
                                            ),
                                            width: deviceWidth,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  horizontalTitleGap: 0.0,
                                                  leading: const Icon(Icons.reviews_outlined, color: appColorPrimary,),
                                                  title: text('Review', fontSize: 20.0, textColor: appColorPrimary, maxLine: 2),
                                                  onTap: () async {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext reviewContext) {
                                                          return AlertDialog(
                                                            backgroundColor: appWhite,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                                                            ),
                                                            title: text('Review ${itinerary[selectedIndex]['places']['Place'][index]}', textColor: appBlack, fontFamily: fontSemibold, maxLine: 2),
                                                            content: RatingBar.builder(
                                                              initialRating: 3,
                                                              minRating: 0.5,
                                                              direction: Axis.horizontal,
                                                              allowHalfRating: true,
                                                              itemCount: 5,
                                                              unratedColor: appDividerColor,
                                                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                              itemBuilder: (context, _) => Icon(
                                                                Icons.star,
                                                                color: Colors.yellow,
                                                                size: 16,
                                                              ),
                                                              onRatingUpdate: (r) {
                                                                print(r);
                                                                // setState(() {
                                                                //   rating = r;
                                                                // });
                                                              },
                                                            ),
                                                            actions: [
                                                              shadowButton("Submit", () async {
                                                                Navigator.pop(reviewContext);
                                                              }, appColorPrimary, deviceHeight),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                    });
                                  },
                                  child: Container(
                                    // height: deviceHeight * 0.18,
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: appWhite),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
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
                                                      image: memory ? DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: MemoryImage(base64Decode(new_img)),
                                                      ) : DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(img),
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
                                                      SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                                      Container(
                                                        margin: EdgeInsets.only(right: 25),
                                                        child: text(
                                                          itinerary[selectedIndex]['places']['Place'][index],
                                                          maxLine: 2,
                                                          fontSize: textSizeSMedium,
                                                          isBold: true,
                                                        ),
                                                      ),
                                                      SizedBox(height: deviceHeight * 0.15 * 0.02,),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          itinerary[selectedIndex]['places']['Avg Cost'][index].toString() == "0.0" ? text("Free") : text("$rupees ${itinerary[selectedIndex]['places']['Avg Cost'][index].toString()}"),
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
                                                            text("Food Options", fontSize: 14.0, maxLine: 1, isCentered: true, textColor: appColorAccent),
                                                            Icon(Icons.chevron_right_rounded, color: appColorAccent,)
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
                                        Positioned(
                                          right: 2,
                                          top: 2,
                                          child: GestureDetector(
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
                                              child: Icon(Icons.directions_outlined)
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              editState ? Expanded(
                                flex: 1,
                                  child: Checkbox(
                                      value: selectedPlace == index,
                                      onChanged: (val) {
                                    setState(() {
                                      selectedPlace = index;
                                    });
                                  })
                              ) : Container(),
                            ],
                          ),
                          SizedBox(height: deviceHeight * 0.02,),
                        ],
                      );
                    }
                ),
              ),
              SizedBox(height: deviceHeight * 0.02,),
            ],
          ),
        ),
      ),
    );
  }
}