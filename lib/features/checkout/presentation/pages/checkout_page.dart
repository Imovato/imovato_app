import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import 'package:provider/provider.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
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

  @override
  void dispose() {
    _cardCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLocalizacaoModal(BuildContext context) async {
    final c = context.read<ExploreController>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalizacaoSheet(initialValue: c.cidade),
    );
    if (selected != null && mounted) c.setCidade(selected);
  }

  Future<void> _openFiltroModal(BuildContext context) async {
    await showModalBottomSheet<FiltroBuscaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltroBuscaSheet(),
    );
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

      print('📧 User Email: $userEmail');
      print('🆔 User ID: $userId');
      print('🏡 Property ID: ${widget.property.id}');
      print('📅 Rental Months: $_rentalMonths');
      print('\n📡 === CHAMANDO ENDPOINT ===');
      print('Endpoint: POST /bookings');
      print('Dados que serão enviados:');
      print('  accommodationId: ${widget.property.id}');
      print('  guestIds: [$userId]');
      print('  rentalMonths: $_rentalMonths');
      print('==============================\n');

      // Criar reserva no backend
      final bookingData = await _bookingService.createBooking(
        accommodationId: widget.property.id,
        guestIds: [userId], // Usando o ID real do MongoDB
        rentalMonths: _rentalMonths,
      );

      print('\n✅ Resposta recebida do backend!');
      print('📦 Booking Data: $bookingData');

      if (!mounted) return;

      if (bookingData != null) {
        print('✅ Booking criado com sucesso! Criando objeto Reservation...');

        // Criar reserva local com dados do backend
        final reservation = Reservation(
          id: bookingData['id']?.toString() ?? 'RES-${DateTime.now().millisecondsSinceEpoch}',
          propertyId: widget.property.id,
          propertyTitle: widget.property.title,
          propertyAddress: '${widget.property.address}, ${widget.property.city} - ${widget.property.state}',
          totalPrice: widget.property.price * _rentalMonths,
          createdAt: DateTime.now(),
          checkInDate: DateTime.now().add(const Duration(days: 7)),
          checkOutDate: DateTime.now().add(Duration(days: 7 + (_rentalMonths * 30))),
          status: ReservationStatus.awaitingPayment,
          paymentMethod: _metodo,
          pixCode: _metodo == 'pix'
              ? '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540${(widget.property.price * _rentalMonths).toStringAsFixed(2)}5802BR5925IMOVATO PAGAMENTOS LTDA6009SAO PAULO62070503***6304ABCD'
              : null,
          paymentDeadline: _metodo == 'pix'
              ? DateTime.now().add(const Duration(hours: 24))
              : null,
        );

        print('🎉 Navegando para tela de status...');

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
        print('❌ bookingData é null!');
        throw Exception('Erro ao criar reserva');
      }
    } catch (e) {
      print('\n❌ ERRO ao confirmar pagamento: $e');
      print('Stack trace: ${StackTrace.current}');

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
    final rentalMonths = _rentalMonths; // Local variable for access in widgets
    final totalPrice = p.price * rentalMonths;

    return Scaffold(
      appBar: ExploreSearchAppBar(
        onTapLocation: () => _openLocalizacaoModal(context),
        onTapFilter: () => _openFiltroModal(context),
        showBack: true,
      ),
      floatingActionButton: ChatFab(onPressed: () {/* chat */}),
      body: Consumer<LoginController>(
        builder: (context, loginCtrl, _) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                    children: [
                      // Resumo
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (p.imagesUrls.isNotEmpty)
                                    ? Image.network(p.imagesUrls.first, width: 72, height: 72, fit: BoxFit.cover)
                                    : Container(width: 72, height: 72, color: scheme.surfaceContainerHighest),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('${p.neighborhood}, ${p.city}', style: text.bodySmall?.copyWith(color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    Text('${formatBRL0(p.price)} / mês', style: const TextStyle(fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),

                  // Modal de login sobreposto
                  if (!loginCtrl.isLoggedIn)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: scheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Para pagar você precisa estar logado',
                                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed('/login');
                                          },
                                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                                          child: const Text('Fazer login'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),

      // Barra fixa com total e botão
      bottomNavigationBar: Consumer<LoginController>(
        builder: (context, loginCtrl, _) {
          final isEnabled = loginCtrl.isLoggedIn;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, -3))],
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
                        Text('Total ($rentalMonths ${rentalMonths == 1 ? 'mês' : 'meses'})'),
                        Text(formatBRL0(totalPrice), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: (isEnabled && !_loading) ? _confirmarPagamento : null,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Reservar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
