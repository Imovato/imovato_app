enum ReservationStatus {
  awaitingPayment,
  paymentConfirmed,
  reserved,
  checkedIn,
  completed,
  cancelled,
}

class Reservation {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final ReservationStatus status;
  final String? paymentMethod;
  final String? pixCode;
  final DateTime? paymentDeadline;

  const Reservation({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.totalPrice,
    required this.createdAt,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    this.paymentMethod,
    this.pixCode,
    this.paymentDeadline,
  });

  Reservation copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? propertyAddress,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    ReservationStatus? status,
    String? paymentMethod,
    String? pixCode,
    DateTime? paymentDeadline,
  }) {
    return Reservation(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      pixCode: pixCode ?? this.pixCode,
      paymentDeadline: paymentDeadline ?? this.paymentDeadline,
    );
  }

  String get statusLabel {
    switch (status) {
      case ReservationStatus.awaitingPayment:
        return 'Aguardando Pagamento';
      case ReservationStatus.paymentConfirmed:
        return 'Pagamento Confirmado';
      case ReservationStatus.reserved:
        return 'Reservado';
      case ReservationStatus.checkedIn:
        return 'Check-in Realizado';
      case ReservationStatus.completed:
        return 'Concluído';
      case ReservationStatus.cancelled:
        return 'Cancelado';
    }
  }

  int get currentStep {
    switch (status) {
      case ReservationStatus.awaitingPayment:
        return 0;
      case ReservationStatus.paymentConfirmed:
        return 1;
      case ReservationStatus.reserved:
        return 2;
      case ReservationStatus.checkedIn:
        return 3;
      case ReservationStatus.completed:
        return 4;
      case ReservationStatus.cancelled:
        return -1;
    }
  }
}

