import 'package:flutter/material.dart';
import '../presenter/login_presenter.dart';
import '../router/login_router.dart';


class LoginView extends StatelessWidget {
  final LoginPresenter presenter;
  final LoginRouter router;


  const LoginView(this.presenter, this.router, {super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold é a base visual da tela — fornece estrutura padrão (appbar, body, etc)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // cor de fundo suave
      body: SafeArea(
        // SafeArea evita que o conteúdo fique atrás da barra de status
        child: Center(
          child: SingleChildScrollView(
            // Evita erro de overflow quando o teclado abre
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Image.asset(
                  'assets/images/bus_logo.png',
                  height: 140,
                ),
                const SizedBox(height: 20),

                // TÍTULO
                const Text(
                  "Bem-vindo!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 27, 40, 108),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Faça login para continuar",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // CAMPO DE E-MAIL
                TextField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // CAMPO DE SENHA
                TextField(
                  obscureText: true, // oculta os caracteres
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // BOTÃO DE LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aqui vai a lógica de login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 27, 40, 108),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
