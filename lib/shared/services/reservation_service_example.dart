import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/auth_storage_service.dart';

/// Exemplo de serviço de reservas que usa o token de autenticação
class ReservationService {
  final AuthStorageService _authStorage = AuthStorageService();
  final String baseUrl = 'https://cadastral-imovato-35ca7e6548df.herokuapp.com';

  /// Cria uma nova reserva
  /// Retorna o ID da reserva criada ou null em caso de erro
  Future<String?> createReservation({
    required String propertyId,
    required int months,
    required DateTime startDate,
  }) async {
    try {
      // Obter o token
      final token = await _authStorage.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      // Fazer a requisição
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ajuste conforme seu backend
        },
        body: jsonEncode({
          'propertyId': propertyId,
          'months': months,
          'startDate': startDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] ?? data['reservationId'];
      } else if (response.statusCode == 401) {
        // Token expirado
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao criar reserva');
      }
    } catch (e) {
      print('Erro ao criar reserva: $e');
      return null;
    }
  }

  /// Busca as reservas do usuário
  Future<List<Map<String, dynamic>>> getMyReservations() async {
    try {
      final token = await _authStorage.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reservations/my'),
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
        throw Exception('Erro ao buscar reservas');
      }
    } catch (e) {
      print('Erro ao buscar reservas: $e');
      return [];
    }
  }

  /// Cancela uma reserva
  Future<bool> cancelReservation(String reservationId) async {
    try {
      final token = await _authStorage.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/reservations/$reservationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erro ao cancelar reserva: $e');
      return false;
    }
  }

  /// Atualiza uma reserva
  Future<bool> updateReservation(
    String reservationId, {
    int? months,
    DateTime? newStartDate,
  }) async {
    try {
      final token = await _authStorage.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final body = <String, dynamic>{};
      if (months != null) body['months'] = months;
      if (newStartDate != null) body['startDate'] = newStartDate.toIso8601String();

      final response = await http.put(
        Uri.parse('$baseUrl/reservations/$reservationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar reserva: $e');
      return false;
    }
  }
}

