import '../interactor/login_interactor.dart';

class LoginPresenter {
  final LoginInteractor interactor;
  final Function(String) onError;
  final Function(Map<String, dynamic>) onSuccess;

  LoginPresenter({
    required this.interactor,
    required this.onError,
    required this.onSuccess,
  });

  Future<void> login(String email, String password) async {
    try {
      final result = await interactor.login(email, password);
      onSuccess(result);
    } catch (e) {
      onError(e.toString());
    }
  }
}
