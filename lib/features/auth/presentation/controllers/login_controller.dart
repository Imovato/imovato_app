import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../shared/services/auth_storage_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({this.demoMode = false}) {
    if (demoMode) {
      isLoggedIn = true;
      userEmail = 'demo@imovato.app';
      userName = 'Marina Demo';
      userId = 'demo-user';
      authToken = 'demo-token';
    }
  }

  final bool demoMode;
  bool loading = false;
  bool isLoggedIn = false;
  String? errorMessage;
  String? userEmail;
  String? userName;
  String? authToken;
  String? userId; // ID real do MongoDB

  final AuthStorageService _authStorage = AuthStorageService();

  Future<bool> signIn(String email, String password) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final requestBody = {
        'email': email,
        'password': password,
      };

      print('\n🔧 === COMANDO CURL LOGIN ===');
      print(
          "curl --location 'https://cadastral-imovato-35ca7e6548df.herokuapp.com/auth' \\");
      print("--header 'Content-Type: application/json' \\");
      print("--data-raw '${jsonEncode(requestBody)}'");
      print('============================\n');

      final response = await http.post(
        Uri.parse('https://cadastral-imovato-35ca7e6548df.herokuapp.com/auth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Decodificar resposta
        final data = jsonDecode(response.body);

        print('\n🔍🔍🔍 === DEBUGGING LOGIN === 🔍🔍🔍');
        print('Status Code: ${response.statusCode}');
        print('Body completo: ${response.body}');
        print('Data tipo: ${data.runtimeType}');
        print('Keys disponíveis: ${data.keys.toList()}');
        print('\nValores dos campos:');
        data.forEach((key, value) {
          if (key.toString().toLowerCase().contains('id') ||
              key.toString().toLowerCase().contains('user')) {
            print('  ⭐ $key: $value (${value.runtimeType})');
          } else {
            final valueStr = value.toString();
            print(
                '  $key: ${valueStr.length > 50 ? valueStr.substring(0, 50) + "..." : valueStr}');
          }
        });
        print('=====================================\n');

        // Extrair o token da resposta
        authToken = data['token'];
        if (authToken == null || authToken!.isEmpty) {
          errorMessage = 'Token não recebido do servidor';
          return false;
        }

        // Salvar token no storage
        await _authStorage.saveToken(authToken!);

        // Extrair dados do usuário
        userEmail = email;
        userName = data['userName'] ??
            data['name'] ??
            data['username'] ??
            email.split('@').first;

        // Tentar extrair userId de TODAS as formas possíveis
        String? extractedUserId;

        // 1. Tentar pegar do response body diretamente
        if (data['userId'] != null) {
          extractedUserId = data['userId'].toString();
          print('✅ userId encontrado no body: $extractedUserId');
        } else if (data['id'] != null) {
          extractedUserId = data['id'].toString();
          print('✅ id encontrado no body: $extractedUserId');
        } else if (data['_id'] != null) {
          extractedUserId = data['_id'].toString();
          print('✅ _id encontrado no body: $extractedUserId');
        } else if (data['user'] != null && data['user'] is Map) {
          final userObj = data['user'] as Map;
          extractedUserId = userObj['id']?.toString() ??
              userObj['_id']?.toString() ??
              userObj['userId']?.toString();
          if (extractedUserId != null) {
            print('✅ ID encontrado dentro de user: $extractedUserId');
          }
        }

        // 2. Se não encontrou, tentar decodificar o JWT
        if (extractedUserId == null || extractedUserId.isEmpty) {
          try {
            print('\n🔓 === DECODIFICANDO JWT PARA EXTRAIR userId ===');
            final decodedToken = JwtDecoder.decode(authToken!);
            print('📦 Payload completo do JWT:');
            decodedToken.forEach((key, value) {
              print('   $key: $value');
            });

            // Verificar timestamps para detectar problemas de sincronização
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final iat = decodedToken['iat'] as int?;
            final exp = decodedToken['exp'] as int?;

            print('\n🕐 Verificação de Timestamps:');
            print('   Agora (epoch): $now');
            print('   Agora (data): ${DateTime.now().toIso8601String()}');
            if (iat != null) {
              final iatDate = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
              print('   iat (emitido em): $iat → ${iatDate.toIso8601String()}');
              if (iat > now) {
                print(
                    '   ⚠️⚠️⚠️ ALERTA: Token emitido no FUTURO! Diferença: ${iat - now}s');
                print('   ➡️ Isso causará erro 401 nas requisições!');
                print(
                    '   🔧 Solução: Sincronizar relógio do dispositivo ou backend');
              }
            }
            if (exp != null) {
              final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
              print('   exp (expira em): $exp → ${expDate.toIso8601String()}');
              print(
                  '   Válido por: ${exp - now} segundos (${((exp - now) / 60).toStringAsFixed(1)} minutos)');
            }

            // Tentar extrair de vários campos possíveis
            extractedUserId = decodedToken['sub']?.toString() ??
                decodedToken['userId']?.toString() ??
                decodedToken['id']?.toString() ??
                decodedToken['user_id']?.toString() ??
                decodedToken['uid']?.toString();

            if (extractedUserId != null && extractedUserId.isNotEmpty) {
              print(
                  '✅ userId extraído do JWT (campo "sub" ou similar): $extractedUserId');
            } else {
              print('⚠️ Nenhum campo de ID encontrado no JWT');
            }
            print('===============================================\n');
          } catch (e) {
            print('❌ Erro ao decodificar JWT: $e');
          }
        }

        // 3. Se ainda não encontrou, usar email como fallback
        if (extractedUserId == null || extractedUserId.isEmpty) {
          print('⚠️⚠️⚠️ NENHUM userId ENCONTRADO NA RESPOSTA NEM NO JWT!');
          print('⚠️ Usando email como fallback: $email');
          extractedUserId = email;
        }

        userId = extractedUserId;

        print('\n✅ === DADOS EXTRAÍDOS ===');
        print('   User ID: $userId');
        print('   Email: $userEmail');
        print('   Name: $userName');
        print('   Token: ${authToken?.substring(0, 20)}...');
        print('==========================\n');

        // Salvar dados do usuário incluindo o userId
        await _authStorage.saveUserData(
            email: userEmail, name: userName, userId: userId);

        isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        // Tentar extrair mensagem de erro da resposta
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Erro na autenticação';
        } catch (_) {
          errorMessage = 'Erro na autenticação';
        }
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

  /// Restaura a sessão do usuário a partir do storage
  Future<void> restoreSession() async {
    final token = await _authStorage.getToken();
    if (token != null && token.isNotEmpty) {
      authToken = token;
      userEmail = await _authStorage.getUserEmail();
      userName = await _authStorage.getUserName();
      userId = await _authStorage.getUserId();
      isLoggedIn = true;
      notifyListeners();
    }
  }

  /// Retorna o token para uso em outras APIs
  Future<String?> getToken() async {
    return authToken ?? await _authStorage.getToken();
  }

  void logout() async {
    isLoggedIn = false;
    userEmail = null;
    userName = null;
    authToken = null;
    userId = null;
    await _authStorage.clearAuthData();
    notifyListeners();
  }
}
