class Despesa {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;

  Despesa({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
    };
  }

  static Despesa fromMap(Map<String, dynamic> map, String id) {
    return Despesa(
      id: id, 
      descricao: map['descricao'] ?? 'Descrição não informada', // Valor padrão caso seja null
      valor: (map['valor'] ?? 0.0).toDouble(), // Valor padrão caso seja null
      data: map['data'] != null ? DateTime.parse(map['data']) : DateTime.now(), // Data atual como valor padrão
    );
  }
}
