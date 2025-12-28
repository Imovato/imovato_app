import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends ChangeNotifier {
  bool loading = false;
  bool isLoggedIn = false;
  String? errorMessage;
  String? userEmail;
  String? userName;

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
        // Tentar decodificar resposta se houver body
        try {
          final data = jsonDecode(response.body);
          userEmail = email;
          userName = data['userName'] ?? data['name'] ?? email.split('@').first;
        } catch (_) {
          // Se não conseguir decodificar, usa email
          userEmail = email;
          userName = email.split('@').first;
        }
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
    userEmail = null;
    userName = null;
    notifyListeners();
  }
}
