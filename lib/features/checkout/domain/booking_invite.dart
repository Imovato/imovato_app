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

    double? parseAmount(dynamic raw) {
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw.replaceAll(',', '.'));
      return null;
    }

    final guestObj = json['guest'] is Map<String, dynamic>
        ? json['guest'] as Map<String, dynamic>
        : null;
    final guestEmail = json['guestEmail']?.toString() ??
        json['email']?.toString() ??
        guestObj?['email']?.toString() ??
        '';
    final guestId = json['guestId']?.toString() ??
        json['guestUserId']?.toString() ??
        json['userId']?.toString() ??
        guestObj?['id']?.toString() ??
        guestObj?['_id']?.toString();
    final guestName = json['guestName']?.toString() ??
        json['name']?.toString() ??
        guestObj?['name']?.toString() ??
        guestObj?['fullName']?.toString();
    final amountRaw = json['amountDue'] ??
        json['valueDue'] ??
        json['shareAmount'] ??
        json['share_amount'] ??
        json['amount_due'] ??
        json['amount'] ??
        json['value'];

    return BookingInvite(
      inviteId: json['inviteId']?.toString() ?? json['id']?.toString(),
      guestEmail: guestEmail,
      guestId: guestId,
      guestName: guestName,
      status: parseStatus(json['status']?.toString()),
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt'].toString()) : null,
      amountDue: parseAmount(amountRaw),
    );
  }
}
