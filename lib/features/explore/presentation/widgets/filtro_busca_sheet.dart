import 'package:flutter/material.dart';

class FiltroBuscaResult {
  final String fumantes;                    // 'Sim' | 'Não' | 'Tanto faz'
  final Set<int> pessoasCompartilhando;     // mantém Set, mas você seleciona só 1
  final int? numQuartos;                    // 1, 2, 3, 4 (representa 4+)
  final String? tipoImovel;                 // 'Apartamento' | 'Casa'
  final bool? petFriendly;                  // true (Sim) | false (Não)
  final int? duracaoEstadia;                // duração em meses
  final DateTime? dataInicio;               // data de início

  const FiltroBuscaResult({
    required this.fumantes,
    required this.pessoasCompartilhando,
    this.numQuartos,
    this.tipoImovel,
    this.petFriendly,
    this.duracaoEstadia,
    this.dataInicio,
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
  // ---- Estados ----
  late String _fumantes;
  late Set<int> _pessoasCompartilhando;
  int? _numQuartos;
  String? _tipoImovel;
  bool? _petFriendly;
  int _duracaoEstadia = 1;
  late DateTime _dataInicio;

  @override
  void initState() {
    super.initState();
    _fumantes = widget.initial?.fumantes ?? 'Tanto faz';
    _pessoasCompartilhando = widget.initial?.pessoasCompartilhando.toSet() ?? <int>{};
    _numQuartos = widget.initial?.numQuartos;
    _tipoImovel = widget.initial?.tipoImovel;
    _petFriendly = widget.initial?.petFriendly;
    _duracaoEstadia = widget.initial?.duracaoEstadia ?? 1;
    _dataInicio = widget.initial?.dataInicio ?? DateTime.now();
  }

  // Seleção exclusiva para "Pessoas compartilhando"
  void _selectSinglePessoa(int n, bool checked) {
    setState(() {
      if (checked) {
        _pessoasCompartilhando
          ..clear()
          ..add(n);
      } else {
        _pessoasCompartilhando.clear();
      }
    });
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 44, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filtros',
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

                // Conteúdo
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      // Número de quartos
                      _SectionCard(
                        title: 'Número de quartos',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final q in const [1, 2, 3, 4])
                              ChoiceChip(
                                label: Text(q == 4 ? '4+ Quartos' : '$q Quarto${q > 1 ? 's' : ''}'),
                                selected: _numQuartos == q,
                                onSelected: (sel) => setState(() => _numQuartos = sel ? q : null),
                                selectedColor: scheme.primary,
                                labelStyle: TextStyle(
                                  color: _numQuartos == q ? scheme.onPrimary : textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: scheme.surfaceContainerHighest,
                                side: const BorderSide(color: Colors.black12),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tipo de imóvel
                      _SectionCard(
                        title: 'Tipo de imóvel',
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              value: 'Apartamento',
                              groupValue: _tipoImovel,
                              onChanged: (v) => setState(() => _tipoImovel = v),
                              activeColor: scheme.primary,
                              title: const Text('Apartamento'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<String>(
                              value: 'Casa',
                              groupValue: _tipoImovel,
                              onChanged: (v) => setState(() => _tipoImovel = v),
                              activeColor: scheme.primary,
                              title: const Text('Casa'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Pet friendly
                      _SectionCard(
                        title: 'Pet friendly',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Sim'),
                              selected: _petFriendly == true,
                              onSelected: (sel) => setState(() => _petFriendly = sel ? true : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _petFriendly == true ? scheme.onPrimary : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                            ChoiceChip(
                              label: const Text('Não'),
                              selected: _petFriendly == false,
                              onSelected: (sel) => setState(() => _petFriendly = sel ? false : null),
                              selectedColor: scheme.primary,
                              labelStyle: TextStyle(
                                color: _petFriendly == false ? scheme.onPrimary : textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),


                      // Pessoas compartilhando (mantido - seleção única)
                      _SectionCard(
                        title: 'Pessoas compartilhando o apartamento',
                        subtitle: 'Aplicados somente para apartamentos compartilhados (coliving)',
                        child: Column(
                          children: [
                            for (final n in const [2, 3, 4, 5])
                              CheckboxListTile(
                                value: _pessoasCompartilhando.contains(n),
                                onChanged: (checked) => _selectSinglePessoa(n, checked ?? false),
                                title: Text('$n Pessoas'),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: scheme.primary,
                                contentPadding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Duração da estadia
                      _SectionCard(
                        title: 'Duração da estadia',
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  '$_duracaoEstadia meses',
                                  style: textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _duracaoEstadia > 1
                                  ? () => setState(() => _duracaoEstadia--)
                                  : null,
                              tooltip: 'Diminuir',
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _duracaoEstadia++),
                              tooltip: 'Aumentar',
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Data de início
                      _SectionCard(
                        title: 'Data de início',
                        child: GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _dataInicio,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (pickedDate != null) {
                              setState(() => _dataInicio = pickedDate);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_dataInicio.day.toString().padLeft(2, '0')} / ${_dataInicio.month.toString().padLeft(2, '0')} / ${_dataInicio.year}',
                                  style: textTheme.bodyLarge,
                                ),
                                Icon(Icons.calendar_today, color: scheme.primary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Barra inferior
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10, offset: const Offset(0, -2))],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _fumantes = 'Tanto faz';
                              _pessoasCompartilhando.clear();
                              _numQuartos = null;
                              _tipoImovel = null;
                              _petFriendly = null;
                              _duracaoEstadia = 1;
                              _dataInicio = DateTime.now();
                            });
                          },
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          child: Text(
                            'Limpar',
                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              FiltroBuscaResult(
                                fumantes: _fumantes,
                                pessoasCompartilhando: _pessoasCompartilhando,
                                numQuartos: _numQuartos,
                                tipoImovel: _tipoImovel,
                                petFriendly: _petFriendly,
                                duracaoEstadia: _duracaoEstadia,
                                dataInicio: _dataInicio,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          child: const Text('Ver imóveis'),
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
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1.5,
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withOpacity(.8))),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
