import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _userIdKey = 'user_id';

  /// Salva o token de autenticação
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Recupera o token de autenticação
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Salva os dados do usuário
  Future<void> saveUserData({String? email, String? name, String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
    if (name != null) {
      await prefs.setString(_nameKey, name);
    }
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
  }

  /// Recupera o email do usuário
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Recupera o nome do usuário
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Recupera o ID do usuário
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Remove todos os dados de autenticação (logout)
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_userIdKey);
  }

  /// Verifica se existe um token salvo
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

