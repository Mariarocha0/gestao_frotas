import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_managemet_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String? userName;
  String? userRole;
  List<String> userModules = [];
  bool carregando = false;

  static const String baseUrl = "http://10.0.2.2:3000"; 
  // Se for rodar em celular físico, troque pelo IP local da máquina ex: http://192.168.x.x:3000

  @override
  void initState() {
    super.initState();
    carregarLocalmente(); 
    carregarUsuarioOnline(); 
  }

  /// 🧭 Carrega dados salvos no cache (SharedPreferences)
  Future<void> carregarLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome');
    final role = prefs.getString('role');

    setState(() {
      userName = nome ?? "Usuário";
      userRole = role ?? "user";
      userModules = _definirModulosPorRole(userRole!);
    });
  }

  /// 🌐 Atualiza dados do usuário autenticado via API (rota /auth/me)
  Future<void> carregarUsuarioOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    setState(() => carregando = true);

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 4)); // evita travar o app

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          userName = data['name'] ?? "Usuário";
          userRole = data['role'] ?? "user";
          userModules = _definirModulosPorRole(userRole!);
        });

        await prefs.setString('nome', userName!);
        await prefs.setString('role', userRole!);

        print("✅ Usuário atualizado com sucesso: $userName ($userRole)");
      } else if (response.statusCode == 401) {
        print("⚠️ Token expirado, redirecionando para login...");
        await prefs.clear();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        print("⚠️ Erro inesperado no servidor: ${response.body}");
      }
    } on TimeoutException {
      print("⏰ Tempo limite atingido ao tentar conectar ao servidor.");
    } catch (e) {
      print("❌ Erro ao buscar usuário: $e");
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  /// 🔧 Define os módulos conforme o papel (role)
  List<String> _definirModulosPorRole(String role) {
    switch (role) {
      case 'admin':
        return ["checklist", "manutencao", "estoque", "abastecimento", "historico"];
      case 'oficina':
        return ["checklist", "manutencao", "historico"];
      case 'estoque':
        return ["estoque", "historico"];
      default:
        return ["checklist"];
    }
  }

  /// 🧩 Cria um cartão de módulo
  Widget buildModuleCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B286C), size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }

  /// 🚪 Logout seguro
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = userRole == "admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Frotas"),
        foregroundColor: const Color(0xFF1B286C),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      /// Drawer lateral dinâmico
      drawer: Drawer(
        backgroundColor: const Color(0xFFF8F6FF),
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1B286C),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF1B286C), size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName ?? "Usuário",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userRole?.toUpperCase() ?? "CARREGANDO...",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// Opções dinâmicas
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.supervised_user_circle, color: Color(0xFF1B286C)),
                      title: const Text("Gerenciar Usuários"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserManagementView()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart, color: Color(0xFF1B286C)),
                      title: const Text("Relatórios"),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Color(0xFF1B286C)),
                      title: const Text("Notificações"),
                      onTap: () => Navigator.pop(context),
                    ),
                  ] else if (userRole == "oficina") ...[
                    ListTile(
                      leading: const Icon(Icons.build, color: Color(0xFF1B286C)),
                      title: const Text("Manutenções"),
                      onTap: () => Navigator.pop(context),
                    ),
                  ] else if (userRole == "estoque") ...[
                    ListTile(
                      leading: const Icon(Icons.inventory, color: Color(0xFF1B286C)),
                      title: const Text("Controle de Estoque"),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Sair",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),

      /// Corpo principal
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarUsuarioOnline,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  if (userModules.contains("checklist"))
                    buildModuleCard("Checklist Diário", "Verifique os veículos", Icons.checklist, () {}),
                  if (userModules.contains("manutencao"))
                    buildModuleCard("Manutenção Preventiva", "Agende manutenções", Icons.build, () {}),
                  if (userModules.contains("estoque"))
                    buildModuleCard("Movimentações de Estoque", "Gerencie peças e materiais", Icons.inventory, () {}),
                  if (userModules.contains("abastecimento"))
                    buildModuleCard("Controle de Abastecimento", "Monitore consumo e custos", Icons.local_gas_station, () {}),
                  if (userModules.contains("historico"))
                    buildModuleCard("Histórico de Manutenções", "Consulte manutenções anteriores", Icons.history, () {}),
                ],
              ),
            ),
    );
  }
}
