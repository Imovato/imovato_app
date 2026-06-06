import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterController extends ChangeNotifier {
  bool loading = false;

  Future<bool> signUp({
    String? id,
    required String userName,
    required String password,
    required String cpf,
    required String email,
    required String name,
    required String type, // 'ROLE_HOST' | 'ROLE_GUEST'
  }) async {
    loading = true;
    notifyListeners();
    try {
      // Monte o body aqui (sem DTO)
      final body = <String, dynamic>{
        'userName': userName,
        'password': password,
        'cpf': cpf,
        'email': email,
        'name': name,
        'type': type,
      };

      // Remover id se for nulo
      if (id != null) {
        body['id'] = id;
      }

      final url = Uri.parse('https://cadastral-imovato-35ca7e6548df.herokuapp.com/users');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(body),
      );

      // Verificar status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Erro ao registrar: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção ao registrar: $e');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
