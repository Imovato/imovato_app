import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../widgets/property_card.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  int _filtrosAtivos = 0;

  int _countFiltrosAtivos(FiltroBuscaResult f) {
    var c = 0;
    if (f.numQuartos != null) c++;
    if (f.tipoImovel != null) c++;
    if (f.petFriendly != null) c++;
    if (f.fumantes != 'Tanto faz') c++;
    if (f.pessoasCompartilhando.isNotEmpty) c++;
    return c;
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
      appBar: ExploreSearchAppBar(
          onTapLocation: () => _openLocalizacaoModal(context),
          onTapFilter: () => _openFiltroModal(context)),

      body: Consumer<ExploreController>(
        builder: (context, c, _) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error != null) {
            return Center(child: Text('Erro: ${c.error}'));
          }

          final items = c.results;

          if (items.isEmpty) {
            return const Center(child: Text('Nenhum imóvel encontrado'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return InkWell(
                onTap: () => Navigator.pushNamed(context, Routes.propertyDetails, arguments: item),
                child: PropertyCard(
                  data: item,
                  onToggleFavorite: (fav) {
                    // delegate to controller
                    context.read<ExploreController>().toggleFavoriteById(item.id, fav);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: ChatFab(
        onPressed: () {
          // TODO: abrir chat/atendimento
        },
      ),
    );
  }
}
