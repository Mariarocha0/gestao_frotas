import 'package:flutter/material.dart';
import 'modules/login/presenter/login_presenter.dart';
import 'modules/login/interactor/login_interactor.dart';
import 'modules/login/router/login_router.dart';
import 'modules/login/view/login_view.dart';

void main() {
  final interactor = LoginInteractor();
  final router = LoginRouter();
  final presenter = LoginPresenter(
    interactor: interactor,
    onError: (erro) => print("Erro: $erro"),
    onSuccess: (resultado) => print("Sucesso: $resultado"),
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
      home: LoginView(presenter, router),
    );
  }
}
