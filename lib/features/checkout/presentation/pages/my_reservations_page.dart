import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/router.dart';
import '../../domain/reservation.dart';
import '../../application/reservations_controller.dart';
import '../../../auth/presentation/controllers/login_controller.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedOnce) return;

    final loginController = context.read<LoginController>();
    final userId = loginController.userId;
    if (loginController.isLoggedIn && userId != null && userId.isNotEmpty) {
      context.read<ReservationsController>().loadReservationsByUserId(userId);
      _loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loginController = context.watch<LoginController>();

    // Se não estiver logado, mostra tela pedindo login
    if (!loginController.isLoggedIn) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('Minhas Reservas'),
          centerTitle: true,
          backgroundColor: scheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: 80,
                  color: scheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Faça login para ver suas reservas',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Você precisa estar logado para acessar suas reservas.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.loginMorador);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Fazer Login'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: Consumer<ReservationsController>(
        builder: (context, controller, _) {
          final reservations = controller.reservations;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (reservations.isEmpty) {
            return _buildEmptyState(scheme, textTheme);
          }

          return _buildReservationsList(reservations, scheme, textTheme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: scheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma reserva ainda',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Suas reservas aparecerão aqui assim que você realizar uma',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.alugar,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar Imóveis'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(
    List<Reservation> reservations,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _buildReservationCard(reservation, scheme, textTheme);
      },
    );
  }

  Widget _buildReservationCard(
    Reservation reservation,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.reservationStatus,
            arguments: reservation,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reservation.propertyTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(reservation.status, scheme, textTheme),
                ],
              ),
              const SizedBox(height: 8),
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
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(reservation.checkInDate)} - ${DateFormat('dd/MM/yyyy').format(reservation.checkOutDate)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'R\$ ${reservation.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    ReservationStatus status,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ReservationStatus.awaitingPayment:
        backgroundColor = scheme.errorContainer;
        textColor = scheme.onErrorContainer;
        icon = Icons.payment;
        break;
      case ReservationStatus.paymentConfirmed:
        backgroundColor = scheme.primaryContainer;
        textColor = scheme.onPrimaryContainer;
        icon = Icons.check_circle;
        break;
      case ReservationStatus.reserved:
        backgroundColor = scheme.primaryContainer;
        textColor = scheme.onPrimaryContainer;
        icon = Icons.home;
        break;
      case ReservationStatus.checkedIn:
        backgroundColor = scheme.secondaryContainer;
        textColor = scheme.onSecondaryContainer;
        icon = Icons.login;
        break;
      case ReservationStatus.cancelled:
        backgroundColor = scheme.surfaceContainerHighest;
        textColor = scheme.onSurface;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = scheme.primaryContainer;
        textColor = scheme.onPrimaryContainer;
        icon = Icons.home;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.awaitingPayment:
        return 'Aguardando';
      case ReservationStatus.paymentConfirmed:
        return 'Confirmado';
      case ReservationStatus.reserved:
        return 'Reservado';
      case ReservationStatus.checkedIn:
        return 'Alugado';
      case ReservationStatus.cancelled:
        return 'Cancelado';
      default:
        return 'Reservado';
    }
  }
}

