import 'package:flutter/material.dart';
import '../../dashboard/view/dashboard_view.dart';

class LoginRouter {
  void irParaDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardView()),
    );
  }
}
