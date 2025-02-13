class VendaItem {
  String produto;
  int quantidade;
  double valorUnidade;

  VendaItem({
    required this.produto,
    required this.quantidade,
    required this.valorUnidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'produto': produto,
      'quantidade': quantidade,
      'valorUnidade': valorUnidade,
    };
  }

  factory VendaItem.fromJson(Map<String, dynamic> json) {
    return VendaItem(
      produto: json['produto'],
      quantidade: json['quantidade'],
      valorUnidade: json['valorUnidade'],
    );
  }
}
