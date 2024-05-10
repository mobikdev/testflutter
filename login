// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:QuixiCareService/cutom_widgets/button.dart';
import 'package:QuixiCareService/uiltis/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../uiltis/notifiction.dart';
import 'signup form/signup.dart';
import 'signup form/signup_form1.dart';
import 'signup form/signup_form2.dart';
import 'signup form/signup_form3.dart';
import 'verify_otp.dart';

class UserProgressHelper {
  static const String _progressKey = 'user_progress';

  static Future<int> getUserProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_progressKey) ?? 0;
  }

  static Future<void> setUserProgress(int progress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey, progress);
  }
}

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int screen = 0;
  String otpValue = '';
  String? id;
  int? shopStatus;
  String? retrievedId;
  var ll = 10;

  // NotificationService notificationService = NotificationService();
  // var fcmToken = "0";

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                width: w / 2,
                child: Image.asset(
                  "assets/image/logo1.png",
                ),
              ),
              const Text(
                "Devbhoomi Seller Login",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30),
                child: IntlPhoneField(
                  onCountryChanged: (value) {
                    setState(() {
                      ll = value.maxLength;
                    });
                  },
                  controller: mobilelogin,
                  flagsButtonPadding: const EdgeInsets.all(8),
                  decoration: const InputDecoration(
                    hintText: "Mobile Number",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 0.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  initialCountryCode: 'IN',
                  onSubmitted: (phone) {
                    if (phone != null && phone.contains(RegExp(r'[0-5]'))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid number.'),
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0, left: 30),
                child: Button_widget(
                  buttontext: "Continue",
                  button_height: 17,
                  button_weight: 1.1,
                  onpressed: () async {
                    String mobileNumber = mobilelogin.text;
                    //_login(mobileNumber);
                    if (mobilelogin.text.isEmpty
                    ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter mobile number'),
                        ),
                      );
                      return;
                    }else {
                      RequestLogin(context, mobilelogin.text, "fcm_id");
                    }


                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.hintext_shop,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      "Signup",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: colors.button_color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      int userProgress =
                          await UserProgressHelper.getUserProgress();
                      if (userProgress == 0) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => Signup()),
                        // );
                      } else if (userProgress == 1) {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => Signup_form1()),
                        // );
                      } else if (userProgress == 2) {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => Signup_form2()),
                        // );
                      } else if (userProgress == 3) {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const Signup_form3()),
                        // );
                      } else {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => Signup()),
                        // );
                      }
                       Get.to(Signup());
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

 /* Future<bool> makeApiCall(String mobile, fcm) async {
    final url =
        Uri.parse('https://logicalsofttech.com/QuixiCare/Vendor_api/vendor_login');

    final Map<String, dynamic> data = {
      'mobile': mobile,
      'fcm': fcm.toString(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        final id = data['id'];
        //final shopStatus = data['shop_status'];
        final otp = data['otp'];
        otpValue = otp.toString();
        print("data success test");
        print(data);
        print('API response: ${response.body}');
        print('ID from the response: $id');
        //print('Shop Status from the response: $shopStatus');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('id', id);
        //prefs.setInt('shop_status', shopStatus);
       // Get.to(Verify());
        setState(() {
          this.id = id;
        });

        return true;
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        final message = jsonResponse['message'];
        print('API call failed with status code 400: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
        return false;
      } else {
        print('API call failed with status code ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please Wait You Need to Approved"),
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error making API call: $e');
      return false;
    }
  }*/

  //-------------- Api Calling -----------------

  Future<void> RequestLogin(
      BuildContext context,
      String mobileNo,
      String fcm_id,

      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://logicalsofttech.com/QuixiCare/Vendor_api/vendor_login'),
    );
    request.fields['mobile'] = mobileNo;
    request.fields['fcm_id'] = fcm_id;

    try {
      var response = await request.send();
      var responseStream = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseStream);
      print(jsonResponse);
      if (jsonResponse['result'] == 'true') {
        var userId = jsonResponse['data']['id'];
        var categoryid = jsonResponse['data']['category_id'];
        var otp = jsonResponse['data']['otp'];
        print("otp----$otp");
        prefs.setString("userid", userId);
        prefs.setString("catid", categoryid);
        otpValue = otp.toString();
        Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(
            builder: (_) => Verify()), (route) => false);
        //Get.snackbar("Note", jsonResponse['msg']);
        Get.snackbar("OTP",otp);
      } else {
        //prefs.setBool("isLogin", false);
        Get.snackbar("Note", jsonResponse['msg']);
      }
    } on SocketException catch (e) {
      Get.snackbar('Exception', e.toString());
    } on FormatException catch (e) {
      Get.snackbar('Exception', e.toString());
    } catch (e) {
      Get.snackbar('Exception', e.toString());
    }
  }


  TextEditingController mobilelogin = TextEditingController();
}
