import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  bool loading = false;

  Future<bool> signIn(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      // TODO: aqui você chama seu AuthService (em core/services) ou repository
      await Future.delayed(const Duration(milliseconds: 900));

      // demo: qualquer senha "123456" entra, o resto falha
      final ok = password == '123456';
      return ok;
    } catch (_) {
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
