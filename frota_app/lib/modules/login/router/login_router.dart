import 'package:flutter/material.dart';

class LoginRouter {
  void goToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
}
