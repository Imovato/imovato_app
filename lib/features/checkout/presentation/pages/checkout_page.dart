import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import 'package:provider/provider.dart';
import '../../../search/domain/property.dart';
import '../../../auth/presentation/controllers/login_controller.dart';
import '../../domain/reservation.dart';
import '../../application/booking_service.dart';

class CheckoutPage extends StatefulWidget {
  final Property property;
  const CheckoutPage({super.key, required this.property});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookingService = BookingService();

  // cartão
  final _cardCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController(); // MM/AA
  final _cvvCtrl = TextEditingController();

  // método de pagamento
  String _metodo = 'card'; // 'card' | 'pix'

  // meses de aluguel
  int _rentalMonths = 1;

  bool _loading = false;

  bool get _isColiving =>
      widget.property.accommodationType.toLowerCase().contains('coliving');

  @override
  void dispose() {
    _cardCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarPagamento() async {
    final loginCtrl = context.read<LoginController>();

    if (!loginCtrl.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para pagar')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      print('\n🏠 === INICIANDO PROCESSO DE RESERVA ===');

      // Obter o ID do usuário do LoginController
      final userId = loginCtrl.userId;
      final userEmail = loginCtrl.userEmail ?? '';

      if (userId == null || userId.isEmpty) {
        throw Exception('ID do usuário não encontrado. Faça login novamente.');
      }

      final totalPrice = widget.property.price * _rentalMonths;

      print('📧 User Email: $userEmail');
      print('🆔 User ID: $userId');
      print('🏡 Property ID: ${widget.property.id}');
      print('📅 Rental Months: $_rentalMonths');

      // Criar reserva no backend
      final bookingData = await _bookingService.createBooking(
        accommodationId: widget.property.id,
        guestIds: [userId],
        rentalMonths: _rentalMonths,
      );

      print('\n✅ Resposta recebida do backend!');
      print('📦 Booking Data: $bookingData');

      if (!mounted) return;

      if (bookingData != null) {
        final bookingId = bookingData['id']?.toString() ??
            bookingData['bookingId']?.toString() ??
            'RES-${DateTime.now().millisecondsSinceEpoch}';

        // Calcular o valor que o dono paga
        final ownerPrice = totalPrice;

        // Criar reserva local com dados do backend
        final reservation = Reservation(
          id: bookingId,
          propertyId: widget.property.id,
          propertyTitle: widget.property.title,
          propertyAddress:
              '${widget.property.address}, ${widget.property.city} - ${widget.property.state}',
          totalPrice: ownerPrice,
          createdAt: DateTime.now(),
          checkInDate: DateTime.now().add(const Duration(days: 7)),
          checkOutDate:
              DateTime.now().add(Duration(days: 7 + (_rentalMonths * 30))),
          status: ReservationStatus.awaitingPayment,
          paymentMethod: _metodo,
          isColiving: _isColiving,
          maxOccupancy: widget.property.maxOccupancy,
          pixCode: _metodo == 'pix'
              ? '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540${ownerPrice.toStringAsFixed(2)}5802BR5925IMOVATO PAGAMENTOS LTDA6009SAO PAULO62070503***6304ABCD'
              : null,
          paymentDeadline: _metodo == 'pix'
              ? DateTime.now().add(const Duration(hours: 24))
              : null,
        );

        // Navegar para tela de status
        Navigator.pushReplacementNamed(
          context,
          Routes.reservationStatus,
          arguments: reservation,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erro ao criar reserva');
      }
    } catch (e) {
      print('\n❌ ERRO ao confirmar pagamento: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar reserva: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = widget.property;
    final rentalMonths = _rentalMonths;
    final totalPrice = p.price * rentalMonths;

    return Consumer<LoginController>(
      builder: (context, loginCtrl, _) {
        return Scaffold(
          appBar: ImovatoAppBar(
            title: 'Finalizar reserva',
            showBack: true,
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3))
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total ($rentalMonths ${rentalMonths == 1 ? 'mês' : 'meses'})'),
                        Text(formatBRL0(totalPrice),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: (loginCtrl.isLoggedIn && !_loading)
                          ? _confirmarPagamento
                          : null,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46)),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Reservar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // Resumo do imóvel
                      Card(
                        elevation: 0,
                        color: scheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: (p.imagesUrls.isNotEmpty)
                                    ? Image.network(p.imagesUrls.first,
                                        width: 78,
                                        height: 78,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 78,
                                        height: 78,
                                        color: scheme.surfaceContainerHighest),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title,
                                        style: text.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: scheme.onSurface),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('${p.neighborhood}, ${p.city}',
                                        style: text.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant)),
                                    const SizedBox(height: 8),
                                    Text('${formatBRL0(p.price)} / mês',
                                        style: text.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: scheme.primary)),
                                    if (_isColiving) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.people_alt_outlined,
                                              size: 14, color: scheme.primary),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Coliving — convide participantes após reservar',
                                              style: text.bodySmall?.copyWith(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Overlay de login
                  if (!loginCtrl.isLoggedIn)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Para reservar você precisa estar logado',
                                    style: text.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed('/login'),
                                      style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(46)),
                                      child: const Text('Fazer login'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
