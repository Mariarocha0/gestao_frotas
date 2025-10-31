import 'dart:io';
import 'package:flutter/material.dart';
import 'modules/login/presenter/login_presenter.dart';
import 'modules/login/interactor/login_interactor.dart';
import 'modules/login/router/login_router.dart';
import 'modules/login/view/login_view.dart';
import 'modules/dashboard/view/dashboard_view.dart';

/// 🔧 Corrige lentidão de DNS e SSL no Android Emulator / Windows
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Aceita certificados locais (somente para desenvolvimento)
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚙️ Aplica override global para conexões HTTP/HTTPS
  HttpOverrides.global = MyHttpOverrides();

  // Instancia MVP
  final interactor = LoginInteractor();
  final router = LoginRouter();
  final presenter = LoginPresenter(
    interactor: interactor,
    onError: (erro) => print("❌ Erro: $erro"),
    onSuccess: (resultado) => print("✅ Sucesso: $resultado"),
  );

  runApp(MyApp(presenter: presenter, router: router));
}

class MyApp extends StatelessWidget {
  final LoginPresenter presenter;
  final LoginRouter router;

  const MyApp({super.key, required this.presenter, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Frotas',
      theme: ThemeData(
        primaryColor: const Color(0xFF1B286C),
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginView(presenter, router),
        '/dashboard': (_) => const DashboardView(),
      },
    );
  }
}
