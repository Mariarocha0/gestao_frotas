import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🔧 Corrige lentidão de DNS no Windows + Android Emulator
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Aceita certificados locais (somente para ambiente de desenvolvimento)
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
class ApiService {
  final String baseUrl = "http://10.0.2.2:3000"; // Emulador Android
  // Se for celular físico: use seu IP local ex: "http://192.168.x.x:3000"

  /// LOGIN DO USUÁRIO

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("📩 [LOGIN] Status code: ${response.statusCode}");
      print("📩 [LOGIN] Resposta bruta: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Salva token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['user']['role']);
        await prefs.setString('nome', data['user']['name']);

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
    } catch (e) {
      return {"success": false, "message": "Erro inesperado: $e"};
    }
  }

  /// ==========================
  /// 🔹 OBTÉM DADOS DO USUÁRIO LOGADO
  /// ==========================
  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {"success": false, "message": "Token ausente. Faça login novamente."};
    }

    final url = Uri.parse('$baseUrl/auth/me');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        print("👤 Usuário logado: $user");

        // Atualiza cache local
        await prefs.setString('nome', user['name']);
        await prefs.setString('role', user['role']);

        return {"success": true, "user": user};
      } else if (response.statusCode == 401) {
        await prefs.clear();
        return {"success": false, "message": "Sessão expirada. Faça login novamente."};
      } else {
        return {"success": false, "message": "Erro ao buscar usuário logado."};
      }
    } catch (e) {
      return {"success": false, "message": "Falha ao buscar usuário: $e"};
    }
  }

  /// ==========================
  /// 🔹 VEÍCULOS (rota protegida)
  /// ==========================
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
