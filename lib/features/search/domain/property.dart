class Property {
  final String id;
  final String titulo;       // ex: "Vila Gumercindo · Rua Assungui"
  final String detalhes;     // ex: "Mobiliado · 24m² · Studio"
  final double aluguel;      // ex: 2700
  final double total;        // ex: 3500
  final List<String> fotos;
  final bool favorito;
  final String? descricao;       // texto livre (opcional)
  final int minPeriodoMeses;     // período mínimo (default: 1)

  const Property({
    required this.id,
    required this.titulo,
    required this.detalhes,
    required this.aluguel,
    required this.total,
    required this.fotos,
    this.favorito = false,
    this.descricao,
    this.minPeriodoMeses = 1,
  });

  Property copyWith({bool? favorito}) =>
      Property(
        id: id,
        titulo: titulo,
        detalhes: detalhes,
        aluguel: aluguel,
        total: total,
        fotos: fotos,
        favorito: favorito ?? this.favorito,
        descricao: descricao ?? this.descricao,
        minPeriodoMeses: minPeriodoMeses ?? this.minPeriodoMeses,
      );
}
