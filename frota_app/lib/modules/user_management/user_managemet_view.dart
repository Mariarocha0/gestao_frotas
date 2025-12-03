import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_form_view.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final String baseUrl = 'http://10.0.2.2:3000';
  List<dynamic> usuarios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> carregarUsuarios() async {
    setState(() => carregando = true);
    try {
      final token = await _getToken();
      if (token == null) {
        setState(() => carregando = false);
        return;
      }
      final resp = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          usuarios = data['users'] ?? [];
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
        debugPrint('Erro ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      setState(() => carregando = false);
      debugPrint('Falha ao carregar usuários: $e');
    }
  }

  Future<void> _excluirUsuario(int id) async {
    final token = await _getToken();
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja remover este usuário?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );

    if (confirm != true) return;

    final resp = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário removido.')));
      await carregarUsuarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${resp.body}')));
    }
  }

  Future<void> _novoUsuario() async {
    final createdOrEdited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const UserFormView()),
    );
    if (createdOrEdited == true) {
      await carregarUsuarios();
    }
  }

  Future<void> _editarUsuario(Map<String, dynamic> user) async {
    final createdOrEdited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => UserFormView(user: user)),
    );
    if (createdOrEdited == true) {
      await carregarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Usuários"),
        backgroundColor: const Color(0xFF1B286C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B286C),
        onPressed: _novoUsuario,
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarUsuarios,
              child: usuarios.isEmpty
                  ? const Center(child: Text("Nenhum usuário encontrado."))
                  : ListView.builder(
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final user = usuarios[index];
                        final name = (user['name'] ?? 'U').toString();
                        final email = (user['email'] ?? '').toString();
                        final role = (user['role'] ?? '').toString();

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1B286C),
                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("$email • $role"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  onPressed: () => _editarUsuario(user),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _excluirUsuario(user['id'] as int),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
