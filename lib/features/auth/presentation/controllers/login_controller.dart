import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends ChangeNotifier {
  bool loading = false;
  bool isLoggedIn = false;
  String? errorMessage;

  Future<bool> signIn(String email, String password) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('https://cadastral-imovato-35ca7e6548df.herokuapp.com/auth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Erro na autenticação';
        return false;
      }
    } catch (e) {
      errorMessage = 'Erro ao conectar: $e';
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
