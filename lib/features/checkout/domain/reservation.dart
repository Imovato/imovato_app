enum ReservationStatus {
  awaitingPayment,
  paymentConfirmed,
  awaitingOthersPayment, // coliving: eu paguei, aguardando outros
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
  final bool isColiving;
  final int maxOccupancy;

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
    this.isColiving = false,
    this.maxOccupancy = 1,
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
    bool? isColiving,
    int? maxOccupancy,
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
      isColiving: isColiving ?? this.isColiving,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
    );
  }

  String get statusLabel {
    switch (status) {
      case ReservationStatus.awaitingPayment:
        return 'Aguardando Pagamento';
      case ReservationStatus.paymentConfirmed:
        return 'Pagamento Confirmado';
      case ReservationStatus.awaitingOthersPayment:
        return 'Aguardando outros pagamentos';
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
      case ReservationStatus.awaitingOthersPayment:
        // Na timeline coliving: awaitingPayment(0), paymentConfirmed(1), awaitingOthersPayment(2), reserved(3)
        return 2;
      case ReservationStatus.reserved:
        // Coliving: posição 3 / individual: posição 2
        // O _buildTimeline não inclui awaitingOthersPayment para não-coliving,
        // então para individual reserved fica na posição 2 e para coliving na 3.
        // Usamos isColiving para diferenciar, mas currentStep não tem acesso.
        // Para o cálculo correto, reserved = 3 (coliving usa) ou 2 (individual).
        // Como a lógica da timeline usa índice da lista, e para individual
        // reserved é o índice 2 e para coliving é o índice 3,
        // retornamos um valor alto o suficiente (3) — para individual o step
        // só tem 3 itens (0,1,2), então 3 > 2 marca todos como completed. ✓
        return isColiving ? 3 : 2;
      case ReservationStatus.checkedIn:
        return isColiving ? 4 : 3;
      case ReservationStatus.completed:
        return isColiving ? 5 : 4;
      case ReservationStatus.cancelled:
        return -1;
    }
  }
}

