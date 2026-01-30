import 'package:flutter/material.dart';
import '../domain/reservation.dart';

class ReservationsController extends ChangeNotifier {
  final List<Reservation> _reservations = [];

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  bool get hasReservations => _reservations.isNotEmpty;

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

