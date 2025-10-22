import '../interactor/login_interactor.dart';

class LoginPresenter {
  final LoginInteractor interactor;

  LoginPresenter(this.interactor);

  void login(String email, String password) {
    interactor.authenticate(email, password);
  }
}
