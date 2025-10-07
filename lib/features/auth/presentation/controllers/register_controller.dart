import 'package:flutter/foundation.dart';

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
        'id': id,
        'userName': userName,
        'password': password,
        'cpf': cpf,
        'email': email,
        'name': name,
        'type': type,
      };

      // TODO: chamar seu endpoint real, ex.:
      // final res = await http.post(url, body: jsonEncode(body), headers: {...});

      await Future.delayed(const Duration(milliseconds: 900));

      // Exemplo simples de “sucesso”
      final ok = password.length >= 6;
      return ok;
    } catch (_) {
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
