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
      'São Gabriel, RS',
      'Uruguaiana, RS',
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: widget.cidades.map((c) {
                    final selected = c == _selected;
                    return RadioListTile<String>(
                      value: c,
                      groupValue: _selected,
                      onChanged: (v) => setState(() => _selected = v),
                      activeColor: scheme.primary,
                      title: Text(
                        c,
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
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
