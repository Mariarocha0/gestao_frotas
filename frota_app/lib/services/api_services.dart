import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000"; // Emulador Android
  // Se for celular físico: troque por seu IP local ex: "http://192.168.0.10:3000"

  // LOGIN DO USUÁRIO
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Status code: ${response.statusCode}");
      print("Resposta bruta: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Salva o token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["message"] ?? "Erro desconhecido no servidor",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Sem conexão com o servidor. Verifique sua internet."
      };
    } on HttpException {
      return {"success": false, "message": "Erro ao se comunicar com o servidor."};
    } on FormatException {
      return {"success": false, "message": "Erro ao interpretar a resposta do servidor."};
    } catch (e) {
      return {"success": false, "message": "Erro inesperado: $e"};
    }
  }

  // ROTA PROTEGIDA 
  Future<Map<String, dynamic>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token ausente. Faça login novamente."};
    }

    final url = Uri.parse('$baseUrl/vehicles');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 403) {
        return {"success": false, "message": "Acesso negado. Token inválido ou expirado."};
      } else {
        return {"success": false, "message": "Erro inesperado: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Falha ao buscar veículos: $e"};
    }
  }
}
