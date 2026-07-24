import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../app/utils/br_currency.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../explore/application/explore_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _descCtrl = TextEditingController(text: widget.property.description ?? '');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = widget.property;

    return Scaffold(
      appBar: ImovatoAppBar(
        title: 'Detalhes do imóvel',
        showBack: true,
        action: Consumer<ExploreController>(
          builder: (context, controller, _) {
            final isFavorite =
                controller.favorites.any((item) => item.id == p.id);
            return IconButton(
              tooltip: isFavorite
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () => controller.toggleFavoriteById(p.id, !isFavorite),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? scheme.primary : scheme.primary,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(property: p),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              color: scheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: SizedBox(
                height: 300,
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
                        loadingBuilder: (c, w, p) => p == null
                            ? w
                            : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, __, ___) => Container(
                          color: scheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.photo, size: 48),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Aluguel ${formatBRL0(p.price)}',
                          style: text.labelLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                            width: active ? 10 : 6,
                            height: active ? 10 : 6,
                            decoration: BoxDecoration(
                              color: active ? scheme.primary : Colors.white70,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius:
                    ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: text.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: scheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${p.neighborhood}, ${p.city} - ${p.state}',
                          style: text.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.people_alt_outlined,
                        label:
                            'Máx. ${p.maxOccupancy} ${p.maxOccupancy == 1 ? 'pessoa' : 'pessoas'}',
                      ),
                      _InfoChip(
                        icon: Icons.bed_outlined,
                        label: '${p.bedrooms} quartos',
                      ),
                      _InfoChip(
                        icon: Icons.bathroom_outlined,
                        label: '${p.bathrooms} banheiros',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                _SpecTile(
                  icon: Icons.location_on,
                  title: 'Endereço',
                  subtitle: '${p.address}, ${p.streetNumber}',
                ),
                _SpecTile(
                  icon: Icons.people_outline,
                  title: 'Ocupação Máxima',
                  subtitle:
                      '${p.maxOccupancy} ${p.maxOccupancy == 1 ? 'pessoa' : 'pessoas'}',
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
                  subtitle: p.accommodationType == 'coliving'
                      ? 'Compartilhado'
                      : 'Moradia Individual',
                ),
                _SpecTile(
                  icon: Icons.pets,
                  title: 'Pet Friendly',
                  subtitle: p.petFriendly ? 'Sim' : 'Não',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descrição',
                    style: text.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (p.description?.trim().isNotEmpty ?? false)
                        ? p.description!.trim()
                        : 'O proprietário não adicionou uma descrição.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SpecTile({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: ImovatoBorderRadius.circular(ImovatoBorderRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius:
                  ImovatoBorderRadius.circular(ImovatoBorderRadius.md),
            ),
            child: Icon(icon, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: text.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
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
  int _meses = 1;

  void _decrementarMeses() {
    if (_meses > 1) setState(() => _meses--);
  }

  void _incrementarMeses() {
    if (_meses < 12) setState(() => _meses++);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
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
                color: scheme.surfaceContainerLow,
                borderRadius:
                    ImovatoBorderRadius.circular(ImovatoBorderRadius.lg),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _meses > 1 ? _decrementarMeses : null,
                    icon: const Icon(Icons.remove),
                    color: scheme.primary,
                    disabledColor: scheme.outline,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$_meses',
                          style: text.headlineSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _meses == 1 ? 'mês' : 'meses',
                          style: text.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _meses < 12 ? _incrementarMeses : null,
                    icon: const Icon(Icons.add),
                    color: scheme.primary,
                    disabledColor: scheme.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Total',
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${formatBRL0(widget.property.price * _meses)} / $_meses ${_meses == 1 ? 'mês' : 'meses'}',
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                final loginController = context.read<LoginController>();

                if (!loginController.isLoggedIn) {
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

                Navigator.pushNamed(
                  context,
                  Routes.checkout,
                  arguments: widget.property,
                );
              },
              icon: const Icon(Icons.calendar_month_outlined),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      ImovatoBorderRadius.circular(ImovatoBorderRadius.lg),
                ),
              ),
              label: const Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}
