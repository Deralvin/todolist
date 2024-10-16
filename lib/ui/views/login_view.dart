import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/const/constant.dart';
import 'package:todolist/services/api_service.dart';
import 'package:todolist/ui/views/home_view.dart';
import 'package:todolist/ui/views/register_view.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  ApiService apiService = ApiService(baseUrl: base_url_api);
  TextEditingController emailTxt = TextEditingController();
  TextEditingController passTxt = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(K_BEARER_TOKEN, "");
  }

  void loginAttempt() async {
    Map<String, dynamic> dataLogin = {
      "password": passTxt.text,
      "username": emailTxt.text
    };
    final data = await apiService.postRequest(
      "/login",
      dataLogin,
    );

    if (data != null) {
      if (data.data['statusCode'] == 2110) {
        log("my data ${data.data}");
        await prefs.setString(K_BEARER_TOKEN, data.data['data']['token']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffFEC43F), Color(0xffE6B139)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome Back",
              style: GoogleFonts.poppins(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(Icons.email, 'Username', emailTxt),
            const SizedBox(height: 10),
            _buildTextField(Icons.lock, 'Password', passTxt, isPassword: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                loginAttempt();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xff13334d),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterView()),
                );
              },
              child: Text(
                'Don\'t have an account? Register',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xff13334d)),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: const Color(0xff13334d)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
