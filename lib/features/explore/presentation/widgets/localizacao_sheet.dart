import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:imovato_app/shared/models/location_option.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';

class LocalizacaoSheet extends StatefulWidget {
  final LocationOption? initialValue;

  static const defaultCities = [
    LocationOption(city: 'Alegrete', state: 'RS'),
    LocationOption(city: 'Bagé', state: 'RS'),
    LocationOption(city: 'São Gabriel', state: 'RS'),
    LocationOption(city: 'Uruguaiana', state: 'RS'),
  ];

  final List<LocationOption> cidades;

  const LocalizacaoSheet(
      {super.key, this.initialValue, this.cidades = defaultCities});

  @override
  State<LocalizacaoSheet> createState() => _LocalizacaoSheetState();
}

class _LocalizacaoSheetState extends State<LocalizacaoSheet> {
  LocationOption? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? widget.cidades.first;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.8,
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
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius:
                        ImovatoBorderRadius.circular(ImovatoBorderRadius.xs),
                  ),
                ),
              ),
              const SizedBox(height: ImovatoSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Localização',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
              const SizedBox(height: ImovatoSpacing.xs),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius:
                      ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: widget.cidades.map((c) {
                    final selected = c == _selected;
                    return RadioListTile<LocationOption>(
                      value: c,
                      groupValue: _selected,
                      onChanged: (v) => setState(() => _selected = v),
                      activeColor: scheme.primary,
                      title: Text(
                        c.label,
                        style: textTheme.bodyLarge?.copyWith(
                          color: selected ? scheme.primary : scheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: ImovatoSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        ImovatoBorderRadius.circular(ImovatoBorderRadius.lg),
                  ),
                ),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
