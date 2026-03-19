/// Representa o status de um convite de reserva compartilhada
enum InviteStatus {
  pending,   // Aguardando resposta
  accepted,  // Aceito
  declined,  // Recusado
  expired,   // Expirado (3 dias sem resposta)
}

/// Representa um convidado para a reserva compartilhada
class BookingInvite {
  final String? inviteId;
  final String guestEmail;
  final String? guestId;
  final String? guestName;
  final InviteStatus status;
  final DateTime? sentAt;
  final double? amountDue; // Valor que esse convidado deve pagar

  const BookingInvite({
    this.inviteId,
    required this.guestEmail,
    this.guestId,
    this.guestName,
    this.status = InviteStatus.pending,
    this.sentAt,
    this.amountDue,
  });

  BookingInvite copyWith({
    String? inviteId,
    String? guestEmail,
    String? guestId,
    String? guestName,
    InviteStatus? status,
    DateTime? sentAt,
    double? amountDue,
  }) {
    return BookingInvite(
      inviteId: inviteId ?? this.inviteId,
      guestEmail: guestEmail ?? this.guestEmail,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      amountDue: amountDue ?? this.amountDue,
    );
  }

  String get statusLabel {
    switch (status) {
      case InviteStatus.pending:
        return 'Aguardando';
      case InviteStatus.accepted:
        return 'Aceito';
      case InviteStatus.declined:
        return 'Recusado';
      case InviteStatus.expired:
        return 'Expirado';
    }
  }

  factory BookingInvite.fromJson(Map<String, dynamic> json) {
    InviteStatus parseStatus(String? s) {
      switch (s?.toUpperCase()) {
        case 'ACCEPTED':
          return InviteStatus.accepted;
        case 'DECLINED':
        case 'REJECTED':
          return InviteStatus.declined;
        case 'EXPIRED':
          return InviteStatus.expired;
        default:
          return InviteStatus.pending;
      }
    }

    return BookingInvite(
      inviteId: json['inviteId']?.toString() ?? json['id']?.toString(),
      guestEmail: json['guestEmail']?.toString() ?? json['email']?.toString() ?? '',
      guestId: json['guestId']?.toString(),
      guestName: json['guestName']?.toString() ?? json['name']?.toString(),
      status: parseStatus(json['status']?.toString()),
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt'].toString()) : null,
      amountDue: (json['amountDue'] as num?)?.toDouble(),
    );
  }
}

