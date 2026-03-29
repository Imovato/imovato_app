import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../application/explore_controller.dart';
import '../widgets/filtro_busca_sheet.dart';
import '../widgets/localizacao_sheet.dart';
import '../widgets/tipo_moradia_sheet.dart';
import '../widgets/valor_total_sheet.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/login_controller.dart';

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
    final controller = context.read<ExploreController>();
    final result = await showModalBottomSheet<FiltroBuscaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltroBuscaSheet(
        initial: _filtroBuscaResultFromSearchFilters(controller.filters),
      ),
    );

    if (result != null && context.mounted) {
      // Converter tipo de moradia da tela principal para accommodationType
      String? tipoMoradiaFromMain;
      if (controller.tipoMoradia == 'Apartamento Inteiro') {
        tipoMoradiaFromMain = 'APARTMENT';
      } else if (controller.tipoMoradia == 'Compartilhado') {
        tipoMoradiaFromMain = 'HOUSE';
      }

      // ✅ MERGE: Preserva localização e valor da tela principal, mas dá prioridade aos filtros avançados
      controller.updateFilter(
        // Mantém localização da tela principal (se já foi definida)
        city: controller.filters.city,
        state: controller.filters.state,
        // Filtros avançados têm prioridade sobre os da tela principal
        priceMin: result.priceMin,
        priceMax: result.priceMax ?? controller.valorSelecionado, // Se não definiu no modal, usa da tela principal
        accommodationType: result.accommodationType ?? tipoMoradiaFromMain, // Se não definiu no modal, usa da tela principal
        maxOccupancy: result.maxOccupancy,
        allowsPets: result.allowsPets,
        allowsChildren: result.allowsChildren,
        isSharedHosting: result.isSharedHosting,
      );

      debugPrint('===== FILTROS MESCLADOS (após modal) =====');
      debugPrint('city: ${controller.filters.city}');
      debugPrint('state: ${controller.filters.state}');
      debugPrint('priceMin: ${result.priceMin}');
      debugPrint('priceMax: ${result.priceMax ?? controller.valorSelecionado} (modal ou tela principal)');
      debugPrint('accommodationType: ${result.accommodationType ?? tipoMoradiaFromMain} (modal ou tela principal)');
      debugPrint('maxOccupancy: ${result.maxOccupancy}');
      debugPrint('allowsPets: ${result.allowsPets}');
      debugPrint('allowsChildren: ${result.allowsChildren}');
      debugPrint('isSharedHosting: ${result.isSharedHosting}');
      debugPrint('==========================================');
    }
  }

  /// Converte SearchFilters em FiltroBuscaResult para manter o estado anterior
  FiltroBuscaResult _filtroBuscaResultFromSearchFilters(SearchFilters filters) {
    return FiltroBuscaResult(
      priceMin: filters.priceMin,
      priceMax: filters.priceMax,
      accommodationType: filters.accommodationType,
      maxOccupancy: filters.maxOccupancy,
      allowsPets: filters.allowsPets,
      allowsChildren: filters.allowsChildren,
      isSharedHosting: filters.isSharedHosting,
    );
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
    // Se o usuário está logado, não mostra botão voltar. Caso contrário, comportamento automático
    final isLoggedIn = context.read<LoginController>().isLoggedIn;

    return Scaffold(
      appBar: ExploreSearchAppBar(
          showBack: isLoggedIn ? false : null,
          onTapLocation: () => _openLocalizacaoModal(context),
          onTapFilter: () => _openFiltroModal(context)),
      body: Container(
        color: scheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text(
              'Seu lar pronto, do seu jeito!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Descubra o apartamento perfeito, escolha por quanto tempo quer chamar de lar e alugue online com a Imovato.',
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
                      onPressed: () async {
                        final controller = context.read<ExploreController>();

                        // Extrair cidade e estado da string no formato "Cidade, UF"
                        final cidadePartes = controller.cidade.split(',');
                        final cidade = cidadePartes.isNotEmpty ? cidadePartes[0].trim() : '';
                        final state = cidadePartes.length > 1 ? cidadePartes[1].trim() : '';

                        // Converter tipo de moradia para accommodationType
                        String? accommodationType;
                        if (controller.tipoMoradia == 'Apartamento Inteiro') {
                          accommodationType = 'APARTMENT';
                        } else if (controller.tipoMoradia == 'Compartilhado') {
                          accommodationType = 'HOUSE'; // ou 'COLIVING' dependendo da API
                        }
                        // Se for 'Tanto Faz', deixa null para buscar todos

                        // ✅ MERGE: Combina filtros da tela principal + filtros avançados
                        controller.updateFilter(
                          // Filtros da tela principal
                          city: cidade.isNotEmpty ? cidade : null,
                          state: state.isNotEmpty ? state : null,
                          priceMax: controller.valorSelecionado, // Valor máximo da tela principal
                          accommodationType: accommodationType, // Tipo de moradia
                          // Mantém filtros avançados do modal (se existirem)
                          priceMin: controller.filters.priceMin,
                          // priceMax já foi definido acima, mas se existir no filtro avançado, sobrescreve
                          maxOccupancy: controller.filters.maxOccupancy,
                          allowsPets: controller.filters.allowsPets,
                          allowsChildren: controller.filters.allowsChildren,
                          isSharedHosting: controller.filters.isSharedHosting,
                        );

                        debugPrint('===== BUSCAR COM FILTROS MESCLADOS =====');
                        debugPrint('city: $cidade');
                        debugPrint('state: $state');
                        debugPrint('priceMax (tela principal): ${controller.valorSelecionado}');
                        debugPrint('accommodationType (tela principal): $accommodationType');
                        debugPrint('Filtros avançados preservados: ${controller.filters}');
                        debugPrint('=======================================');

                        // Mostrar loading e fazer busca
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );
                        await controller.searchAccommodations();
                        if (context.mounted) {
                          Navigator.of(context).pop(); // close loading
                          Navigator.pushNamed(context, Routes.buscar);
                        }
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
      floatingActionButton: null,
    );
  }
}
