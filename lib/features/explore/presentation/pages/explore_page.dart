import 'package:flutter/material.dart';
import 'package:imovato_app/shared/models/location_option.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../application/explore_controller.dart';
import '../widgets/filtro_busca_sheet.dart';
import '../widgets/localizacao_sheet.dart';

/// Página inicial de descoberta. Os filtros e resultados vivem na aba Buscar.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Future<void> _openLocation(BuildContext context) async {
    final controller = context.read<ExploreController>();
    final selected = await showModalBottomSheet<LocationOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalizacaoSheet(
        initialValue: LocalizacaoSheet.defaultCities.firstWhere(
          (e) => e.label == controller.cidade,
        ),
      ),
    );

    if (selected != null && context.mounted) {
      controller.setCidade(selected);
      Navigator.pushReplacementNamed(context, Routes.buscar);
    }
  }

  Future<void> _openFilters(BuildContext context) async {
    final controller = context.read<ExploreController>();
    final result = await showModalBottomSheet<FiltroBuscaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltroBuscaSheet(),
    );

    if (result != null && context.mounted) {
      controller.setFilters(SearchFilters(
        priceMin: result.priceMin,
        priceMax: result.priceMax,
        city: controller.filters.city,
        state: controller.filters.state,
        neighborhood: controller.filters.neighborhood,
        accommodationType: result.accommodationType,
        maxOccupancy: result.maxOccupancy,
        allowsPets: result.allowsPets,
        allowsChildren: result.allowsChildren,
        isSharedHosting: result.isSharedHosting,
      ));
      await controller.searchAccommodations();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, Routes.buscar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ImovatoAppBar(
        title: 'Início',
        showBack: false,
        action: IconButton(
          tooltip: 'Escolher região',
          onPressed: () => _openLocation(context),
          icon: const Icon(Icons.location_on_outlined),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu próximo lar começa aqui.',
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Encontre moradias pensadas para a sua rotina universitária.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSecondary.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      Routes.buscar,
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Explorar imóveis'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Comece por aqui', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _QuickAction(
              icon: Icons.location_on_outlined,
              title: 'Escolha sua região',
              subtitle: 'Veja imóveis perto de onde você estuda',
              onTap: () => _openLocation(context),
            ),
            _QuickAction(
              icon: Icons.tune_outlined,
              title: 'Defina suas preferências',
              subtitle: 'Preço, tipo de moradia e mais filtros',
              onTap: () => _openFilters(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
