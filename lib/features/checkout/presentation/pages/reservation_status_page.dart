import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../app/utils/br_currency.dart';
import '../../domain/reservation.dart';
import '../../application/reservations_controller.dart';

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
            onPressed: () {
              // Remove a reserva do controller
              final controller = context.read<ReservationsController>();
              controller.removeReservation(widget.reservation.id);

              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back from reservation status page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reserva cancelada com sucesso'),
                ),
              );
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

  void _processPayment() {
    // TODO: Implementar integração com gateway de pagamento
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentOptionsSheet(
        reservation: widget.reservation,
        onPaymentSelected: (method) {
          Navigator.pop(context);
          _handlePaymentMethod(method);
        },
      ),
    );
  }

  void _handlePaymentMethod(String method) {
    // TODO: Implementar lógica específica para cada método de pagamento
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Processando Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processando pagamento via $method...'),
          ],
        ),
      ),
    );

    // Simula processamento
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pagamento em Análise'),
          content: const Text(
            'Seu pagamento está sendo processado. Você receberá uma notificação assim que for confirmado.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Atualiza o status da reserva
                final controller = context.read<ReservationsController>();
                controller.updateReservationStatus(
                  widget.reservation.id,
                  ReservationStatus.paymentConfirmed,
                );
                setState(() {});
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
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
                    // Botão Pagar
                    FilledButton(
                      onPressed: _processPayment,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Pagar'),
                    ),
                    const SizedBox(height: 12),
                    // Botão Cancelar
                    OutlinedButton(
                      onPressed: _cancelReservation,
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

// Widget de opções de pagamento
class _PaymentOptionsSheet extends StatelessWidget {
  final Reservation reservation;
  final Function(String) onPaymentSelected;

  const _PaymentOptionsSheet({
    required this.reservation,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Escolha a forma de pagamento',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Valor total: ${formatBRL0(reservation.totalPrice)}',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Opções de pagamento
              _PaymentOption(
                icon: Icons.pix,
                title: 'PIX',
                subtitle: 'Aprovação imediata',
                onTap: () => onPaymentSelected('PIX'),
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                icon: Icons.credit_card,
                title: 'Cartão de Crédito',
                subtitle: 'Parcelamento disponível',
                onTap: () => onPaymentSelected('Cartão de Crédito'),
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                icon: Icons.account_balance,
                title: 'Boleto Bancário',
                subtitle: 'Vencimento em 3 dias úteis',
                onTap: () => onPaymentSelected('Boleto'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de opção de pagamento individual
class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: scheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
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

