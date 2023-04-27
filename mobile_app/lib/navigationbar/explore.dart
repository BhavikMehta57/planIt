// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Explore extends StatefulWidget {
  static String tag = '/Explore';

  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List allPlacesList = [];
  List filteredPlacesList = [];
  String? searchPlace = "";
  String? sort = "";
  late TabController filterTabController;
  Map<String, bool> cityFilterList = {
    'Mumbai': false,
    'Delhi': false,
    'Chennai': false,
    'Hyderabad': false,
  };
  Map<String, bool> typeFilterList = {
    "Religious": false,
    "Heritage": false,
    "Entertainment": false,
    "Leisure": false,
    "Beaches": false,
    "Shopping": false,
    "Food": false,
    "Nature & Wildlife": false,
    "Art & Museum": false,
    "Malls": false,
  };

  @override
  void initState() {
    super.initState();
    filterTabController = TabController(length: 2, vsync: this);
    getPlaces();
  }

  Future<void> getPlaces() async {
    String url = "http://$ipAddress/places";
    final response = await http.get(Uri.parse(url), headers: {"Accept" : "application/json"});
    var responseData = json.decode(response.body);
    setState(() {
      allPlacesList = responseData['result']['data'];
      filteredPlacesList = List.from(allPlacesList);
    });
  }

  Future<void> sortPlaces() async {
    List tempPlaceList = List.from(allPlacesList);
    if (sort == "bestMatch") {} else if (sort == "priceAscending") {
      tempPlaceList.sort((a, b) => double.parse(a[12].toString().replaceAll(",", "")).compareTo(double.parse(b[12].toString().replaceAll(",", ""))));
    } else if (sort == "priceDescending") {
      tempPlaceList.sort((a, b) => double.parse(b[12].toString().replaceAll(",", "")).compareTo(double.parse(a[12].toString().replaceAll(",", ""))));
    } else if (sort == "ratingAscending") {
      tempPlaceList.sort((a, b) => double.parse(a[6].toString()).compareTo(double.parse(b[6].toString())));
    } else if (sort == "ratingDescending") {
      tempPlaceList.sort((a, b) => double.parse(b[6].toString()).compareTo(double.parse(a[6].toString())));
    } else {}
    setState((){
      filteredPlacesList = List.from(tempPlaceList);
    });
  }

  Future<void> sortFilteredPlaces() async {
    List tempPlaceList = List.from(filteredPlacesList);
    if (sort == "bestMatch") {} else if (sort == "priceAscending") {
      tempPlaceList.sort((a, b) => double.parse(a[12].toString().replaceAll(",", "")).compareTo(double.parse(b[12].toString().replaceAll(",", ""))));
    } else if (sort == "priceDescending") {
      tempPlaceList.sort((a, b) => double.parse(b[12].toString().replaceAll(",", "")).compareTo(double.parse(a[12].toString().replaceAll(",", ""))));
    } else if (sort == "ratingAscending") {
      tempPlaceList.sort((a, b) => double.parse(a[6].toString()).compareTo(double.parse(b[6].toString())));
    } else if (sort == "ratingDescending") {
      tempPlaceList.sort((a, b) => double.parse(b[6].toString()).compareTo(double.parse(a[6].toString())));
    } else {}
    setState((){
      filteredPlacesList = List.from(tempPlaceList);
    });
  }
  
  Future<void> filterPlaces(String searchValue) async {
    List tempPlacesList = List.from(allPlacesList);
    tempPlacesList.retainWhere((element) => element[0].toString().toLowerCase().contains(searchValue.toLowerCase()));
    setState(() {
      filteredPlacesList = List.from(tempPlacesList);
    });
  }

  Future<void> applyFilterPlaces() async {
    List tempPlacesList = List.from(allPlacesList);

    if (cityFilterList.containsValue(true)) {
      Map<String, bool> tempCityFilterList = Map.from(cityFilterList);
      tempCityFilterList.removeWhere((key, value) => (value == false));
      tempPlacesList.retainWhere((element) => tempCityFilterList.keys.toList().contains(element[1]));
    }

    if (typeFilterList.containsValue(true)) {
      Map<String, bool> tempTypeFilterList = Map.from(typeFilterList);
      tempTypeFilterList.removeWhere((key, value) => (value == false));
      tempPlacesList.retainWhere((element) => tempTypeFilterList.keys.toList().contains(element[10]));
    }

    setState(() {
      filteredPlacesList = List.from(tempPlacesList);
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: text(
                    "Explore Places all over India",
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
                      searchPlace = value;
                      await filterPlaces(value);
                    },
                    hintText: "Search Place by Name",
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
                                  TabBar(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      isScrollable: true,
                                      physics: BouncingScrollPhysics(),
                                      controller: filterTabController,
                                      tabs: [
                                        Tab(child: text('Filter'),),
                                        Tab(child: text('Sort'),),
                                      ]
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                        controller: filterTabController,
                                        children: [
                                          Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      text("Select City"),
                                                      Wrap(
                                                        spacing: 5.0,
                                                        runSpacing: 5.0,
                                                        children: cityFilterList.keys.toList().map((String choice) {
                                                          return Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              CustomCheckbox(
                                                                isChecked: cityFilterList[choice],
                                                                onChange: (bool? val) {
                                                                  setState((){
                                                                    cityFilterList[choice] = val!;
                                                                  });
                                                                },
                                                              ),
                                                              text(choice,),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                      text("Select Types"),
                                                      Wrap(
                                                        spacing: 5.0,
                                                        runSpacing: 5.0,
                                                        children: typeFilterList.keys.toList().map((String choice) {
                                                          return Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              CustomCheckbox(
                                                                isChecked: typeFilterList[choice],
                                                                onChange: (bool? val) {
                                                                  setState((){
                                                                    typeFilterList[choice] = val!;
                                                                  });
                                                                },
                                                              ),
                                                              text(choice,),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                                child: filterButton("Filter", () async {
                                                  applyFilterPlaces();
                                                  Navigator.pop(context);
                                                }, appWhite, deviceHeight),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
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
                                                  if (searchPlace == "") {
                                                    await sortPlaces();
                                                  } else {
                                                    await sortFilteredPlaces();
                                                  }
                                                  Navigator.pop(context);
                                                }, appWhite, deviceHeight),
                                              )
                                            ],
                                          )
                                        ]
                                    ),
                                  ),
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
            ListView.builder(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredPlacesList.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                bool memory = true;
                String img = filteredPlacesList[index][14];
                String new_img = "";
                if(img.startsWith("data:image/jpeg;base64,")){
                  memory = true;
                  new_img = img.substring(23);
                } else {
                  memory = false;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // setState(() {
                        //   selected = index;
                        // });
                        // print(filteredPlacesList[selected!]['Name']);
                      },
                      child: Container(
                        // height: deviceHeight * 0.18,
                        margin: EdgeInsets.symmetric(horizontal: 20),
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
                                              filteredPlacesList[index][0],
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
                                              text("$rupees ${filteredPlacesList[index][12].toString()}"),
                                              SizedBox(width: deviceWidth * 0.05),
                                              text(filteredPlacesList[index][6].toString()),
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
                                            filteredPlacesList[index][10],
                                            maxLine: 2,
                                            fontSize: textSizeSMedium,
                                            isBold: true,
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
                                    final String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=${filteredPlacesList[index][4]},${filteredPlacesList[index][5]}";
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
                    SizedBox(height: deviceHeight * 0.02,),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}