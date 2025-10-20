import 'package:flutter/material.dart';
import '../../../../app/utils/br_currency.dart';
import '../../domain/property.dart';

class PropertyCard extends StatefulWidget {
  final Property data;
  final ValueChanged<bool>? onToggleFavorite;

  const PropertyCard({super.key, required this.data, this.onToggleFavorite});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = widget.data;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fotos
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: data.fotos.length,
                  itemBuilder: (_, i) => Image.network(
                    data.fotos[i],
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

                // Indicadores
                Positioned(
                  bottom: 8, left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(data.fotos.length, (i) {
                      final isActive = i == _page;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 8 : 6,
                        height: isActive ? 8 : 6,
                        decoration: BoxDecoration(
                          color: isActive ? scheme.primary : Colors.white70,
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

          // Texto
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(data.titulo, style: textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              data.detalhes,
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                children: [
                  TextSpan(
                    text: 'Aluguel ${formatBRL0(data.aluguel)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
            child: Text(
              'Total ${formatBRL0(data.total)}',
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
