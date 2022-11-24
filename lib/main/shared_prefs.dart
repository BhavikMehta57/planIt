// import 'package:shared_preferences/shared_preferences.dart';
//
// class SharedPrefs{
//
//   static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
//   static String sharedPreferencePhoneKey = "PHONEKEY";
//
//   /// saving data to sharedpreference
//   static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{
//
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
//   }
//
//   static Future<bool> savePhoneSharedPreference(String Phone) async{
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return await preferences.setString(sharedPreferencePhoneKey, Phone);
//   }
//
//   /// fetching data from sharedpreference
//   static Future<bool?> getUserLoggedInSharedPreference() async{
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.getBool(sharedPreferenceUserLoggedInKey);
//   }
//
//   static Future<String?> getPhoneSharedPreference() async{
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.getString(sharedPreferencePhoneKey);
//   }
//
// }