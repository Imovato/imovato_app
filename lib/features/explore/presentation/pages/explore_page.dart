import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/Space.dart';

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
        priceMax: result.priceMax ??
            controller
                .valorSelecionado, // Se não definiu no modal, usa da tela principal
        accommodationType: result.accommodationType ??
            tipoMoradiaFromMain, // Se não definiu no modal, usa da tela principal
        maxOccupancy: result.maxOccupancy,
        allowsPets: result.allowsPets,
        allowsChildren: result.allowsChildren,
        isSharedHosting: result.isSharedHosting,
      );

      debugPrint('===== FILTROS MESCLADOS (após modal) =====');
      debugPrint('city: ${controller.filters.city}');
      debugPrint('state: ${controller.filters.state}');
      debugPrint('priceMin: ${result.priceMin}');
      debugPrint(
          'priceMax: ${result.priceMax ?? controller.valorSelecionado} (modal ou tela principal)');
      debugPrint(
          'accommodationType: ${result.accommodationType ?? tipoMoradiaFromMain} (modal ou tela principal)');
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
    final textTheme = Theme.of(context).textTheme;
    final isLoggedIn = context.read<LoginController>().isLoggedIn;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: ExploreSearchAppBar(
        showBack: isLoggedIn ? false : null,
        onTapLocation: () => _openLocalizacaoModal(context),
        onTapFilter: () => _openFiltroModal(context),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.md),
          children: [
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(Space.md),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withAlpha(18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Busca inteligente',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu lar pronto, do seu jeito!',
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descubra o apartamento perfeito, escolha por quanto tempo quer chamar de lar e alugue online com a Imovato.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Space.md),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: Space.sm, horizontal: Space.sm),
                child: Column(
                  children: [
                    Consumer<ExploreController>(
                      builder: (context, c, _) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Space.xs,
                          vertical: Space.xxs,
                        ),
                        leading: Container(
                          width: Space.xl,
                          height: Space.xl,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.home_outlined,
                            color: scheme.primary,
                          ),
                        ),
                        title: Text(
                          'Tipo de moradia',
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Text(
                          c.tipoMoradiaLabel,
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing:
                            Icon(Icons.chevron_right, color: scheme.primary),
                        onTap: () => _openTipoMoradiaModal(context),
                      ),
                    ),
                    const Divider(height: 1),
                    Consumer<ExploreController>(
                      builder: (context, c, _) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Space.sm,
                          vertical: Space.xxs,
                        ),
                        leading: Container(
                          width: Space.xxl,
                          height: Space.xxl,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(Space.sm),
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: scheme.primary,
                          ),
                        ),
                        title: Text(
                          'Valor total',
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Text(
                          formatBRL0(c.valorSelecionado),
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing:
                            Icon(Icons.chevron_right, color: scheme.primary),
                        onTap: () => _openValorTotalModal(context),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    FilledButton.icon(
                      onPressed: () async {
                        final controller = context.read<ExploreController>();

                        final cidadePartes = controller.cidade.split(',');
                        final cidade = cidadePartes.isNotEmpty
                            ? cidadePartes[0].trim()
                            : '';
                        final state = cidadePartes.length > 1
                            ? cidadePartes[1].trim()
                            : '';

                        String? accommodationType;
                        if (controller.tipoMoradia == 'Apartamento Inteiro') {
                          accommodationType = 'APARTMENT';
                        } else if (controller.tipoMoradia == 'Compartilhado') {
                          accommodationType = 'HOUSE';
                        }

                        controller.updateFilter(
                          city: cidade.isNotEmpty ? cidade : null,
                          state: state.isNotEmpty ? state : null,
                          priceMax: controller.valorSelecionado,
                          accommodationType: accommodationType,
                          priceMin: controller.filters.priceMin,
                          maxOccupancy: controller.filters.maxOccupancy,
                          allowsPets: controller.filters.allowsPets,
                          allowsChildren: controller.filters.allowsChildren,
                          isSharedHosting: controller.filters.isSharedHosting,
                        );

                        debugPrint('===== BUSCAR COM FILTROS MESCLADOS =====');
                        debugPrint('city: $cidade');
                        debugPrint('state: $state');
                        debugPrint(
                            'priceMax (tela principal): ${controller.valorSelecionado}');
                        debugPrint(
                            'accommodationType (tela principal): $accommodationType');
                        debugPrint(
                            'Filtros avançados preservados: ${controller.filters}');
                        debugPrint('=======================================');

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        await controller.searchAccommodations();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, Routes.buscar);
                        }
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
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
