import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';

class FiltroBuscaResult {
  final double? priceMin;
  final double? priceMax;
  final String? accommodationType;
  final int? maxOccupancy;
  final bool? allowsPets;
  final bool? allowsChildren;
  final bool? isSharedHosting;

  const FiltroBuscaResult({
    this.priceMin,
    this.priceMax,
    this.accommodationType,
    this.maxOccupancy,
    this.allowsPets,
    this.allowsChildren,
    this.isSharedHosting,
  });
}

class FiltroBuscaSheet extends StatefulWidget {
  final FiltroBuscaResult? initial;

  const FiltroBuscaSheet({
    super.key,
    this.initial,
  });

  @override
  State<FiltroBuscaSheet> createState() => _FiltroBuscaSheetState();
}

class _FiltroBuscaSheetState extends State<FiltroBuscaSheet> {
  late double _priceMin;
  late double _priceMax;
  String? _accommodationType;
  int? _maxOccupancy;
  bool? _allowsPets;
  bool? _allowsChildren;
  bool? _isSharedHosting;

  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceMin = widget.initial?.priceMin ?? 0;
    _priceMax = widget.initial?.priceMax ?? 10000;
    _accommodationType = widget.initial?.accommodationType;
    _maxOccupancy = widget.initial?.maxOccupancy;
    _allowsPets = widget.initial?.allowsPets;
    _allowsChildren = widget.initial?.allowsChildren;
    _isSharedHosting = widget.initial?.isSharedHosting;

    if (widget.initial?.priceMin != null) {
      _priceMinController.text = _priceMin.toStringAsFixed(0);
    }
    if (widget.initial?.priceMax != null) {
      _priceMaxController.text = _priceMax.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.outlineVariant,
                            borderRadius: ImovatoBorderRadius.circular(
                                ImovatoBorderRadius.xs),
                          ),
                        ),
                      ),
                      const SizedBox(height: ImovatoSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filtros',
                              style: textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            tooltip: 'Fechar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _SectionCard(
                        title: 'Faixa de preço (R\$)',
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceMinController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Preço mínimo',
                                  border: OutlineInputBorder(
                                    borderRadius: ImovatoBorderRadius.circular(
                                        ImovatoBorderRadius.sm),
                                  ),
                                  prefixText: 'R\$ ',
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() => _priceMin =
                                        double.tryParse(value) ?? 0);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _priceMaxController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Preço máximo',
                                  border: OutlineInputBorder(
                                    borderRadius: ImovatoBorderRadius.circular(
                                        ImovatoBorderRadius.sm),
                                  ),
                                  prefixText: 'R\$ ',
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() => _priceMax =
                                        double.tryParse(value) ?? 10000);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Tipo de moradia',
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              value: 'APARTMENT',
                              groupValue: _accommodationType,
                              onChanged: (v) =>
                                  setState(() => _accommodationType = v),
                              activeColor: scheme.primary,
                              title: const Text('Apartamento'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<String>(
                              value: 'HOUSE',
                              groupValue: _accommodationType,
                              onChanged: (v) =>
                                  setState(() => _accommodationType = v),
                              activeColor: scheme.primary,
                              title: const Text('Casa'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Tipo de hospedagem',
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: _isSharedHosting == true,
                              onChanged: (checked) => setState(
                                () => _isSharedHosting =
                                    checked == true ? true : null,
                              ),
                              title: const Text('Compartilhado'),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: scheme.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              value: _isSharedHosting == false,
                              onChanged: (checked) => setState(
                                () => _isSharedHosting =
                                    checked == true ? false : null,
                              ),
                              title: const Text('Moradia Individual'),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: scheme.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Quantas pessoas?',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final occ in const [1, 2, 3, 4, 5])
                              ChoiceChip(
                                label: Text('$occ'),
                                selected: _maxOccupancy == occ,
                                onSelected: (sel) => setState(
                                    () => _maxOccupancy = sel ? occ : null),
                                selectedColor: scheme.primary,
                                labelStyle: TextStyle(
                                  color: _maxOccupancy == occ
                                      ? scheme.onPrimary
                                      : textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: scheme.surfaceContainerLowest,
                                side: BorderSide(color: scheme.outlineVariant),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Pet friendly',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Sim'),
                              selected: _allowsPets == true,
                              onSelected: (sel) => setState(
                                  () => _allowsPets = sel ? true : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _allowsPets == true
                                    ? scheme.onPrimary
                                    : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                            ChoiceChip(
                              label: const Text('Não'),
                              selected: _allowsPets == false,
                              onSelected: (sel) => setState(
                                  () => _allowsPets = sel ? false : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _allowsPets == false
                                    ? scheme.onPrimary
                                    : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Permite crianças',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Sim'),
                              selected: _allowsChildren == true,
                              onSelected: (sel) => setState(
                                  () => _allowsChildren = sel ? true : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _allowsChildren == true
                                    ? scheme.onPrimary
                                    : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                            ChoiceChip(
                              label: const Text('Não'),
                              selected: _allowsChildren == false,
                              onSelected: (sel) => setState(
                                  () => _allowsChildren = sel ? false : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _allowsChildren == false
                                    ? scheme.onPrimary
                                    : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      )
                    ],
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Limpar estado interno primeiro
                            setState(() {
                              _priceMin = 0;
                              _priceMax = 10000;
                              _accommodationType = null;
                              _maxOccupancy = null;
                              _allowsPets = null;
                              _allowsChildren = null;
                              _isSharedHosting = null;
                              _priceMinController.clear();
                              _priceMaxController.clear();
                            });

                            // Retornar resultado vazio para limpar os filtros no controller
                            Navigator.pop(
                              context,
                              const FiltroBuscaResult(
                                priceMin: null,
                                priceMax: null,
                                accommodationType: null,
                                maxOccupancy: null,
                                allowsPets: null,
                                allowsChildren: null,
                                isSharedHosting: null,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                          child: Text(
                            'Limpar',
                            style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            double? finalPriceMin;
                            double? finalPriceMax;

                            if (_priceMinController.text.isNotEmpty) {
                              finalPriceMin =
                                  double.tryParse(_priceMinController.text);
                            }
                            if (_priceMaxController.text.isNotEmpty) {
                              finalPriceMax =
                                  double.tryParse(_priceMaxController.text);
                            }

                            final result = FiltroBuscaResult(
                              priceMin: finalPriceMin,
                              priceMax: finalPriceMax,
                              accommodationType: _accommodationType,
                              maxOccupancy: _maxOccupancy,
                              allowsPets: _allowsPets,
                              allowsChildren: _allowsChildren,
                              isSharedHosting: _isSharedHosting,
                            );

                            debugPrint('===== FILTROS APLICADOS =====');
                            debugPrint('priceMin: ${result.priceMin}');
                            debugPrint('priceMax: ${result.priceMax}');
                            debugPrint(
                                'accommodationType: ${result.accommodationType}');
                            debugPrint('maxOccupancy: ${result.maxOccupancy}');
                            debugPrint('allowsPets: ${result.allowsPets}');
                            debugPrint(
                                'allowsChildren: ${result.allowsChildren}');
                            debugPrint(
                                'isSharedHosting: ${result.isSharedHosting}');
                            debugPrint('=============================');

                            Navigator.pop(context, result);
                          },
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                          child: const Text('Aplicar filtros'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
