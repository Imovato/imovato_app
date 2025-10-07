import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  bool loading = false;

  Future<bool> signIn(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      // TODO: implementar chamada no endpoint de auth
      await Future.delayed(const Duration(milliseconds: 900));

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
