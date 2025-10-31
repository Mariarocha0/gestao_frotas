import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginInteractor {
  final String baseUrl = "http://10.0.2.2:3000";
  // Se usar celular físico, troque por seu IP local (ex: http://192.168.x.x:3000)

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('📡 Status code: ${response.statusCode}');
    print('📨 Resposta bruta: ${response.body}');

    if (response.statusCode == 200) {
      // Decodifica e força o tipo
      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      late Map<String, dynamic> data;

      // Cobre ambos os formatos possíveis de resposta
      if (decoded.containsKey('data') && decoded['data'] is Map) {
        // Caso venha com "success" e "data"
        data = Map<String, dynamic>.from(decoded['data'] as Map);
      } else if (decoded.containsKey('token')) {
        // Caso venha direto, sem "data"
        data = Map<String, dynamic>.from(decoded);
      } else {
        throw Exception('Formato de resposta inesperado: $decoded');
      }

      print('🟢 Dados extraídos: $data');
      return data;
    } else {
      print('❌ Erro no login: ${response.body}');
      throw Exception('Erro ao fazer login: ${response.body}');
    }
  }
}
