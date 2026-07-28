import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PasswordResetController extends ChangeNotifier {
  bool loading = false;
  String? errorMessage;
  String? infoMessage;
  String? resetToken;
  String? resetTokenExpiresAt;

  Future<bool> requestReset(String email) async {
    loading = true;
    errorMessage = null;
    infoMessage = null;
    resetToken = null;
    resetTokenExpiresAt = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          'https://cadastral-imovato-35ca7e6548df.herokuapp.com/auth/forgot-password',
        ),
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        infoMessage = data['message']?.toString() ??
            'Se o e-mail existir, um token de recuperação foi enviado.';
        resetToken = data['resetToken']?.toString();
        resetTokenExpiresAt = data['expiresAt']?.toString();
        return true;
      }

      errorMessage = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Não foi possível solicitar a recuperação de senha.';
      return false;
    } catch (e) {
      errorMessage = 'Erro ao conectar: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    loading = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          'https://cadastral-imovato-35ca7e6548df.herokuapp.com/auth/reset-password',
        ),
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        infoMessage = response.body.replaceAll('"', '');
        return true;
      }

      errorMessage = response.body.replaceAll('"', '');
      return false;
    } catch (e) {
      errorMessage = 'Erro ao conectar: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
