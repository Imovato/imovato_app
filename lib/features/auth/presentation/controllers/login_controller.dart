import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  bool loading = false;
  bool isLoggedIn = false;

  Future<bool> signIn(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      // TODO: implementar chamada no endpoint de auth
      await Future.delayed(const Duration(milliseconds: 900));

      final ok = password == '123456';
      if (ok) {
        isLoggedIn = true;
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}
