import 'package:flutter/material.dart';

import '../../../../app/utils/br_currency.dart';
import '../../application/explore_controller.dart';
import '../widgets/filtro_busca_sheet.dart';
import '../widgets/localizacao_sheet.dart';
import '../widgets/tipo_moradia_sheet.dart';
import '../widgets/valor_total_sheet.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Future<void> _openValorTotalModal(BuildContext context) async {
    final controller = context.read<ExploreController>();
    final selected = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ValorTotalSheet(initialValue: controller.valorSelecionado),
    );
    if (selected != null && context.mounted) {
      controller.setValor(selected);
    }
  }

  Future<void> _openTipoMoradiaModal(BuildContext context) async {
    final controller = context.read<ExploreController>();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TipoMoradiaSheet(initialValue: controller.tipoMoradia),
    );

    if (selected != null && context.mounted) {
      controller.setTipoMoradia(selected);
    }
  }

  Future<void> _openFiltroModal(BuildContext context) async {
    final result = await showModalBottomSheet<FiltroBuscaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltroBuscaSheet(),
    );

    if (result != null && context.mounted) {
      debugPrint(
        'FILTROS -> quartos=${result.numQuartos} | tipo=${result.tipoImovel} | pet=${result.petFriendly} | '
            'fumantes=${result.fumantes} | compartilhando=${result.pessoasCompartilhando}',
      );
    }
  }

  Future<void> _openLocalizacaoModal(BuildContext context) async {
    final c = context.read<ExploreController>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalizacaoSheet(initialValue: c.cidade),
    );
    if (selected != null && context.mounted) {
      c.setCidade(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: const BackButton(),
        actions: const [SizedBox(width: 40)],
        title: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.apartment,
                color: Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buscar apartamentos',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Consumer<ExploreController>(
                      builder: (context, c, _) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openLocalizacaoModal(context),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            c.cidade,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openFiltroModal(context),
                icon: const Icon(
                  Icons.tune,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: scheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text(
              'Aluguel flexível,\ncom tudo pronto para morar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Encontre o apartamento perfeito, escolha quanto tempo quer morar e faça a locação online',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    Consumer<ExploreController>(
                      builder: (context, c, _) => ListTile(
                        leading: Icon(
                          Icons.home_outlined,
                          color: scheme.primary,
                        ),
                        title: const Text(
                          'TIPO DE MORADIA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          c.tipoMoradiaLabel,
                          style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openTipoMoradiaModal(context),
                      ),
                    ),
                    const Divider(height: 1),
                    Consumer<ExploreController>(
                      builder: (context, c, _) => ListTile(
                        leading: Icon(
                          Icons.attach_money,
                          color: scheme.primary,
                        ),
                        title: const Text(
                          'VALOR TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          formatBRL0(c.valorSelecionado),
                          style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openValorTotalModal(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        /* TODO: chamar repositório / buscar */
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.inversePrimary,
        onPressed: () {},
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Color(0xFFD10B58),
        ),
      ),
    );
  }
}
