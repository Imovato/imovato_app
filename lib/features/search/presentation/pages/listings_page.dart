import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../../domain/property.dart';
import '../widgets/property_card.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  int _filtrosAtivos = 0;

  // mock de imóveis (troque por dados reais quando ligar a API)
  List<Property> _items = const [
    Property(
      id: '1',
      titulo: 'Vila Gumercindo · Rua Assungui',
      detalhes: 'Mobiliado · 24m² · Studio',
      aluguel: 2700, total: 3500,
      fotos: [
        'https://images.unsplash.com/photo-1505691723518-36a5ac3b2d5b?w=1200',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200',
      ],
    ),
    Property(
      id: '2',
      titulo: 'Brooklin · Rua Sansão Alves dos Santos',
      detalhes: 'Mobiliado · 35m² · 1 quarto',
      aluguel: 3200, total: 4100,
      fotos: [
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1200',
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1201',
      ],
      favorito: true,
    ),
  ];

  void _toggleFav(int index, bool fav) {
    setState(() {
      _items = List<Property>.from(_items)
        ..[index] = _items[index].copyWith(favorito: fav);
    });
  }

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ExploreSearchAppBar(
          onTapLocation: () => _openLocalizacaoModal(context),
          onTapFilter: () => _openFiltroModal(context)),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // Ações (Filtrar / Mapa)
          Row(
            children: [
              const SizedBox(width: 12),
            ],
          ),

          const SizedBox(height: 12),

          // Lista de cards
          for (var i = 0; i < _items.length; i++)
            InkWell(
              onTap: () => Navigator.pushNamed(context, Routes.propertyDetails, arguments: _items[i]),
              child: PropertyCard(
                data: _items[i],
                onToggleFavorite: (fav) => _toggleFav(i, fav),
              ),
            ),
        ],
      ),

      floatingActionButton: ChatFab(
        onPressed: () {
          // TODO: abrir chat/atendimento
        },
      ),
    );
  }
}
