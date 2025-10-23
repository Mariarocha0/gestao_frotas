import 'view/login_view.dart';
import 'presenter/login_presenter.dart';
import 'interactor/login_interactor.dart';
import 'router/login_router.dart';

class LoginModule {
  static LoginView build() {
    final interactor = LoginInteractor();
    final presenter = LoginPresenter(
      interactor: interactor,
      onError: (error) {
        // Lógica de tratamento de erro
      },
      onSuccess: (data) {
        // Lógica de tratamento de sucesso
      },
    );
    final router = LoginRouter();

    return LoginView(presenter, router);
  }
}
