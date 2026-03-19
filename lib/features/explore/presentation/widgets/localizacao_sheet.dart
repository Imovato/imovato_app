import 'package:flutter/material.dart';

class LocalizacaoSheet extends StatefulWidget {
  final String? initialValue;
  final List<String> cidades;

  const LocalizacaoSheet({
    super.key,
    this.initialValue,
    this.cidades = const [
      'Alegrete, RS',
      'Bagé, RS',
      'Caçapava do Sul, RS',
      'Dom Pedrito, RS',
      'Itaqui, RS',
      'Jaguarão, RS',
      'Porto Alegre, RS',
      'Santana do Livramento, RS',
      'São Borja, RS',
      'São Gabriel, RS',
      'Uruguaiana, RS',
      'São Paulo, SP',
      'Florianópolis, SC',
      'Curitiba, PR',
    ],
  });

  @override
  State<LocalizacaoSheet> createState() => _LocalizacaoSheetState();
}

class _LocalizacaoSheetState extends State<LocalizacaoSheet> {
  String? _selected;

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 24, offset: const Offset(0, -6))],
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              // pegador
              Center(
                child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),

              // header
              Row(
                children: [
                  Expanded(
                    child: Text('Localização', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), tooltip: 'Fechar'),
                ],
              ),
              const SizedBox(height: 8),

              ...widget.cidades.map((c) => RadioListTile<String>(
                value: c,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                activeColor: scheme.primary,
                title: Text(c),
                contentPadding: EdgeInsets.zero,
              )),

              const SizedBox(height: 12),

              FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('ok'),
              ),
            ],
          ),
        );
      },
    );
  }
}
