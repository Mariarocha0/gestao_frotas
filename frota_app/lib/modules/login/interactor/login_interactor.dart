import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginInteractor {
  final String baseUrl = "http://10.0.2.2:3000"; 
  // ⚠️ Se usar celular físico, troque por seu IP local (ex: http://192.168.x.x:3000)

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao fazer login: ${response.body}');
    }
  }
}
