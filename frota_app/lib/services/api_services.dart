import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; 
  // ⚠️ se for testar no celular físico, troque por seu IP local ex: http://192.168.0.105:3000

  static Future<http.Response> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await http.post(
      url,
      body: {'email': email, 'password': senha},
    );
  }

  static Future<http.Response> getVehicles() async {
    final url = Uri.parse('$baseUrl/vehicles');
    return await http.get(url);
  }
}
