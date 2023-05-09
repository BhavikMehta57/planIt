// ignore_for_file: avoid_print, must_be_immutable, file_names, non_constant_identifier_names, prefer_const_constructors
import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/rendering.dart';
import 'package:nanoid/nanoid.dart';
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
import 'package:planit/screens/hotelList.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ItineraryForm extends StatefulWidget {
  static String tag = '/ItineraryForm';

  const ItineraryForm({Key? key}) : super(key: key);

  @override
  _ItineraryFormState createState() => _ItineraryFormState();
}

class _ItineraryFormState extends State<ItineraryForm> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPlanning = false;
  String destination = "Mumbai";
  String selectedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
  String selectedEndDate = "";
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String numberOfTravellers = "";
  String budget = "15K - 20K";
  List<String> areasOfInterest = ["Entertainment", "Leisure", "Shopping"];
  Map<String, bool> areasOfInterests = {
    "Religious": false,
    "Heritage": false,
    "Entertainment": true,
    "Leisure": true,
    "Beaches": false,
    "Shopping": true,
    "Food": false,
    "Nature & Wildlife": false,
    "Art & Museum": false,
    "Malls": false,
  };
  var budgetList = ["Below 10K", "10k - 15K", "15k - 20K", "20k - 30K", "30k - 40K", "40k - 50K", "Above 50K"];
  var destinationList = ["Mumbai", "Delhi", "Chennai" , "Hyderabad"];
  ScrollController scrollController = ScrollController();

  List hotelList = [];

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

  Future<void> getHotelsList(String city) async {
    String url = "http://$ipAddress/hotels/$city";
    final response = await http.get(Uri.parse(url), headers: {"Accept" : "application/json"});
    var responseData = json.decode(response.body);
    //print(responseData['result']['data']);
    setState(() {
      hotelList = responseData['result']['data'];
    });
  }

  // Future createJobDynamicLink() async {
  //   var parameters = DynamicLinkParameters(
  //     uriPrefix: 'https://planite.page.link',
  //     link: Uri.parse('https://planit/share?page=job'),
  //     androidParameters: AndroidParameters(
  //       packageName: "com.project.planit",
  //     ),
  //     // iosParameters: const IOSParameters(
  //     //   bundleId: "com.project.planit",
  //     //   appStoreId: '1498909115',
  //     // ),
  //   );
  //   // final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  //   // final Uri shortUrl = shortLink.shortUrl;
  //   final Uri dynamicUrl = await parameters.buildUrl();
  //   final ShortDynamicLink shortLink = await parameters.buildShortLink();
  //   final Uri shortUrl = shortLink.shortUrl;
  //   setState(() {
  //     shareJobLink = shortUrl.toString();
  //     print(shareJobLink);
  //   });
  // }

  void _pickStartDateDialog() {
    showDatePicker(
      builder: (context, child){
        return Theme(
          data: Theme.of(context).copyWith(
              cardColor: appWhite,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: appWhite, // button text color
                ),
              ),
              colorScheme: ColorScheme.dark(
                  primary: appColorPrimary,
                  onPrimary: appWhite
              )
            // ColorScheme.fromSwatch().copyWith(primary: appColorPrimary, secondary: appWhite),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2099,12,31),
      helpText: "Select Start Date",
      fieldLabelText: "Enter Start Date",
      fieldHintText: "Select Start Date",
      cancelText: "Cancel",
      confirmText: "Set",
    ).then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        selectedStartDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        startDateController.text = selectedStartDate;
      });
    });
  }

  void _pickEndDateDialog() {
    showDatePicker(
      builder: (context, child){
        return Theme(
          data: Theme.of(context).copyWith(
              cardColor: appWhite,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: appWhite, // button text color
                ),
              ),
              colorScheme: ColorScheme.dark(
                  primary: appColorPrimary,
                  onPrimary: appWhite
              )
            // ColorScheme.fromSwatch().copyWith(primary: appColorPrimary, secondary: appWhite),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.parse(selectedStartDate).add(Duration(days: 1)),
      firstDate: DateTime.parse(selectedStartDate).add(Duration(days: 1)),
      lastDate: DateTime(2099,12,31),
      helpText: "Select Start Date",
      fieldLabelText: "Enter Start Date",
      fieldHintText: "Select Start Date",
      cancelText: "Cancel",
      confirmText: "Set",
    ).then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        selectedEndDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        endDateController.text = selectedEndDate;
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
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        height: deviceHeight * 0.8,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: appWhite,
          // border: Border.all(color: appWhite),
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: deviceHeight * 0.02),
                  text(
                      "Create your trip",
                      textColor: appColorPrimary,
                      isCentered: true,
                      isBold: true,
                      fontSize: 24.0
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  // EditText(
                  //   isPrefixIcon: false,
                  //   onPressed: (value) {
                  //     destination = value;
                  //   },
                  //   hintText: "Enter your Destination",
                  //   // prefixIcon: emailIcon,
                  //   isPassword: false,
                  //   isPhone: false,
                  //   keyboardType: TextInputType.text,
                  //   validatefunc: (String? value) {
                  //     if (value!.isEmpty) {
                  //       return 'Please enter a destination';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      // border: Border.all(color: appColorPrimary, width: 0.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: DropdownButtonFormField2(
                      scrollbarAlwaysShow: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: edit_text_background,
                        //Add isDense true and zero Padding.
                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: appColorPrimary, width: 0.0),
                        ),
                        //Add more decoration as you want here
                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                      ),
                      isExpanded: true,
                      hint: const Text(
                        'Choose your Destination',
                        style: TextStyle(
                            color: hint_text_colour,
                            fontSize: textSizeMedium,
                            fontFamily: fontRegular
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: appBlack,
                      ),
                      iconSize: 30,
                      buttonHeight: 50,
                      buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      dropdownDecoration: BoxDecoration(
                        color: edit_text_background,
                        border: Border.all(color: appColorPrimary, width: 0.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      items: destinationList
                          .map((item) =>
                          DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: appColorPrimary,
                              ),
                            ),
                          )).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a destination';
                        }
                      },
                      onChanged: (value) {
                        destination = value.toString();
                        print(destination);
                      },
                      onSaved: (value) {
                        destination = value.toString();
                        print(destination);
                      },
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  EditText(
                    // onTap: () async {
                    //   _pickStartDateDialog();
                    // },
                    readOnly: true,
                    controller: startDateController,
                    isPrefixIcon: false,
                    onPressed: (value) {},
                    hintText: "Start Date",
                    suffixIcon: Icons.calendar_today,
                    suffixIconColor: appColorPrimary,
                    suffixIconOnTap: () {
                      _pickStartDateDialog();
                    },
                    isPassword: false,
                    isPhone: false,
                    keyboardType: TextInputType.text,
                    validatefunc: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please select a start date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  EditText(
                    // onTap: () async {
                    //   _pickEndDateDialog();
                    // },
                    readOnly: true,
                    controller: endDateController,
                    isPrefixIcon: false,
                    onPressed: (value) {},
                    hintText: "End Date",
                    suffixIcon: Icons.calendar_today,
                    suffixIconColor: appColorPrimary,
                    suffixIconOnTap: () {
                      _pickEndDateDialog();
                    },
                    isPassword: false,
                    isPhone: false,
                    keyboardType: TextInputType.text,
                    validatefunc: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please select an end date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  EditText(
                    isPrefixIcon: false,
                    onPressed: (value) {
                      numberOfTravellers = value;
                    },
                    hintText: "Number of Travellers",
                    isPassword: false,
                    isPhone: false,
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                    validatefunc: (String? value) {
                      String pattern = r'^-?[0-9]+$';
                      RegExp regExp = RegExp(pattern);
                      if (value!.isEmpty) {
                        return 'Please enter number of travellers';
                      } else if (!regExp.hasMatch(value)) {
                        return 'Please enter valid number of travellers';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          autofocus: false,
                          validator: (String? value) {
                            if (areasOfInterest.length < 3) {
                              return 'Please select atleast 3 areas of interest';
                            }
                            return null;
                          },
                          onChanged: (value) {},
                          style: TextStyle(color: appBlack, fontSize: textSizeLargeMedium, fontFamily: fontRegular),
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.arrow_drop_down, color: appColorPrimary,),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 5),
                            hintText: "Select areas of interest",
                            hintStyle: TextStyle(color: hint_text_colour, fontSize: textSizeMedium),
                            filled: true,
                            fillColor: edit_text_background,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                borderSide: const BorderSide(color: appColorPrimary, width: 0.0)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                              borderSide: const BorderSide(color: appColorPrimary, width: 0.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: appColorPrimary, width: 0.0),
                            ),
                          ),
                          cursorColor: TextColorSecondary,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        height: deviceHeight * 0.2,
                        decoration: BoxDecoration(
                          border: Border.all(color: appColorPrimary, width: 0.0),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0),
                          ),
                        ),
                        child: Theme(
                          data: ThemeData(
                            highlightColor: appColorPrimary, //Does not work
                          ),
                          child: CupertinoScrollbar(
                            isAlwaysShown: true,
                            controller: scrollController,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: areasOfInterests.length,
                              itemBuilder: (BuildContext context, int index) {
                                String key = areasOfInterests.keys.elementAt(index);
                                return ListTile(
                                  minVerticalPadding: 0.0,
                                  title: text(key, textColor: appColorPrimary),
                                  trailing: Checkbox(
                                    fillColor: MaterialStateProperty.all<Color>(edit_text_background),
                                    side: BorderSide(
                                      color: appColorPrimary,
                                      width: 0.0
                                    ),
                                    checkColor: appColorPrimary,
                                    activeColor: appWhite,
                                    value: areasOfInterests[key],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        areasOfInterests[key] = value!;
                                        value ? areasOfInterest.add(key) : areasOfInterest.remove(key);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 15),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: appColorPrimary, width: 0.0),
                  //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  //   ),
                  //   child: DropdownButtonFormField2(
                  //     decoration: InputDecoration(
                  //       filled: true,
                  //       fillColor: edit_text_background,
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.zero,
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(5),
                  //       ),
                  //       //Add more decoration as you want here
                  //       //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                  //     ),
                  //     isExpanded: true,
                  //     focusColor: appBlack,
                  //     hint: const Text(
                  //       'Choose your budget',
                  //       style: TextStyle(
                  //           color: hint_text_colour,
                  //           fontSize: textSizeMedium,
                  //           fontFamily: fontRegular
                  //       ),
                  //     ),
                  //     icon: const Icon(
                  //       Icons.arrow_drop_down,
                  //       color: appBlack,
                  //     ),
                  //     iconSize: 30,
                  //     buttonHeight: 50,
                  //     buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                  //     dropdownDecoration: BoxDecoration(
                  //       color: edit_text_background,
                  //       border: Border.all(color: appColorPrimary, width: 0.0),
                  //       borderRadius: BorderRadius.circular(15),
                  //     ),
                  //     items: budgetList
                  //         .map((item) =>
                  //         DropdownMenuItem<String>(
                  //           value: item,
                  //           child: Text(
                  //             item,
                  //             style: const TextStyle(
                  //               fontSize: 14,
                  //               color: appColorPrimary,
                  //             ),
                  //           ),
                  //         )).toList(),
                  //     validator: (value) {
                  //       if (value == null) {
                  //         return 'Please select a range for your budget';
                  //       }
                  //     },
                  //     onChanged: (value) {
                  //       budget = value.toString();
                  //       print(budget);
                  //     },
                  //     onSaved: (value) {
                  //       budget = value.toString();
                  //       print(budget);
                  //     },
                  //   ),
                  // ),
                  // SizedBox(height: deviceHeight * 0.02),
                  isPlanning
                      ?
                  const Center(
                      child: CircularProgressIndicator(color: appColorPrimary,)
                  ) :
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: deviceWidth * 0.2),
                    child: shadowButton("Plan It", () async {
                      setState((){
                        isPlanning = true;
                      });
                      if(_formKey.currentState!.validate() && DateTime.parse(selectedEndDate).difference(DateTime.parse(selectedStartDate)).inDays > 0){
                        int diff = DateTime.parse(selectedEndDate).difference(DateTime.parse(selectedStartDate)).inDays + 1;
                        String docId = nanoid(8);
                        try {
                          await getHotelsList(destination);
                          await FirebaseFirestore.instance.collection("plannerInput").doc(docId).set({
                            "Destination": destination,
                            "Start Date": selectedStartDate,
                            "End Date": selectedEndDate,
                            "Number of travellers": numberOfTravellers,
                            "Areas of Interest": areasOfInterest,
                            // "Budget": budget,
                            "Number of Days": diff,
                            "ItineraryID": docId,
                            "UserEmail": FirebaseAuth.instance.currentUser!.email,
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HotelList(hotelList: hotelList, itineraryID: docId, city: destination,)
                              )
                          );
                          setState((){
                            // showSuccessfulApplicationDialog("Data Uploaded", "Data sent to Firebase successfully");
                            isPlanning = false;
                          });
                        } catch(e) {
                          print(e);
                          const snackBar = SnackBar(
                            content: Text('Planning Failed\nPlease check your internet connection'),
                            duration: Duration(seconds: 10),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState((){
                            isPlanning = false;
                          });
                        }
                      } else {
                        setState((){
                          isPlanning = false;
                        });
                        if (DateTime.parse(selectedEndDate).difference(DateTime.parse(selectedStartDate)).inDays < 0) {
                          const snackBar = SnackBar(
                            content: Text('End Date cannot be before Start Date'),
                            duration: Duration(seconds: 10),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    }, appColorPrimary, deviceHeight),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                ],
              )
          ),
        ),
      ),
    );
  }
}