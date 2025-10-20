import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../../shared/widgets/chat_fab.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
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

    _descCtrl = TextEditingController(text: widget.property.descricao ?? '');
    _minPeriodo = widget.property.minPeriodoMeses;
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
      floatingActionButton: ChatFab(onPressed: () {/* abrir chat */}),
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
                  itemCount: p.fotos.length,
                  itemBuilder: (_, i) => Image.network(
                    p.fotos[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 10, left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(p.fotos.length, (i) {
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
            child: Text(p.titulo, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(p.detalhes, style: text.bodyMedium?.copyWith(color: Colors.black54)),
          ),
          const SizedBox(height: 8),

          // Preços
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aluguel ${formatBRL0(p.aluguel)}',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
            child: Text('Total ${formatBRL0(p.total)} / mês',
                style: text.bodyMedium?.copyWith(color: Colors.black54)),
          ),

          const Divider(height: 1),

          // Especificações principais (ícones + texto)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                _SpecTile(icon: Icons.apartment, title: 'Apartamento', subtitle: 'Inteiro'),
                _SpecTile(icon: Icons.square_foot, title: '60m²'),
                _SpecTile(icon: Icons.bed_outlined, title: '1 quarto'),
                _SpecTile(icon: Icons.chair_outlined, title: 'Mobiliado'),
                _SpecTile(icon: Icons.smoking_rooms, title: 'Fumar', subtitle: 'Não permitido', subtitleColor: Colors.pink.shade400),
                _SpecTile(icon: Icons.local_parking_outlined, title: 'Garagem', subtitle: '1 vaga disponível'),
                _SpecTile(icon: Icons.pets_outlined, title: 'Pets', subtitle: 'Não são permitidos', subtitleColor: Colors.pink.shade400),
                _SpecTile(icon: Icons.grid_on, title: 'Tela de proteção', subtitle: 'Não instalada', subtitleColor: Colors.pink.shade400),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Itens do apartamento
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Itens do apartamento',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface)),
          ),
          _RoomItems(title: 'Quarto A', items: const ['Armário', 'Cama', 'Sofá']),
          _RoomItems(title: 'Cozinha', items: const ['Geladeira', 'Microondas', 'Armário']),
          _RoomItems(title: 'Banheiro 1', items: const ['Chuveiro', 'Armário', 'Espelho']),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () {/* ver todos */},
              icon: const Icon(Icons.open_in_new),
              label: const Text('Todos os itens'),
            ),
          ),

          // Comodidades no condomínio
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text('Comodidades no condomínio',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _AmenityRow(label: 'Elevador Social'),
                _AmenityRow(label: 'Lavanderia no Prédio'),
                _AmenityRow(label: 'Lavanderia pay per use'),
                _AmenityRow(label: 'Locker'),
                _AmenityRow(label: 'Loja de Conveniência 24h'),
                _AmenityRow(label: 'Portaria 24h'),
              ],
            ),
          ),
          const SizedBox(height: 12), // espaço pro bottom bar
          // --- Descrição (texto livre com limite) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Descrição',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _descCtrl,
              maxLength: _descLimit,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Escreva aqui uma descrição do imóvel (máx. 300 caracteres)',
                border: OutlineInputBorder(),
                counterText: '', // remove contador padrão (deixa só o limite)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_descCtrl.text.length}/$_descLimit',
                style: text.bodySmall?.copyWith(color: Colors.black54),
              ),
            ),
          ),

// --- Período mínimo de locação ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Período De Locação',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _minPeriodo,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [1, 2, 3, 6, 12]
                        .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m == 1 ? '1 mês' : '$m meses'),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _minPeriodo = v ?? 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: text.titleMedium),
      subtitle: subtitle == null ? null : Text(
        subtitle!,
        style: text.bodySmall?.copyWith(color: subtitleColor ?? Colors.black54),
      ),
    );
  }
}

class _RoomItems extends StatelessWidget {
  final String title;
  final List<String> items;
  const _RoomItems({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.checkroom_outlined, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: text.bodyMedium?.copyWith(color: Colors.black87),
                children: [
                  TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: items.join(', ')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityRow extends StatelessWidget {
  final String label;
  const _AmenityRow({required this.label});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_box, color: scheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Property property;
  const _BottomBar({required this.property});

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
            Row(
              children: [
                const Text('Total'),
                const Spacer(),
                Text(
                  '${formatBRL0(property.total)} / mês',
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
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.checkout,           // rota do checkout
                        arguments: property,       // passa o imóvel
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Reservar'),
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

