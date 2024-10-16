import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/const/constant.dart';
import 'package:todolist/services/api_service.dart';
import 'package:todolist/ui/views/login_view.dart';

class RegisterView extends StatefulWidget {
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController uNameTxt = TextEditingController();
  TextEditingController emailTxt = TextEditingController();
  TextEditingController passTxt = TextEditingController();
  late SharedPreferences prefs;
  ApiService apiService = ApiService(baseUrl: base_url_api);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData() async {
    prefs = await SharedPreferences.getInstance();
  }

  void registerAttempt() async {
    Map<String, dynamic> dataRegister = {
      "password": passTxt.text,
      "username": uNameTxt.text,
      "email": emailTxt.text
    };
    final data = await apiService.postRequest(
      "/register",
      dataRegister,
    );

    if (data != null) {
      if (data.data['statusCode'] == 2000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${data.data['message']}"),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(),
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
            colors: [Color(0xffE8704D), Color(0xffCF6445)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Create Account",
              style: GoogleFonts.poppins(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(Icons.person, 'Username', uNameTxt),
            const SizedBox(height: 10),
            _buildTextField(Icons.email, 'Email', emailTxt),
            const SizedBox(height: 10),
            _buildTextField(Icons.lock, 'Password', passTxt, isPassword: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                registerAttempt();
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
                'Register',
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
                Navigator.pop(context);
              },
              child: Text(
                'Already have an account? Login',
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
