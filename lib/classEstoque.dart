class EstoqueItem {
  String id;
  String produto;
  int quantidadeEntrada;
  int quantidadeSaida;
  int quantidadeRestante;
  double valorUnidade;
  double valorTotal;
  String imagemUrl; // Campo para armazenar a URL da imagem
  String categoria; // Novo campo para armazenar a categoria do produto

  EstoqueItem({
    this.id = '',
    required this.produto,
    required this.quantidadeEntrada,
    required this.quantidadeSaida,
    required this.quantidadeRestante,
    required this.valorUnidade,
    required this.valorTotal,
    this.imagemUrl = '', // Inicializa com uma string vazia caso não tenha imagem
    required this.categoria, // Categoria é um campo obrigatório
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produto': produto,
      'quantidadeEntrada': quantidadeEntrada,
      'quantidadeSaida': quantidadeSaida,
      'quantidadeRestante': quantidadeRestante,
      'valorUnidade': valorUnidade,
      'valorTotal': valorTotal,
      'imagemUrl': imagemUrl, // Adiciona a URL da imagem ao JSON
      'categoria': categoria, // Adiciona a categoria ao JSON
    };
  }

  factory EstoqueItem.fromJson(Map<String, dynamic> json) {
    return EstoqueItem(
      id: json['id'],
      produto: json['produto'],
      quantidadeEntrada: json['quantidadeEntrada'],
      quantidadeSaida: json['quantidadeSaida'],
      quantidadeRestante: json['quantidadeRestante'],
      valorUnidade: json['valorUnidade'],
      valorTotal: json['valorTotal'],
      imagemUrl: json['imagemUrl'] ?? '', // Verifica se existe a URL da imagem no JSON
      categoria: json['categoria'] ?? '', // Verifica se existe a categoria no JSON
    );
  }
}
