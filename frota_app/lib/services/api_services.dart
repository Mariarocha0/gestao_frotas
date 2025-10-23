import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000"; // Emulador Android
  // Se for celular físico: substitua 10.0.2.2 pelo IP do seu computador local

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {"success": true, "data": data};
    } else {
      final error = jsonDecode(response.body);
      return {"success": false, "message": error["message"] ?? "Erro desconhecido"};
    }
  }
}
