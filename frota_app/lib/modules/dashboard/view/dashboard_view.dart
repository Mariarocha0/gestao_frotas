import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Principal"),
        backgroundColor: const Color.fromARGB(255, 27, 40, 108),
      ),
      body: const Center(
        child: Text(
          "Bem-vindo ao Dashboard!",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
