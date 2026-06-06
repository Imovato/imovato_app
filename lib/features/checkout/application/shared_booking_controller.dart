import 'package:flutter/foundation.dart';
import '../domain/booking_invite.dart';
import 'invite_service.dart';

/// Estado/resultado de uma tentativa de adicionar convidado
enum AddGuestResult { success, userNotFound, limitReached, alreadyAdded, selfInvite, error }

/// Controlador que gerencia a lista de convidados ANTES de criar a reserva.
///
/// Ele valida e-mails, resolve o ID do usuário no backend e mantém
/// a lista de [BookingInvite] com status [InviteStatus.pending].
///
/// Após a reserva ser criada, chame [sendAllInvites] passando o bookingId
/// para enviar os convites via API.
class SharedBookingController extends ChangeNotifier {
  final InviteService _inviteService;

  final List<BookingInvite> _guests = [];
  bool _isLoading = false;
  String? _error;

  /// Máximo de convidados (ocupacaoMaxima - 1 dono)
  int maxGuests;

  /// E-mail do usuário dono da reserva (para bloquear auto-convite)
  String? ownerEmail;

  int? _participantsOverride;

  SharedBookingController({
    required this.maxGuests,
    this.ownerEmail,
    InviteService? inviteService,
  }) : _inviteService = inviteService ?? InviteService();

  void setOwnerEmail(String? email) {
    ownerEmail = email?.toLowerCase();
  }

  List<BookingInvite> get guests => List.unmodifiable(_guests);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalParticipants {
    final override = _participantsOverride;
    if (override != null && override > 0) return override;
    return _guests.length + 1; // + owner
  }

  void setParticipantsOverride(int? participants) {
    if (_participantsOverride == participants) return;
    _participantsOverride = participants;
    notifyListeners();
  }

  void clearParticipantsOverride() {
    _participantsOverride = null;
    notifyListeners();
  }

  /// Calcula a parte de cada participante.
  ///
  /// A diferença de centavos fica para o dono (tratada no backend).
  double perPersonAmount(double totalPrice) {
    if (totalParticipants <= 0) return totalPrice;
    if (totalParticipants == 1) return totalPrice;
    // Truncar para 2 casas – diferença fica com o dono
    final base = (totalPrice / totalParticipants * 100).truncate() / 100.0;
    return base;
  }

  /// Quanto o dono paga (total - soma dos convidados arredondados)
  double ownerAmount(double totalPrice) {
    if (totalParticipants <= 0) return totalPrice;
    if (totalParticipants == 1) return totalPrice;
    final guestPart = perPersonAmount(totalPrice) * (totalParticipants - 1);
    return double.parse((totalPrice - guestPart).toStringAsFixed(2));
  }

  /// Adiciona um convidado por e-mail.
  ///
  /// Valida se o usuário existe no backend antes de adicioná-lo.
  Future<AddGuestResult> addGuestByEmail(String email) async {
    final trimmed = email.trim().toLowerCase();
    _error = null;

    // Bloqueia o dono de se convidar
    if (ownerEmail != null && trimmed == ownerEmail!.toLowerCase()) {
      _error = 'Você não pode convidar a si mesmo.';
      notifyListeners();
      return AddGuestResult.selfInvite;
    }

    if (_guests.length >= maxGuests) {
      _error = 'Limite de convidados atingido ($maxGuests).';
      notifyListeners();
      return AddGuestResult.limitReached;
    }

    if (_guests.any((g) => g.guestEmail.toLowerCase() == trimmed)) {
      _error = 'Este e-mail já foi adicionado.';
      notifyListeners();
      return AddGuestResult.alreadyAdded;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _inviteService.findUserByEmail(trimmed);

      if (userData == null) {
        _error = 'Nenhum usuário encontrado com este e-mail.';
        _isLoading = false;
        notifyListeners();
        return AddGuestResult.userNotFound;
      }

      final guestId = userData['id']?.toString() ??
          userData['_id']?.toString() ??
          userData['userId']?.toString();

      final guestName = userData['name']?.toString() ??
          userData['userName']?.toString() ??
          userData['fullName']?.toString();

      final invite = BookingInvite(
        guestEmail: trimmed,
        guestId: guestId,
        guestName: guestName,
        status: InviteStatus.pending,
        sentAt: DateTime.now(),
      );

      _guests.add(invite);
      _clearParticipantsOverrideForLocalChange();
      _isLoading = false;
      notifyListeners();
      return AddGuestResult.success;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('sessão expirou') || msg.contains('login novamente') || msg.contains('Sessão expirada')) {
        _error = 'Sua sessão expirou. Faça logout e login novamente.';
      } else {
        _error = 'Erro ao validar usuário: ${msg.replaceAll('Exception: ', '')}';
      }
      _isLoading = false;
      notifyListeners();
      return AddGuestResult.error;
    }
  }

  void _clearParticipantsOverrideForLocalChange() {
    if (_participantsOverride == null) return;
    _participantsOverride = null;
  }

  /// Remove um convidado da lista pelo e-mail
  void removeGuest(String email) {
    _guests.removeWhere((g) => g.guestEmail.toLowerCase() == email.toLowerCase());
    _clearParticipantsOverrideForLocalChange();
    _error = null;
    notifyListeners();
  }

  void clearGuests() {
    _guests.clear();
    _clearParticipantsOverrideForLocalChange();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Envia todos os convites pendentes para a API após a reserva ser criada.
  ///
  /// [bookingId] – ID da reserva recém-criada.
  Future<void> sendAllInvites(String bookingId) async {
    for (int i = 0; i < _guests.length; i++) {
      final guest = _guests[i];
      if (guest.guestId == null) continue;
      try {
        await _inviteService.sendInvite(
          bookingId: bookingId,
          guestId: guest.guestId!,
        );
        _guests[i] = guest.copyWith(status: InviteStatus.pending);
        print('✅ Convite enviado para ${guest.guestEmail}');
      } catch (e) {
        print('❌ Erro ao enviar convite para ${guest.guestEmail}: $e');
      }
    }
    notifyListeners();
  }

  /// Envia o convite para um único convidado pelo e-mail.
  ///
  /// Usado quando o convite é enviado logo após adicionar o convidado
  /// (reserva já criada).
  Future<void> sendInviteForGuest({
    required String bookingId,
    required String guestEmail,
  }) async {
    final idx = _guests.indexWhere(
        (g) => g.guestEmail.toLowerCase() == guestEmail.toLowerCase());
    if (idx == -1) return;

    final guest = _guests[idx];
    if (guest.guestId == null) {
      print('⚠️ guestId nulo para ${guest.guestEmail}, convite não enviado.');
      return;
    }

    try {
      await _inviteService.sendInvite(
        bookingId: bookingId,
        guestId: guest.guestId!,
      );
      _guests[idx] = guest.copyWith(status: InviteStatus.pending);
      print('✅ Convite enviado para ${guest.guestEmail}');
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao enviar convite para ${guest.guestEmail}: $e');
      rethrow;
    }
  }

  Future<void> loadInvites(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final invites = await _inviteService.getInvites(bookingId);
      _guests
        ..clear()
        ..addAll(invites);
    } catch (e) {
      _error = 'Nao foi possivel carregar convidados.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

