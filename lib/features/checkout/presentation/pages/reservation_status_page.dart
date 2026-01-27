import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../app/utils/br_currency.dart';
import '../../domain/reservation.dart';

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
  bool _showPixDetails = false;

  void _copyPixCode() {
    if (widget.reservation.pixCode != null) {
      Clipboard.setData(ClipboardData(text: widget.reservation.pixCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reservation = widget.reservation;

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
                    'Acompanhe seu pedido',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTimeline(scheme, textTheme),
                ],
              ),
            ),

            // Informações de Pagamento
            if (reservation.status == ReservationStatus.awaitingPayment &&
                reservation.paymentMethod == 'pix') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 48,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pagamento via PIX',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (reservation.paymentDeadline != null)
                            Text(
                              'Pague até ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.paymentDeadline!)}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onPrimaryContainer.withOpacity(0.8),
                              ),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showPixDetails = !_showPixDetails;
                              });
                            },
                            icon: Icon(_showPixDetails
                                ? Icons.visibility_off
                                : Icons.visibility),
                            label: Text(
                                _showPixDetails ? 'Ocultar código' : 'Ver código PIX'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                          if (_showPixDetails && reservation.pixCode != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    reservation.pixCode!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _copyPixCode,
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copiar código'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: scheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],

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

            // Botões de ação
            if (reservation.status == ReservationStatus.awaitingPayment)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verificando pagamento...'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Já fiz o pagamento'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
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
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reserva cancelada'),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sim, cancelar',
                                  style: TextStyle(color: scheme.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancelar Reserva'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ColorScheme scheme, TextTheme textTheme) {
    final steps = [
      _TimelineStep(
        title: 'Aguardando Pagamento',
        description: 'Confirme o pagamento para prosseguir',
        icon: Icons.payment,
        status: ReservationStatus.awaitingPayment,
      ),
      _TimelineStep(
        title: 'Pagamento Confirmado',
        description: 'Seu pagamento foi aprovado',
        icon: Icons.check_circle,
        status: ReservationStatus.paymentConfirmed,
      ),
      _TimelineStep(
        title: 'Reserva Confirmada',
        description: 'Sua vaga está garantida',
        icon: Icons.home,
        status: ReservationStatus.reserved,
      ),
      _TimelineStep(
        title: 'Check-in',
        description: 'Realize o check-in no imóvel',
        icon: Icons.key,
        status: ReservationStatus.checkedIn,
      ),
      _TimelineStep(
        title: 'Concluído',
        description: 'Estadia finalizada',
        icon: Icons.done_all,
        status: ReservationStatus.completed,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final currentStep = widget.reservation.currentStep;
        final stepIndex = step.status.index;

        final isCompleted = currentStep >= stepIndex;
        final isCurrent = currentStep == stepIndex;
        final isCancelled = widget.reservation.status == ReservationStatus.cancelled;

        return _buildTimelineItem(
          scheme: scheme,
          textTheme: textTheme,
          step: step,
          isCompleted: isCompleted && !isCancelled,
          isCurrent: isCurrent && !isCancelled,
          isLast: isLast,
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
                if (isCurrent && widget.reservation.paymentDeadline != null)
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
                            'Expira em ${_getTimeRemaining(widget.reservation.paymentDeadline!)}',
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

