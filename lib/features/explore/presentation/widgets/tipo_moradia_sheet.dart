import 'package:flutter/material.dart';

class TipoMoradiaSheet extends StatefulWidget {
  final String? initialValue;
  const TipoMoradiaSheet({super.key, this.initialValue});

  @override
  State<TipoMoradiaSheet> createState() => _TipoMoradiaSheetState();
}

class _TipoMoradiaSheetState extends State<TipoMoradiaSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.7,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                      'Tipo de Moradia',
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius:
                      ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'Apartamento Inteiro',
                      groupValue: _selected,
                      activeColor: scheme.primary,
                      title: const Text('Apartamento Inteiro'),
                      subtitle: const Text('Individual, Casal ou Família'),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    RadioListTile<String>(
                      value: 'Compartilhado',
                      groupValue: _selected,
                      activeColor: scheme.primary,
                      title: const Text('Compartilhado'),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    RadioListTile<String>(
                      value: 'Tanto Faz',
                      groupValue: _selected,
                      activeColor: scheme.primary,
                      title: const Text('Tanto Faz'),
                      subtitle: const Text('Inteiro e compartilhado'),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                  ],
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
