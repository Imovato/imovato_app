import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/services/auth_storage_service.dart';
import '../domain/booking_invite.dart';

/// Serviço responsável por gerenciar convites de reserva compartilhada
class InviteService {
  final AuthStorageService _authStorage = AuthStorageService();
  final String _baseUrl =
      'https://transacional-imovato-9daff7c83047.herokuapp.com';

  Future<String?> _getAuthToken() async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final decoded = JwtDecoder.decode(token);
      final exp = decoded['exp'] as int?;
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      print('🕐 Token exp: $exp | Agora: $nowEpoch | Diff: ${exp != null ? exp - nowEpoch : 'N/A'}s');
    } catch (e) {
      print('⚠️ Não foi possível decodificar o token: $e');
    }

    // Não bloqueamos localmente — a API retorna 401 se expirado
    return token;
  }

  /// Envia um convite para um usuário participar de uma reserva
  ///
  /// [bookingId]  – ID da reserva
  /// [guestId]    – ID do usuário convidado
  ///
  /// Retorna o JSON de resposta ou lança Exception em caso de erro.
  Future<Map<String, dynamic>> sendInvite({
    required String bookingId,
    required String guestId,
  }) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final url = Uri.parse('$_baseUrl/bookings/$bookingId/invites');
    final body = jsonEncode({'guestId': guestId});

    print('\n📨 === ENVIANDO CONVITE ===');
    print('URL: $url');
    print('Body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return {'success': true};
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'success': true};
      }
    } else if (response.statusCode == 401) {
      // Verifica se é token expirado ou permissão insuficiente
      final wwwAuth = response.headers['www-authenticate'] ?? '';
      if (wwwAuth.contains('Basic realm')) {
        throw Exception(
            'Sem permissão para enviar convites. Verifique as configurações do backend.');
      }
      throw Exception('Sessão expirada. Faça login novamente.');
    } else if (response.statusCode == 404) {
      throw Exception('Reserva ou usuário não encontrado.');
    } else if (response.statusCode == 400) {
      String msg = 'Dados inválidos.';
      try {
        final err = jsonDecode(response.body);
        msg = err['message']?.toString() ?? msg;
      } catch (_) {}
      throw Exception(msg);
    } else {
      throw Exception('Erro ao enviar convite (${response.statusCode}).');
    }
  }

  /// Busca um usuário pelo e-mail para validar antes de convidar
  ///
  /// Retorna os dados do usuário ou null se não encontrado.
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final url = Uri.parse(
        'https://cadastral-imovato-35ca7e6548df.herokuapp.com/users/email/${Uri.encodeComponent(email)}');

    print('\n🔍 === BUSCANDO USUÁRIO POR EMAIL ===');
    print('URL: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('❌ Body está vazio!');
          return null;
        }
        try {
          final decoded = jsonDecode(response.body);
          print('✅ Decoded JSON: $decoded');
          print('✅ Type: ${decoded.runtimeType}');

          if (decoded is Map<String, dynamic>) {
            print('✅ Campos disponíveis: ${decoded.keys.toList()}');
            return decoded;
          } else if (decoded is List && decoded.isNotEmpty) {
            print('⚠️ API retornou lista, usando primeiro elemento');
            return decoded.first as Map<String, dynamic>;
          } else {
            print('❌ Formato inesperado: $decoded');
            return null;
          }
        } catch (parseError) {
          print('❌ Erro ao fazer parse do JSON: $parseError');
          return null;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Token inválido ou expirado! Status: ${response.statusCode}');
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 404) {
        print('ℹ️ Usuário não encontrado (404)');
        return null;
      } else {
        print('❌ Status inesperado: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao buscar usuário: $e');
      rethrow;
    }
  }

  /// Busca os convites pendentes do usuário logado
  Future<List<Map<String, dynamic>>> getPendingInvites() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final url = Uri.parse('$_baseUrl/invites/pending');

    print('\n📋 === BUSCANDO CONVITES PENDENTES ===');
    print('URL: $url');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception('Erro ao buscar convites (${response.statusCode}).');
    }
  }

  /// Busca os convites de uma reserva
  Future<List<BookingInvite>> getInvites(String bookingId) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$bookingId/invites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .cast<Map<String, dynamic>>()
          .map(BookingInvite.fromJson)
          .toList();
    } else {
      return [];
    }
  }
}

