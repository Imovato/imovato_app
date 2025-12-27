import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import 'package:provider/provider.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../search/domain/property.dart';
import '../../../auth/presentation/controllers/login_controller.dart';

class CheckoutPage extends StatefulWidget {
  final Property property;
  const CheckoutPage({super.key, required this.property});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // cartão
  final _cardCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController(); // MM/AA
  final _cvvCtrl = TextEditingController();

  // método de pagamento
  String _metodo = 'card'; // 'card' | 'pix'

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
      // TODO: integrar com backend (criar reserva + pagamento)
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva confirmada!')),
      );
      Navigator.pop(context); // volta aos detalhes (ou mude para uma tela de sucesso)
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                        const Text('Total'),
                        Text('${formatBRL0(p.price)} / mês', style: const TextStyle(fontWeight: FontWeight.w800)),
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
                          : const Text('Pagar'),
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
