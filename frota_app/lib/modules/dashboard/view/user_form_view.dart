import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserFormView extends StatefulWidget {
  final Map<String, dynamic>? user; // se vier, é edição

  const UserFormView({super.key, this.user});

  @override
  State<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> {
  final String baseUrl = 'http://10.0.2.2:3000';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  String _role = 'oficina';
  bool _salvando = false;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?['name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.user?['email'] ?? '');
    _role = widget.user?['role'] ?? 'oficina';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final token = await _getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão expirada')));
        return;
      }

      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _role,
      };

      // Senha só é enviada se preenchida (em edição é opcional)
      if (_passwordCtrl.text.trim().isNotEmpty) {
        body['password'] = _passwordCtrl.text.trim();
      }

      late http.Response resp;

      if (isEdit) {
        final id = widget.user!['id'];
        resp = await http.put(
          Uri.parse('$baseUrl/users/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      } else {
        if (!body.containsKey('password')) {
          // Para criação, exigimos senha
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informe a senha para o novo usuário.')),
          );
          setState(() => _salvando = false);
          return;
        }
        resp = await http.post(
          Uri.parse('$baseUrl/users'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Usuário atualizado!' : 'Usuário criado!')),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // avisa a tela anterior para recarregar
      } else {
        debugPrint('Erro ${resp.statusCode}: ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resp.body}')),
        );
      }
    } catch (e) {
      debugPrint('Falha ao salvar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Usuário' : 'Novo Usuário'),
        backgroundColor: const Color(0xFF1B286C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isEdit ? 'Senha (opcional)' : 'Senha',
                helperText: isEdit ? 'Deixe em branco para manter a senha atual.' : null,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (!isEdit && (v == null || v.trim().length < 4)) {
                  return 'A senha deve ter pelo menos 4 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Função', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                    DropdownMenuItem(value: 'oficina', child: Text('oficina')),
                    DropdownMenuItem(value: 'estoque', child: Text('estoque')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'oficina'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B286C)),
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(isEdit ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
