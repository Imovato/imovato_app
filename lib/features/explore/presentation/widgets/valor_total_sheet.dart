import 'package:flutter/material.dart';

import '../../../../app/utils/br_currency.dart';

class ValorTotalSheet extends StatefulWidget {
  final double initialValue;
  const ValorTotalSheet({super.key, required this.initialValue});

  @override
  State<ValorTotalSheet> createState() => _ValorTotalSheetState();
}

class _ValorTotalSheetState extends State<ValorTotalSheet> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue.clamp(500, 15000);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.85,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Valor Total',
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
              Container(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius:
                      ImovatoBorderRadius.circular(ImovatoBorderRadius.lg),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  'O valor total já inclui aluguel, condomínio, IPTU, internet, seguro residencial, suporte e manutenções.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Valor Total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('R\$ 500', style: textTheme.labelMedium),
                  Text(
                    formatBRL0(value),
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: scheme.primary,
                  inactiveTrackColor: scheme.primary.withValues(alpha: 0.25),
                  thumbColor: scheme.primary,
                  overlayColor: scheme.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: value,
                  min: 500,
                  max: 15000,
                  divisions: 145,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, value),
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
