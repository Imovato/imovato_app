import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/services/auth_storage_service.dart';

/// Serviço responsável por criar e gerenciar reservas (bookings)
class BookingService {
  final AuthStorageService _authStorage = AuthStorageService();
  final String baseUrl = 'https://transacional-imovato-9daff7c83047.herokuapp.com';

  /// Obtém o token de autenticação salvo
  Future<String?> _getAuthToken() async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      print('❌ Token não encontrado. Usuário precisa fazer login.');
      return null;
    }
    return token;
  }

  /// Cria uma nova reserva no backend
  ///
  /// Retorna o ID da reserva criada ou null em caso de erro
  Future<Map<String, dynamic>?> createBooking({
    required String accommodationId,
    required List<String> guestIds,
    required int rentalMonths,
  }) async {
    try {
      // Obter token de autenticação do storage
      String? token = await _getAuthToken();

      if (token == null) {
        throw Exception('Você precisa estar logado para criar uma reserva.');
      }

      // Validar e decodificar o JWT para verificar timestamps
      try {
        final decodedToken = JwtDecoder.decode(token);
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Epoch em segundos
        final iat = decodedToken['iat'] as int?;
        final exp = decodedToken['exp'] as int?;

        print('\n🕐 === VERIFICAÇÃO DE TIMESTAMPS DO TOKEN ===');
        print('⏰ Horário Atual (epoch): $now');
        print('⏰ Horário Atual (data): ${DateTime.now().toIso8601String()}');
        if (iat != null) {
          final iatDate = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
          print('🔹 Token iat (issued at): $iat');
          print('🔹 Token iat (data): ${iatDate.toIso8601String()}');
          if (iat > now) {
            print('⚠️⚠️⚠️ PROBLEMA: Token foi emitido no FUTURO!');
            print('   Diferença: ${iat - now} segundos à frente');
            print('   ➡️ O servidor vai rejeitar (401) porque o token "ainda não é válido"');
          } else {
            print('✅ Token iat OK (no passado)');
          }
        }
        if (exp != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          print('🔹 Token exp (expires at): $exp');
          print('🔹 Token exp (data): ${expDate.toIso8601String()}');
          if (exp < now) {
            print('❌ PROBLEMA: Token JÁ EXPIROU!');
            print('   Expirou há ${now - exp} segundos');
            throw Exception('Token expirado. Faça login novamente.');
          } else {
            print('✅ Token ainda válido por ${exp - now} segundos');
          }
        }
        print('============================================\n');
      } catch (e) {
        print('⚠️ Erro ao decodificar/validar token: $e');
      }

      print('\n=== 🎯 CRIANDO RESERVA NO ENDPOINT /bookings ===');
      print('🌐 URL COMPLETA: $baseUrl/bookings');
      print('📍 ENDPOINT: POST /bookings');
      print('🔑 Token (primeiros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      print('🏡 accommodationId: $accommodationId');
      print('👥 guestIds: $guestIds');
      print('📅 rentalMonths: $rentalMonths');
      print('\n📤 HEADERS DA REQUISIÇÃO:');
      print('  Content-Type: application/json');
      print('  Authorization: Bearer ${token.substring(0, 20)}...');

      final requestBody = {
        'accommodationId': accommodationId,
        'guestIds': guestIds,
        'rentalMonths': rentalMonths,
      };
      print('\n📦 Request Body: ${jsonEncode(requestBody)}');

      // Gerar comando CURL equivalente para debug
      print('\n🔧 === COMANDO CURL EQUIVALENTE ===');
      print("curl --location '$baseUrl/bookings' \\");
      print("--header 'Content-Type: application/json' \\");
      print("--header 'Authorization: Bearer $token' \\");
      print("--data '${jsonEncode(requestBody)}'");
      print('===============================================\n');

      // Fazer a requisição
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('\n📥 RESPOSTA DA API:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ RESERVA CRIADA COM SUCESSO!');
        print('Response Data: $data');
        return data;
      } else if (response.statusCode == 401) {
        print('❌ ERRO 401: Token inválido ou expirado');
        print('   Verifique se o token está correto e não expirou');
        throw Exception('Sessão expirada. Por favor, faça login novamente.');
      } else if (response.statusCode == 400) {
        print('❌ ERRO 400: Dados inválidos');
        try {
          final error = jsonDecode(response.body);
          print('   Detalhes: $error');
          final errorMsg = error['message'] ?? 'Dados inválidos na requisição';
          throw Exception(errorMsg);
        } catch (_) {
          throw Exception('Dados inválidos na requisição');
        }
      } else if (response.statusCode == 503) {
        print('❌ ERRO 503: Serviço indisponível');
        print('   O servidor está temporariamente fora do ar');
        throw Exception('Serviço temporariamente indisponível. Tente novamente mais tarde.');
      } else {
        print('❌ ERRO ${response.statusCode}');
        // Tentar extrair mensagem de erro
        try {
          final error = jsonDecode(response.body);
          print('Erro detalhado: $error');
          final errorMsg = error['message'] ?? 'Erro ao processar reserva';
          throw Exception(errorMsg);
        } catch (_) {
          throw Exception('Erro ao processar reserva (${response.statusCode})');
        }
      }
    } catch (e) {
      print('❌ EXCEÇÃO ao criar booking: $e');
      rethrow;
    }
  }

  /// Realiza o check-in de uma reserva (endpoint POST /bookings/checkin/{id})
  Future<bool> checkInBooking(String bookingId) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      print('\n🚪 === REALIZANDO CHECK-IN ===');
      print('🌐 URL: $baseUrl/bookings/checkin/$bookingId');
      print('🔑 Token (primeiros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      print('🔧 CURL: curl --location --request POST "$baseUrl/bookings/checkin/$bookingId" --header "Authorization: Bearer $token"');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/checkin/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao realizar check-in (${response.statusCode})');
      }
    } catch (e) {
      print('Erro ao realizar check-in: $e');
      rethrow;
    }
  }

  /// Busca as reservas do usuário pelo ID
  Future<List<Map<String, dynamic>>> getBookingsByUserId(String userId) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao buscar reservas (${response.statusCode})');
      }
    } catch (e) {
      print('Erro ao buscar bookings por usuário: $e');
      rethrow;
    }
  }

  /// Busca as reservas do usuário
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao buscar reservas (${response.statusCode})');
      }
    } catch (e) {
      print('Erro ao buscar bookings: $e');
      return [];
    }
  }

  /// Cancela uma reserva (endpoint PATCH /bookings/{id}/cancel)
  Future<bool> cancelBookingById(String bookingId) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao cancelar reserva (${response.statusCode})');
      }
    } catch (e) {
      print('Erro ao cancelar booking via PATCH: $e');
      rethrow;
    }
  }

  /// Cancela uma reserva
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erro ao cancelar booking: $e');
      return false;
    }
  }

  /// Confirma o pagamento de uma reserva
  ///
  /// [bookingId] - ID da reserva
  /// [userId] - ID do usuário que está pagando
  Future<bool> confirmPayment({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      print('\n💳 === CONFIRMANDO PAGAMENTO ===');
      print('🌐 URL: $baseUrl/bookings/$bookingId/pay/$userId');
      print('🔑 Token (primeiros 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      print('🆔 Booking ID: $bookingId');
      print('👤 User ID: $userId');

      // Gerar comando CURL equivalente para debug
      print('\n🔧 === COMANDO CURL EQUIVALENTE ===');
      print("curl --location --request PATCH '$baseUrl/bookings/$bookingId/pay/$userId' \\");
      print("--header 'Authorization: Bearer $token'");
      print('===============================================\n');

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/pay/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 RESPOSTA DA API:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ PAGAMENTO CONFIRMADO COM SUCESSO!');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ ERRO 401: Token inválido ou expirado');
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 404) {
        print('❌ ERRO 404: Reserva não encontrada');
        throw Exception('Reserva não encontrada');
      } else {
        print('❌ ERRO ${response.statusCode}');
        throw Exception('Erro ao confirmar pagamento (${response.statusCode})');
      }
    } catch (e) {
      print('❌ EXCEÇÃO ao confirmar pagamento: $e');
      rethrow;
    }
  }
}
