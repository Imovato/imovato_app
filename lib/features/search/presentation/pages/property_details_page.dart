import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../../../checkout/domain/reservation.dart';
import '../../../checkout/application/reservations_controller.dart';
import '../../../checkout/application/booking_service.dart';
import '../../../auth/presentation/controllers/login_controller.dart';
import '../../domain/property.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  late final PageController _pageCtrl;
  late final TextEditingController _descCtrl;
  int _page = 0;
  static const int _descLimit = 300;
  int _minPeriodo = 1;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    _descCtrl = TextEditingController(text: widget.property.description ?? '');
    _minPeriodo = 1;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _descCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = widget.property;

    return Scaffold(
      appBar: ExploreSearchAppBar(
        onTapLocation: () => _openLocalizacaoModal(context),
        onTapFilter: () => _openFiltroModal(context),
        showBack: true,
      ),
      floatingActionButton: ChatFab(onPressed: () {
        /* abrir chat */
      }),
      bottomNavigationBar: _BottomBar(property: p),
      body: ListView(
        children: [
          // Galeria de fotos
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: p.imagesUrls.length,
                  itemBuilder: (_, i) => Image.network(
                    p.imagesUrls[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(p.imagesUrls.length, (i) {
                      final active = i == _page;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 8 : 6,
                        height: active ? 8 : 6,
                        decoration: BoxDecoration(
                          color: active ? scheme.primary : Colors.white70,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Título + detalhes
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(p.title,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${p.neighborhood}, ${p.city} - ${p.state}',
                style: text.bodyMedium?.copyWith(color: Colors.black54)),
          ),
          const SizedBox(height: 8),

          // Preços
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aluguel ${formatBRL0(p.price)}',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
            child: Text('Máximo ${p.maxOccupancy} ${p.maxOccupancy == 1 ? 'pessoa' : 'pessoas'}',
                style: text.bodyMedium?.copyWith(color: Colors.black54)),
          ),

          const Divider(height: 1),

          // Endereço completo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                _SpecTile(
                  icon: Icons.location_on,
                  title: 'Endereço',
                  subtitle: '${p.address}, ${p.streetNumber}',
                ),
                _SpecTile(
                  icon: Icons.people_outline,
                  title: 'Ocupância Máxima',
                  subtitle: '${p.maxOccupancy} ${p.maxOccupancy == 1 ? 'pessoa' : 'pessoas'}',
                ),
                _SpecTile(
                  icon: Icons.bed_outlined,
                  title: 'Quartos',
                  subtitle: '${p.bedrooms}',
                ),
                _SpecTile(
                  icon: Icons.bathroom_outlined,
                  title: 'Banheiros',
                  subtitle: '${p.bathrooms}',
                ),
                _SpecTile(
                  icon: Icons.home_work_outlined,
                  title: 'Tipo de Moradia',
                  subtitle: p.accommodationType == 'coliving' ? 'Coliving' : 'Moradia Individual',
                ),
                _SpecTile(
                  icon: Icons.pets,
                  title: 'Pet Friendly',
                  subtitle: p.petFriendly ? 'Sim' : 'Não',
                ),
              ],
            ),
          ),

          // Descrição
          if ((p.description?.trim().isNotEmpty ?? false)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Descrição',
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              child: Text(
                p.description!.trim(),
                style: text.bodyMedium
                    ?.copyWith(color: Colors.black87, height: 1.4),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
              child: Text(
                'O proprietário não adicionou uma descrição.',
                style: text.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;

  const _SpecTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: text.titleMedium),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: text.bodySmall
                  ?.copyWith(color: subtitleColor ?? Colors.black54),
            ),
    );
  }
}



class _BottomBar extends StatefulWidget {
  final Property property;

  const _BottomBar({required this.property});

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  final _bookingService = BookingService();
  int _meses = 1;
  bool _loading = false;

  void _decrementarMeses() {
    if (_meses > 1) {
      setState(() => _meses--);
    }
  }

  void _incrementarMeses() {
    if (_meses < 12) {
      setState(() => _meses++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _meses > 1 ? _decrementarMeses : null,
                    icon: const Icon(Icons.remove),
                    color: scheme.primary,
                    disabledColor: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$_meses',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _meses == 1 ? 'mês' : 'meses',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _meses < 12 ? _incrementarMeses : null,
                    icon: const Icon(Icons.add),
                    color: scheme.primary,
                    disabledColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Total'),
                const Spacer(),
                Text(
                  '${formatBRL0(widget.property.price * _meses)} / $_meses ${_meses == 1 ? 'mês' : 'meses'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : () async {
                      // Verificar se o usuário está logado
                      final loginController = context.read<LoginController>();

                      if (!loginController.isLoggedIn) {
                        // Se não estiver logado, mostrar diálogo e redirecionar para login
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Login Necessário'),
                            content: const Text(
                              'Você precisa fazer login para reservar um imóvel.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.pushNamed(context, Routes.loginMorador);
                                },
                                child: const Text('Fazer Login'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Iniciar loading
                      setState(() => _loading = true);

                      try {
                        print('\n🏠 === CRIANDO RESERVA NA API ===');

                        // Obter dados do usuário
                        final userEmail = loginController.userEmail ?? '';
                        final userId = loginController.userId ?? userEmail; // Usar ID real ou fallback para email

                        print('📧 User Email: $userEmail');
                        print('🆔 User ID: $userId');
                        print('🏡 Property ID: ${widget.property.id}');
                        print('📅 Rental Months: $_meses');

                        // Validar que temos IDs reais
                        if (userId.isEmpty) {
                          throw Exception('ID do usuário não encontrado. Faça login novamente.');
                        }
                        if (widget.property.id.isEmpty) {
                          throw Exception('ID do imóvel inválido.');
                        }

                        // Chamar API para criar reserva
                        final bookingData = await _bookingService.createBooking(
                          accommodationId: widget.property.id,
                          guestIds: [userId],
                          rentalMonths: _meses,
                        );

                        print('✅ Resposta recebida da API!');
                        print('📦 Booking Data: $bookingData');

                        if (!mounted) return;

                        if (bookingData != null) {
                          // Criar objeto de reserva local com dados do backend
                          final reservation = Reservation(
                            id: bookingData['id']?.toString() ?? 'RES-${DateTime.now().millisecondsSinceEpoch}',
                            propertyId: widget.property.id,
                            propertyTitle: widget.property.title,
                            propertyAddress: '${widget.property.address}, ${widget.property.city} - ${widget.property.state}',
                            totalPrice: widget.property.price * _meses,
                            createdAt: DateTime.now(),
                            checkInDate: DateTime.now().add(const Duration(days: 7)),
                            checkOutDate: DateTime.now().add(Duration(days: 7 + (_meses * 30))),
                            status: ReservationStatus.awaitingPayment,
                            paymentMethod: 'pix',
                            pixCode: '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540${(widget.property.price * _meses).toStringAsFixed(2)}5802BR5925IMOVATO PAGAMENTOS LTDA6009SAO PAULO62070503***6304ABCD',
                            paymentDeadline: DateTime.now().add(const Duration(hours: 24)),
                          );

                          // Adicionar ao controller local
                          context.read<ReservationsController>().addReservation(reservation);

                          print('🎉 Reserva criada com sucesso no backend!');
                          print('📍 Navegando para Minhas Reservas...');

                          // Redirecionar para Minhas Reservas
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.myReservations,
                          );

                          // Mostrar snackbar de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Reserva criada com sucesso no banco de dados!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          throw Exception('API retornou null');
                        }
                      } catch (e) {
                        print('\n❌ ERRO ao criar reserva: $e');

                        if (!mounted) return;

                        // Mostrar erro genérico ao usuário (não mostrar detalhes técnicos)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Não foi possível processar a reserva. Tente novamente.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _loading = false);
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Reservar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}