import 'package:flutter/material.dart';
import '../domain/reservation.dart';
import 'booking_service.dart';

class ReservationsController extends ChangeNotifier {
  final List<Reservation> _reservations = [];
  final BookingService _bookingService = BookingService();

  bool _loading = false;
  String? _errorMessage;

  List<Reservation> get reservations => List.unmodifiable(_reservations);
  bool get hasReservations => _reservations.isNotEmpty;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReservationsByUserId(String userId) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _bookingService.getBookingsByUserId(userId);
      final mapped = data.map(_mapBookingToReservation).toList();
      final merged = mapped.map((incoming) {
        final existing = _reservations.firstWhere(
          (r) => r.id == incoming.id,
          orElse: () => incoming,
        );
        if (existing.id == incoming.id) {
          final mergedStatus = _maxStatus(existing.status, incoming.status);
          return incoming.copyWith(
            status: mergedStatus,
            paymentMethod: incoming.paymentMethod ?? existing.paymentMethod,
            pixCode: incoming.pixCode ?? existing.pixCode,
            paymentDeadline: incoming.paymentDeadline ?? existing.paymentDeadline,
            isColiving: incoming.isColiving || existing.isColiving,
            maxOccupancy: incoming.maxOccupancy != 1
                ? incoming.maxOccupancy
                : existing.maxOccupancy,
          );
        }
        return incoming;
      }).toList();
      _reservations
        ..clear()
        ..addAll(merged);
    } catch (e) {
      _errorMessage = 'Não foi possível carregar suas reservas.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Reservation _mapBookingToReservation(Map<String, dynamic> booking) {
    final accommodation = booking['accommodationDetails'] as Map<String, dynamic>?;
    final initialDate = booking['initialDate']?.toString();
    final endDate = booking['endDate']?.toString();

    final checkInDate = initialDate != null
        ? DateTime.tryParse(initialDate) ?? DateTime.now()
        : DateTime.now();
    final checkOutDate = endDate != null
        ? DateTime.tryParse(endDate) ?? checkInDate
        : checkInDate;

    final totalPrice = _resolveTotalPrice(booking, accommodation);

    return Reservation(
      id: _resolveBookingId(booking),
      propertyId: booking['accommodationId']?.toString() ?? accommodation?['id']?.toString() ?? '',
      propertyTitle: accommodation?['title']?.toString() ?? 'Imóvel',
      propertyAddress: _formatAddress(accommodation),
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      status: _mapStatus(_resolveStatus(booking)),
      paymentMethod: null,
      pixCode: null,
      paymentDeadline: null,
      isColiving: accommodation?['accommodationType']?.toString().toLowerCase().contains('coliving') ?? false,
      maxOccupancy: (accommodation?['maxOccupancy'] as num?)?.toInt() ?? 1,
    );
  }

  double _resolveTotalPrice(Map<String, dynamic> booking, Map<String, dynamic>? accommodation) {
    final candidates = [
      booking['totalAmount'],
      booking['totalPrice'],
      booking['amount'],
      booking['price'],
      booking['value'],
      booking['totalValue'],
      booking['valorTotal'],
      booking['total'],
    ];

    for (final raw in candidates) {
      if (raw is num) return raw.toDouble();
      if (raw is String) {
        final parsed = double.tryParse(raw.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    }

    return (accommodation?['price'] as num?)?.toDouble() ?? 0.0;
  }

  String _resolveBookingId(Map<String, dynamic> booking) {
    final id = booking['bookingId'] ?? booking['id'] ?? booking['bookingID'];
    return id?.toString() ?? 'RES-${DateTime.now().millisecondsSinceEpoch}';
  }

  String? _resolveStatus(Map<String, dynamic> booking) {
    return booking['statusReservation']?.toString() ??
        booking['status']?.toString() ??
        booking['reservationStatus']?.toString();
  }

  String _formatAddress(Map<String, dynamic>? accommodation) {
    if (accommodation == null) return '';
    final address = accommodation['address']?.toString();
    final streetNumber = accommodation['streetNumber']?.toString();
    final city = accommodation['city']?.toString();
    final state = accommodation['state']?.toString();
    final parts = [
      if (address != null && address.isNotEmpty) address,
      if (streetNumber != null && streetNumber.isNotEmpty) streetNumber,
      if (city != null && city.isNotEmpty) city,
      if (state != null && state.isNotEmpty) state,
    ];
    return parts.join(', ');
  }

  ReservationStatus _mapStatus(String? status) {
    switch (status) {
      case 'WAITING_PAYMENT':
        return ReservationStatus.awaitingPayment;
      case 'PAYMENT_CONFIRMED':
        return ReservationStatus.paymentConfirmed;
      case 'AWAITING_OTHERS_PAYMENT':
        return ReservationStatus.awaitingOthersPayment;
      case 'CONFIRMED':
      case 'RESERVED':
        return ReservationStatus.reserved;
      case 'RENTED':
      case 'CHECKED_IN':
        return ReservationStatus.checkedIn;
      case 'COMPLETED':
        return ReservationStatus.completed;
      case 'CANCELLED':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.awaitingPayment;
    }
  }

  ReservationStatus _maxStatus(ReservationStatus a, ReservationStatus b) {
    return _statusRank(a) >= _statusRank(b) ? a : b;
  }

  int _statusRank(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.awaitingPayment:
        return 0;
      case ReservationStatus.paymentConfirmed:
        return 1;
      case ReservationStatus.awaitingOthersPayment:
        return 2;
      case ReservationStatus.reserved:
        return 3;
      case ReservationStatus.checkedIn:
        return 4;
      case ReservationStatus.completed:
        return 5;
      case ReservationStatus.cancelled:
        return -1;
    }
  }

  void addReservation(Reservation reservation) {
    _reservations.insert(0, reservation);
    notifyListeners();
  }

  void updateReservationStatus(String id, ReservationStatus newStatus) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void removeReservation(String id) {
    _reservations.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Reservation? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Reservation> getActiveReservations() {
    return _reservations
        .where((r) =>
            r.status != ReservationStatus.completed &&
            r.status != ReservationStatus.cancelled)
        .toList();
  }

  List<Reservation> getPastReservations() {
    return _reservations
        .where((r) =>
            r.status == ReservationStatus.completed ||
            r.status == ReservationStatus.cancelled)
        .toList();
  }
}
