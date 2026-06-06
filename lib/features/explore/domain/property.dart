class Property {
  final int id;
  final String titulo;
  final String descricao;
  final double aluguel;
  final double total;
  final List<String> fotos;

  Property({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.aluguel,
    required this.total,
    required this.fotos,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'],
    titulo: json['titulo'],
    descricao: json['descricao'] ?? '',
    aluguel: (json['aluguel'] ?? 0).toDouble(),
    total: (json['total'] ?? 0).toDouble(),
    fotos: List<String>.from(json['fotos'] ?? []),
  );
}
