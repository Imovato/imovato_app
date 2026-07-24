import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.imagesUrls.length > 1) {
        precacheImage(
          CachedNetworkImageProvider(
            cloudinaryCardImage(widget.data.imagesUrls[1]),
          ),
          context,
        );
      }
    });
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
      margin: const EdgeInsets.only(bottom: ImovatoSpacing.sm),
      clipBehavior: Clip.antiAlias,
      color: scheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                PageView.builder(
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: data.imagesUrls.length,
                    itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: cloudinaryCardImage(data.imagesUrls[i]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => const ColoredBox(
                            color: Color(0xFFF2F2F2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.photo, size: 48),
                        )),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      formatBRL0(data.price),
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   right: 12,
                //   top: 12,
                //   child: Material(
                //     color: Colors.white,
                //     shape: const CircleBorder(),
                //     child: IconButton(
                //       tooltip: data.favorito
                //           ? 'Remover dos favoritos'
                //           : 'Adicionar aos favoritos',
                //       onPressed: widget.onToggleFavorite == null
                //           ? null
                //           : () => widget.onToggleFavorite!(!data.favorito),
                //       icon: Icon(
                //         data.favorito ? Icons.favorite : Icons.favorite_border,
                //         color:
                //             data.favorito ? scheme.primary : scheme.onSurface,
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(data.imagesUrls.length, (i) {
                      final isActive = i == _page;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 10 : 6,
                        height: isActive ? 10 : 6,
                        decoration: BoxDecoration(
                          color: isActive ? scheme.primary : Colors.white70,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              data.title,
              style: textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18, color: scheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${data.neighborhood}, ${data.city}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.people_alt_outlined,
                  label:
                      'Máx. ${data.maxOccupancy} ${data.maxOccupancy == 1 ? 'pessoa' : 'pessoas'}',
                ),
                _InfoChip(
                  icon: Icons.home_outlined,
                  label: data.neighborhood,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String cloudinaryCardImage(String url) {
  return url.replaceFirst(
    '/upload/',
    '/upload/f_auto,q_auto,w_800/',
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            style: textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
