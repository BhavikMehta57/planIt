// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:planit/authentication/Login.dart';
import 'package:planit/main/utils/AppColors.dart';
import 'package:planit/main/utils/AppConstant.dart';
import 'package:planit/main/utils/AppString.dart';
import 'package:planit/main/utils/AppWidget.dart';
import 'package:planit/main/utils/animation/fadeAnimation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:planit/navigationbar/userHome.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? fullName;
  String? companyName;
  String userEmail = '';
  String password = '';
  String? rePassword;
  bool isLoading = false;
  bool agree = true;

  startLoading() => setState(() {
    isLoading = true;
  });
  stopLoading() => setState(() {
    isLoading = false;
  });

  @override
  void initState() {
    super.initState();
  }

  Future<void> addUserToDatabase() async {
    await _firestore.collection("users").doc(userEmail).set({
      "Full Name": fullName,
      "Email": userEmail,
      "Password": password,
      "Profile Url": DefaultProfilPhotoURL,
      "Registered On": DateTime.now().toString(),
      "isVerified": true,
      "isBlocked": false,
      "isProfileComplete": false,
    });
  }

  // Future<void> sendEmail() async {
  //   String phone = '${countryCode!}${phoneNumber!}';
  //   try {
  //     String username = "planitbrainvita@gmail.com";//"brainvita5@gmail.com";
  //     String password = "dzzbglaumubloils";//"fouctsjoilonnqfh";
  //     final smtpServer = gmail(username,password);
  //     final message = Message()
  //       ..from = Address(username)
  //       ..recipients.add('planitbrainvita@gmail.com')
  //       ..subject = 'New User Signup for $phone' //subject of the email
  //       ..text = "Name: $fullName\nFather's Name: $fatherName\nMother's Name: $motherName\n"
  //           "Education: $education\nEmailID: $email\nPhone Number: $phone\n"
  //           "Date of Birth: $dateOfBirth\nTime of Birth: ${timeOfBirth.hour}:${timeOfBirth.minute}\nPlace of Birth: $placeOfBirth\n"
  //           "Franchise: $franchise";
  //     try {
  //       var connection = PersistentConnection(smtpServer);
  //       await connection.send(message).timeout(const Duration(seconds: 300));
  //       await connection.close();
  //       print('Message sent: ');
  //     } on MailerException catch (e) {
  //       print('Message not sent. \n'+ e.toString()); //print if the email is not sent
  //       // e.toString() will show why the email is not sending
  //       const snackBar = SnackBar(
  //         content: Text('SignUp Failed\nPlease Check your internet connection and try again'),
  //         duration: Duration(seconds: 10),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //   } catch(e){
  //     print(e.toString());
  //     const snackBar = SnackBar(
  //       content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
  //       duration: Duration(seconds: 10),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  Future<void> processRegisterRequest(context) async {
    try {
      final UserCredential userCreds = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: userEmail, password: password);
      final User? currentUser = FirebaseAuth.instance.currentUser;

      print("Adding to firestore");
      // Store user details in database
      await addUserToDatabase();
      //await sendEmail();
      assert(userCreds.user!.uid == currentUser!.uid);

      if (userCreds.user != null) {
        print("User Not Null, Signing In, Redirecting To Home");
        stopLoading();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => UserHome(currentIndex: 0,),
            ),
                (Route<dynamic> route) => false);
      } else {
        print("Auth Failed! (Login, from verify callback)");
        stopLoading();
        const snackBar = SnackBar(
          content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
          duration: Duration(seconds: 10),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e.toString());
      stopLoading();
      const snackBar = SnackBar(
        content: Text('SignUp Failed!\nPlease Check your internet connection and try again'),
        duration: Duration(seconds: 10),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: appWhite,
        appBar: AppBar(
          backgroundColor: appWhite,
          elevation: 0.0,
          leading: TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Container(
                  height: deviceHeight * 0.04,
                  width: deviceWidth * 0.08,
                  decoration: BoxDecoration(
                      color: appWhite,
                      border: Border.all(color: border_colour),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: Icon(Icons.chevron_left, color: appColorPrimary)
              )
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.05,),
                FadeAnimation(0.4, formHeading("Hello! Register to get started", TextColorPrimary)),
                SizedBox(height: deviceHeight * 0.05),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FadeAnimation(
                        0.8,
                        EditText(
                          //full name
                          onPressed: (value) {
                            fullName = value;
                          },
                          hintText: hint_fullName,
                          prefixIcon: fullnameIcon,
                          isPassword: false,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please enter your full name";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      FadeAnimation(
                        1.2,
                        EditText(
                          onPressed: (value) {
                            userEmail = value;
                          },
                          hintText: hint_email,
                          prefixIcon: emailIcon,
                          isPassword: false,
                          isPhone: false,
                          keyboardType: TextInputType.emailAddress,
                          validatefunc: (String? value) {
                            String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regExp = RegExp(pattern);
                            if (value!.isEmpty) {
                              return 'Please enter email address';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Please enter valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      FadeAnimation(
                        1.4,
                        EditText(
                          onPressed: (value) {
                            password = value;
                            print(password);
                          },
                          hintText: hint_password,
                          prefixIcon: passwordIcon,
                          isPassword: true,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please enter a password";
                            } else if (value.length < 6) {
                              return "Password must consist atleast 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      FadeAnimation(
                        1.6,
                        EditText(
                          onPressed: (value) {
                            rePassword = value;

                            print(rePassword);
                          },
                          hintText: hint_re_passwordText,
                          prefixIcon: passwordIcon,
                          isPassword: true,
                          isPhone: false,
                          validatefunc: (String? value) {
                            if (value!.isEmpty) {
                              return "Please re-enter your password";
                            } else if (value.length < 6) {
                              return "Password must consist atleast 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      FadeAnimation(
                        1.8,
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                side: BorderSide(color: appColorPrimary),
                                activeColor: TextColorPrimary,
                                value: agree,
                                onChanged: (value) {
                                  setState(() {
                                    agree = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                      text: "By Signing Up, You agree with the \n",
                                      style: TextStyle(
                                          color: TextColorPrimary
                                      ),
                                      children:[
                                        TextSpan(
                                          text: "Terms of Use",
                                          style: TextStyle(
                                              color: TextColorLinks,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () {
                                            // Navigator.of(context).push(
                                            //     MaterialPageRoute(
                                            //       builder: (context) => TermsOfUse(),
                                            //     )
                                            // );
                                          },
                                        ),
                                        TextSpan(
                                          text: " & ",
                                          style: TextStyle(
                                              color: TextColorPrimary
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                              color: TextColorLinks,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () {
                                            // Navigator.of(context).push(
                                            //     MaterialPageRoute(
                                            //       builder: (context) => SDSplashScreen(),
                                            //     )
                                            // );
                                          },
                                        ),
                                      ]
                                  ),
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.02),
                      isLoading
                          ?
                      const CircularProgressIndicator(color: appColorPrimary,)
                          :
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: FadeAnimation(
                          1.8,
                          shadowButton(
                              sign_upText,
                                  () async {
                                if (_formKey.currentState!.validate() && agree) {
                                  startLoading();
                                  if (rePassword == password) {
                                    //Check if mobile number is already registered
                                    try {
                                      DocumentSnapshot ds =
                                      await _firestore
                                          .collection("users")
                                          .doc(userEmail)
                                          .get();

                                      if (ds.exists) {
                                        const snackBar = SnackBar(
                                          content: Text(
                                              'User with this email already exists !'),
                                          duration:
                                          Duration(seconds: 3),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        stopLoading();
                                        return;
                                      } else {
                                        // Process registration
                                        await processRegisterRequest(
                                            context);
                                      }
                                    } catch (e) {
                                      print(e);
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'Some error occurred! Please check you internet connection.'),
                                        duration: Duration(seconds: 3),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      stopLoading();
                                      return;
                                    }
                                  } else {
                                    const snackBar = SnackBar(
                                      content: Text(
                                          'Passwords do not match'),
                                      duration: Duration(seconds: 3),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    stopLoading();
                                    return;
                                  }
                                }
                              }, appColorPrimary, deviceHeight
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
                FadeAnimation(
                  2.0,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      text(already_have_account,
                          textColor: textSecondaryColor,
                          fontSize: textSizeLargeMedium),
                      SizedBox(width: deviceWidth * 0.02),
                      GestureDetector(
                        onTap: () {
                          Login().launch(context);
                        },
                        child: text("Login Now",
                            fontFamily: fontMedium,
                            textColor: TextColorLinks),
                      )
                    ],
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
              ],
            ),
          ),
        )
    );
  }
}
