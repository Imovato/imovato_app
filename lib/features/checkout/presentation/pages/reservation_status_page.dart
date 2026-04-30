import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../app/utils/br_currency.dart';
import '../../domain/reservation.dart';
import '../../application/reservations_controller.dart';
import '../../application/booking_service.dart';
import '../../application/shared_booking_controller.dart';
import '../../application/invite_service.dart';
import '../../domain/booking_invite.dart';
import '../../../../shared/services/auth_storage_service.dart';

class ReservationStatusPage extends StatefulWidget {
  final Reservation reservation;

  const ReservationStatusPage({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationStatusPage> createState() => _ReservationStatusPageState();
}

class _ReservationStatusPageState extends State<ReservationStatusPage> {
  final BookingService _bookingService = BookingService();
  final AuthStorageService _authStorage = AuthStorageService();
  final InviteService _inviteService = InviteService();
  bool _isProcessingPayment = false;
  bool _isProcessingCheckIn = false;
  bool _paymentDone = false;
  static const bool _forceEnableCheckInForTest = true;
  static const String _wifiPassword = 'WIFI-1234';
  static const String _doorPassword = 'PORTA-5678';

  late final SharedBookingController _sharedBookingCtrl;
  String? _currentUserId;
  String? _currentUserEmail;
  List<Map<String, dynamic>> _pendingInvites = [];
  bool _pendingLoaded = false;
  int? _guestCount;
  bool _guestCountLoaded = false;

  @override
  void initState() {
    super.initState();
    final maxGuests = (widget.reservation.maxOccupancy - 1).clamp(0, 99);
    _sharedBookingCtrl = SharedBookingController(
      maxGuests: maxGuests,
      inviteService: InviteService(),
    );
    _sharedBookingCtrl.addListener(_onSharedBookingChanged);
    // Carrega o email do dono para bloquear auto-convite
    _authStorage.getUserEmail().then((email) {
      _sharedBookingCtrl.setOwnerEmail(email);
      if (!mounted) return;
      setState(() => _currentUserEmail = email?.toLowerCase());
    });
    _authStorage.getUserId().then((id) {
      if (!mounted) return;
      setState(() => _currentUserId = id);
    });
    _loadCurrentUserFromToken();

    if (widget.reservation.isColiving) {
      _sharedBookingCtrl.loadInvites(widget.reservation.id);
    }
    _loadPendingInvites();
    _loadGuestCount();

    // Garante que a reserva está no controller para que as atualizações de
    // status reflitam na tela via context.watch<ReservationsController>()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<ReservationsController>();
      if (controller.getReservationById(widget.reservation.id) == null) {
        controller.addReservation(widget.reservation);
      }
    });
  }

  @override
  void dispose() {
    _sharedBookingCtrl.removeListener(_onSharedBookingChanged);
    _sharedBookingCtrl.dispose();
    super.dispose();
  }

  void _onSharedBookingChanged() {
    if (mounted) setState(() {});
  }

  void _cancelReservation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          'Tem certeza que deseja cancelar esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              try {
                final success = await _bookingService.cancelBookingById(
                  widget.reservation.id,
                );

                if (!mounted) return;

                if (success) {
                  final controller = context.read<ReservationsController>();
                  controller.removeReservation(widget.reservation.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reserva cancelada com sucesso'),
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível cancelar a reserva.'),
                  ),
                );
              }
            },
            child: Text(
              'Sim, cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    if (_isProcessingPayment) return;

    try {
      setState(() => _isProcessingPayment = true);

      final userId = await _authStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('Usuário não identificado. Faça login novamente.');
      }

      print('\n💳 === INICIANDO PROCESSO DE PAGAMENTO ===');
      print('🆔 Booking ID: ${widget.reservation.id}');
      print('👤 User ID: $userId');

      final success = await _bookingService.confirmPayment(
        bookingId: widget.reservation.id,
        userId: userId,
      );

      if (!mounted) return;

      if (success) {
        setState(() => _paymentDone = true);

        final controller = context.read<ReservationsController>();
        final currentInvite = _findCurrentUserInvite();
        final isSharedFlow = widget.reservation.isColiving || currentInvite != null || _guestCount != null;

        // Atualiza status localmente com o valor correto
        final newStatus = isSharedFlow
            ? ReservationStatus.awaitingOthersPayment
            : ReservationStatus.paymentConfirmed;

        controller.updateReservationStatus(widget.reservation.id, newStatus);
        setState(() {});

        if (isSharedFlow) {
          _sharedBookingCtrl.loadInvites(widget.reservation.id);
          _loadGuestCount();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSharedFlow
                  ? 'Seu pagamento foi confirmado! Aguardando os demais participantes.'
                  : 'Pagamento confirmado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Reserva individual: avança para reserved após confirmação
        if (!isSharedFlow) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            controller.updateReservationStatus(
              widget.reservation.id,
              ReservationStatus.reserved,
            );
            setState(() {});
            // Recarrega do backend após avançar o status localmente
            Future.delayed(const Duration(seconds: 3), () {
              if (!mounted) return;
              controller.loadReservationsByUserId(userId);
            });
          });
        } else {
          // Coliving: recarrega após um delay para o backend processar
          Future.delayed(const Duration(seconds: 5), () {
            if (!mounted) return;
            controller.loadReservationsByUserId(userId);
          });
        }
      }
    } catch (e) {
      print('❌ ERRO ao processar pagamento: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar pagamento. Tente novamente.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _showAccessInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Informacoes de acesso'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Senha do Wi-Fi:'),
            SizedBox(height: 4),
            Text(
              _wifiPassword,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('Senha eletronica da porta:'),
            SizedBox(height: 4),
            Text(
              _doorPassword,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _performCheckIn() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Realizar Check-in'),
        content: const Text(
          'Confirmar check-in neste imóvel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              try {
                final success = await _bookingService.checkInBooking(
                  widget.reservation.id,
                );

                if (!mounted) return;

                if (success) {
                  final controller = context.read<ReservationsController>();
                  controller.updateReservationStatus(
                    widget.reservation.id,
                    ReservationStatus.checkedIn,
                  );
                  setState(() {});

                  _showAccessInfo();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Check-in realizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível realizar o check-in.'),
                  ),
                );
              }
            },
            child: Text(
              'Confirmar Check-in',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCheckInAvailable(Reservation reservation) {
    if (_forceEnableCheckInForTest) return true;

    final now = DateTime.now();
    final checkInDate = reservation.checkInDate;

    // Check-in disponível se:
    // 1. A data atual é igual ou posterior à data de check-in
    // 2. A reserva está confirmada (pagamento confirmado ou reservada)
    // 3. Não está cancelada
    final isDateValid = now.year >= checkInDate.year &&
        now.month >= checkInDate.month &&
        now.day >= checkInDate.day;

    final isStatusValid = reservation.status == ReservationStatus.paymentConfirmed ||
        reservation.status == ReservationStatus.reserved;

    return isDateValid && isStatusValid;
  }

  Future<void> _loadPendingInvites() async {
    try {
      final data = await _inviteService.getPendingInvites();
      if (!mounted) return;
      setState(() {
        _pendingInvites = data;
        _pendingLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pendingLoaded = true);
    }
  }

  Future<void> _loadGuestCount() async {
    try {
      final count = await _bookingService.getGuestCount(widget.reservation.id);
      if (!mounted) return;
      final normalized = (count != null && count > 0) ? count : null;
      setState(() {
        _guestCount = normalized;
        _guestCountLoaded = true;
      });
      if (normalized != null) {
        _sharedBookingCtrl.setParticipantsOverride(normalized);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _guestCountLoaded = true);
    }
  }

  Future<void> _loadCurrentUserFromToken() async {
    if (_currentUserId != null && _currentUserEmail != null) return;
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) return;

    Map<String, dynamic> decoded;
    try {
      decoded = JwtDecoder.decode(token);
    } catch (_) {
      return;
    }

    String? tokenEmail;
    final emailRaw = decoded['email'] ?? decoded['userEmail'] ?? decoded['mail'] ?? decoded['username'];
    if (emailRaw is String && emailRaw.contains('@')) {
      tokenEmail = emailRaw;
    }

    String? tokenId;
    final idRaw = decoded['userId'] ?? decoded['id'] ?? decoded['_id'] ?? decoded['sub'];
    if (idRaw != null) {
      tokenId = idRaw.toString();
      if (tokenId.contains('@')) tokenId = null;
    }

    if (!mounted) return;
    setState(() {
      _currentUserEmail ??= tokenEmail?.toLowerCase();
      _currentUserId ??= tokenId;
    });
  }

  String? _normalizeEmail(String? email) {
    if (email == null) return null;
    final trimmed = email.trim().toLowerCase();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _extractBookingId(Map<String, dynamic> invite) {
    final booking = invite['booking'] as Map<String, dynamic>?;
    final bookingValue = invite['booking'];
    if (bookingValue is String) return bookingValue;
    return invite['bookingId']?.toString() ??
        invite['booking_id']?.toString() ??
        invite['reservationId']?.toString() ??
        booking?['id']?.toString() ??
        booking?['bookingId']?.toString();
  }

  String? _extractAccommodationId(Map<String, dynamic> invite) {
    final booking = invite['booking'] as Map<String, dynamic>?;
    return invite['accommodationId']?.toString() ??
        invite['propertyId']?.toString() ??
        booking?['accommodationId']?.toString();
  }

  BookingInvite? _inviteFromPending(Map<String, dynamic> invite) {
    final normalized = Map<String, dynamic>.from(invite);
    if (normalized['status'] == null && normalized['statusInvite'] != null) {
      normalized['status'] = normalized['statusInvite'];
    }
    if (normalized['amountDue'] == null && normalized['shareAmount'] != null) {
      normalized['amountDue'] = normalized['shareAmount'];
    }
    return BookingInvite.fromJson(normalized);
  }

  double? _extractShareAmount(Map<String, dynamic> invite) {
    final raw = invite['shareAmount'] ??
        invite['share_amount'] ??
        invite['amountDue'] ??
        invite['valueDue'] ??
        invite['amount_due'];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.replaceAll(',', '.'));
    return null;
  }

  BookingInvite? _findCurrentUserInvite() {
    final email = _normalizeEmail(_currentUserEmail);
    for (final invite in _sharedBookingCtrl.guests) {
      final inviteEmail = _normalizeEmail(invite.guestEmail);
      final sameId = _currentUserId != null && invite.guestId == _currentUserId;
      final sameEmail = email != null && inviteEmail == email;
      if (sameId || sameEmail) return invite;
    }

    for (final pending in _pendingInvites) {
      final bookingId = _extractBookingId(pending);
      final accommodationId = _extractAccommodationId(pending);
      final matchesBooking = bookingId != null && bookingId == widget.reservation.id;
      final matchesAccommodation = accommodationId != null && accommodationId == widget.reservation.propertyId;
      if (!matchesBooking && !matchesAccommodation) continue;
      final invite = _inviteFromPending(pending);
      if (invite == null) continue;
      final inviteEmail = _normalizeEmail(invite.guestEmail);
      final sameId = _currentUserId != null && invite.guestId == _currentUserId;
      final sameEmail = email != null && inviteEmail == email;
      final noInviteIdentity = invite.guestId == null && inviteEmail == null;
      final noUserIdentity = _currentUserId == null && email == null;
      if (sameId || sameEmail || noInviteIdentity || noUserIdentity) return invite;
      // Endpoint /invites/pending retorna convites do usuario logado.
      return invite;
    }

    return null;
  }

  bool _canGuestPay(Reservation reservation, BookingInvite invite) {
    final statusOk = reservation.status == ReservationStatus.awaitingPayment ||
        reservation.status == ReservationStatus.awaitingOthersPayment;
    final inviteOk = invite.status == InviteStatus.pending || invite.status == InviteStatus.accepted;
    return statusOk && inviteOk;
  }

  double _resolveGuestAmount(Reservation reservation, BookingInvite? currentInvite, double? pendingShare) {
    final inviteAmount = currentInvite?.amountDue;
    if (inviteAmount != null && inviteAmount > 0) return inviteAmount;
    if (pendingShare != null && pendingShare > 0) return pendingShare;
    return _sharedBookingCtrl.perPersonAmount(reservation.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Buscar a reserva atualizada do controller
    final controller = context.watch<ReservationsController>();
    final reservation = controller.getReservationById(widget.reservation.id) ?? widget.reservation;

    final currentInvite = _findCurrentUserInvite();
    final isGuestView = currentInvite != null;
    final pendingMatch = _pendingInvites.firstWhere(
      (invite) {
        final bookingId = _extractBookingId(invite);
        final accommodationId = _extractAccommodationId(invite);
        return (bookingId != null && bookingId == reservation.id) ||
            (accommodationId != null && accommodationId == reservation.propertyId);
      },
      orElse: () => {},
    );
    final pendingShare = pendingMatch.isNotEmpty ? _extractShareAmount(pendingMatch) : null;
    final guestAmount = _resolveGuestAmount(reservation, currentInvite, pendingShare);
    final participantsLabel = _guestCountLoaded && _guestCount != null
        ? '${_guestCount!} pessoas'
        : '${_sharedBookingCtrl.totalParticipants} pessoas';
    final isSharedReservation = reservation.isColiving || pendingMatch.isNotEmpty || _guestCount != null;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Status da Reserva'),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com informações do imóvel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.08)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.propertyTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reservation.propertyAddress,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(reservation.checkInDate),
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: scheme.onSurface.withOpacity(0.4),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Check-out',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(reservation.checkOutDate),
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Timeline
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acompanhe a sua reserva',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTimeline(scheme, textTheme, reservation),
                ],
              ),
            ),


            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valor Total',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatBRL0(reservation.totalPrice),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Seção de convidados coliving ──────────────────────────
            if (reservation.isColiving &&
                reservation.status != ReservationStatus.cancelled)
              ChangeNotifierProvider<SharedBookingController>.value(
                value: _sharedBookingCtrl,
                child: _ColivingInviteSection(
                  reservation: reservation,
                  sharedCtrl: _sharedBookingCtrl,
                  readOnly: isGuestView,
                ),
              ),

            // Pagamento do convidado
            if (isGuestView && reservation.status != ReservationStatus.cancelled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sua parte',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatBRL0(guestAmount),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Convidado',
                        style: textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),

            if (!isGuestView && isSharedReservation)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor por pessoa',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatBRL0(_sharedBookingCtrl.perPersonAmount(reservation.totalPrice)),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'Divisao: $participantsLabel',
                      //   style: textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                      // ),
                      const SizedBox(height: 4),

                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Botões de ação
            if (reservation.status != ReservationStatus.cancelled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Botão Pagar (dono aguardando pagamento ou convidado)
                    if ((reservation.status == ReservationStatus.awaitingPayment) ||
                        (isGuestView && currentInvite != null && _canGuestPay(reservation, currentInvite))) ...[
                      FilledButton(
                        onPressed: (_isProcessingPayment || _paymentDone) ? null : _processPayment,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isProcessingPayment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Pagar'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Botões Check-in e Cancelar (lado a lado)
                    Row(
                      children: [
                        // Botão Check-in
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _isCheckInAvailable(reservation)
                                ? _performCheckIn
                                : null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: _isProcessingCheckIn
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login,
                                        size: 18,
                                        color: _isCheckInAvailable(reservation)
                                            ? scheme.onSecondaryContainer
                                            : scheme.onSurface.withOpacity(0.38),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Check-in'),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botão Cancelar
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isProcessingPayment ? null : _cancelReservation,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                    if (reservation.status == ReservationStatus.checkedIn) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: _showAccessInfo,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Ver informacoes de acesso'),
                      ),
                    ],

                    // Mensagem informativa sobre check-in
                    if (!_isCheckInAvailable(reservation)) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Check-in disponível a partir de ${DateFormat('dd/MM/yyyy').format(reservation.checkInDate)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ColorScheme scheme, TextTheme textTheme, Reservation reservation) {
    final steps = [
      _TimelineStep(
        title: 'Aguardando Pagamento',
        description: 'Confirme o pagamento para prosseguir',
        icon: Icons.payment,
        status: ReservationStatus.awaitingPayment,
      ),
      _TimelineStep(
        title: 'Pagamento Confirmado',
        description: reservation.isColiving
            ? 'Seu pagamento foi aprovado'
            : 'Seu pagamento foi aprovado',
        icon: Icons.check_circle,
        status: ReservationStatus.paymentConfirmed,
      ),
      if (reservation.isColiving)
        _TimelineStep(
          title: 'Aguardando outros pagamentos',
          description: 'Reserva confirmada quando todos pagarem',
          icon: Icons.hourglass_top,
          status: ReservationStatus.awaitingOthersPayment,
        ),
      _TimelineStep(
        title: 'Reserva Confirmada',
        description: 'Sua vaga está garantida',
        icon: Icons.home,
        status: ReservationStatus.reserved,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final currentStep = reservation.currentStep;
        // Usa o índice da lista (posição), não o índice do enum
        final stepIndex = index;

        final isCompleted = currentStep > stepIndex;
        final isCurrent = currentStep == stepIndex;
        final isCancelled = reservation.status == ReservationStatus.cancelled;

        return _buildTimelineItem(
          scheme: scheme,
          textTheme: textTheme,
          step: step,
          isCompleted: isCompleted && !isCancelled,
          isCurrent: isCurrent && !isCancelled,
          isLast: isLast,
          reservation: reservation,
        );
      }),
    );
  }

  Widget _buildTimelineItem({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required _TimelineStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required Reservation reservation,
  }) {
    final iconColor = isCompleted || isCurrent
        ? scheme.primary
        : scheme.onSurface.withOpacity(0.3);
    final lineColor = isCompleted
        ? scheme.primary
        : scheme.onSurface.withOpacity(0.15);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : step.icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: lineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted || isCurrent
                        ? scheme.onSurface
                        : scheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (isCurrent && reservation.paymentDeadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: scheme.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expira em ${_getTimeRemaining(reservation.paymentDeadline!)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) return 'Expirado';
    if (difference.inHours > 24) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
    return '${difference.inMinutes}m';
  }
}

class _TimelineStep {
  final String title;
  final String description;
  final IconData icon;
  final ReservationStatus status;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Painel de convidados coliving
// ─────────────────────────────────────────────────────────────────────────────

class _ColivingInviteSection extends StatefulWidget {
  final Reservation reservation;
  final SharedBookingController sharedCtrl;
  final bool readOnly;

  const _ColivingInviteSection({
    required this.reservation,
    required this.sharedCtrl,
    this.readOnly = false,
  });

  @override
  State<_ColivingInviteSection> createState() => _ColivingInviteSectionState();
}

class _ColivingInviteSectionState extends State<_ColivingInviteSection> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ChangeNotifierProvider<SharedBookingController>.value(
      value: widget.sharedCtrl,
      child: Consumer<SharedBookingController>(
        builder: (context, ctrl, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined, color: scheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Participantes do Coliving',
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.readOnly
                      ? 'Veja quem participa da reserva'
                      : 'Convide até ${ctrl.maxGuests} pessoas para dividir o custo',
                  style: text.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // Lista de convidados já adicionados
                if (ctrl.guests.isNotEmpty) ...[
                  ...ctrl.guests.map((g) => _GuestTile(
                        guest: g,
                        // perPersonAmount: ctrl.perPersonAmount(widget.reservation.totalPrice),
                        onRemove: widget.readOnly ? () {} : () => ctrl.removeGuest(g.guestEmail),
                        scheme: scheme,
                        text: text,
                        readOnly: widget.readOnly,
                      )),
                  const SizedBox(height: 8),

                  // Resumo da divisão (apenas para o dono)
                  // if (!widget.readOnly) ...[
                  //   Container(
                  //     padding: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: scheme.primaryContainer.withOpacity(0.4),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 'Sua parte (${ctrl.totalParticipants} pessoas)',
                  //                 style: text.bodySmall,
                  //                 overflow: TextOverflow.ellipsis,
                  //               ),
                  //               Text(
                  //                 formatBRL0(ctrl.ownerAmount(widget.reservation.totalPrice)),
                  //                 style: text.titleMedium?.copyWith(
                  //                     fontWeight: FontWeight.bold,
                  //                     color: scheme.primary),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         Text(
                  //           'Total:\n${formatBRL0(widget.reservation.totalPrice)}',
                  //           textAlign: TextAlign.right,
                  //           style: text.bodySmall?.copyWith(
                  //             color: Colors.black45,
                  //             decoration: TextDecoration.lineThrough,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   const SizedBox(height: 12),
                  // ],
                ],

                // Erro
                if (ctrl.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(ctrl.error!,
                              style: text.bodySmall?.copyWith(color: Colors.red.shade700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Campo de e-mail + botão (apenas dono)
                if (!widget.readOnly && ctrl.guests.length < ctrl.maxGuests)
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'E-mail do convidado',
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                              if (!v.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: ctrl.isLoading ? null : () => _addGuest(ctrl),
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              padding: EdgeInsets.zero),
                          child: ctrl.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.person_add_alt_1_outlined),
                        ),
                      ],
                    ),
                  )
                else if (!widget.readOnly)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 16, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text('Limite de convidados atingido',
                            style: text.bodySmall),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addGuest(SharedBookingController ctrl) async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();

    // Passo 1: valida o e-mail e adiciona o convidado à lista
    final result = await ctrl.addGuestByEmail(email);

    if (!mounted) return;

    if (result != AddGuestResult.success) {
      // Trata erros de validação
      switch (result) {
        case AddGuestResult.selfInvite:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Você não pode convidar a si mesmo.'),
          backgroundColor: Colors.orange,
        ));
        break;
      case AddGuestResult.userNotFound:
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Usuário não encontrado nesta plataforma.'),
            backgroundColor: Colors.red,
          ));
          break;
        case AddGuestResult.alreadyAdded:
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Este e-mail já foi adicionado.'),
            backgroundColor: Colors.orange,
          ));
          break;
        case AddGuestResult.error:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ctrl.error ?? 'Erro ao validar usuário.'),
            backgroundColor: Colors.red,
          ));
          break;
        default:
          break;
      }
      return;
    }

    // Passo 2: envia o convite via endpoint POST /bookings/{id}/invites
    _emailCtrl.clear();
    try {
      await ctrl.sendInviteForGuest(
        bookingId: widget.reservation.id,
        guestEmail: email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Convite enviado para $email'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Usuário adicionado, mas falha ao enviar convite: ${e.toString().replaceAll('Exception: ', '')}',
        ),
        backgroundColor: Colors.orange,
      ));
    }
  }
}

class _GuestTile extends StatelessWidget {
  final dynamic guest;
  // final double perPersonAmount;
  final VoidCallback onRemove;
  final ColorScheme scheme;
  final TextTheme text;
  final bool readOnly;

  const _GuestTile({
    required this.guest,
    // required this.perPersonAmount,
    required this.onRemove,
    required this.scheme,
    required this.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              (guest.guestName ?? guest.guestEmail)[0].toUpperCase(),
              style: TextStyle(
                  color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.guestName ?? guest.guestEmail,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Text(
                //   // formatBRL0(perPersonAmount),
                //   // style: text.bodySmall?.copyWith(color: scheme.primary),
                // ),
              ],
            ),
          ),
          if (!readOnly)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              color: Colors.black45,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}








