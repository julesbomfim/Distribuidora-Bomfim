import 'package:distribuidora_bomfim/ClassVendaItem.dart';

class Venda {
  String id;
  List<VendaItem> itens;
  double valorTotal;
  double desconto;
  DateTime dataVenda;
  String formaPagamento1;
  String? formaPagamento2;
  double valorPagamento1;
  double? valorPagamento2;
  String nomeVendedor;
  String? tipoPixPagamento1; // Tipo de Pix para pagamento 1, opcional
  String? tipoPixPagamento2; // Tipo de Pix para pagamento 2, opcional

  Venda({
    this.id = '',
    required this.itens,
    required this.valorTotal,
    this.desconto = 0.0,
    required this.dataVenda,
    required this.formaPagamento1,
    this.formaPagamento2,
    required this.valorPagamento1,
    this.valorPagamento2,
    required this.nomeVendedor,
    this.tipoPixPagamento1, // Inicializa tipo de Pix como opcional
    this.tipoPixPagamento2, // Inicializa tipo de Pix como opcional
  });

  double get valorComDesconto => valorTotal - desconto;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itens': itens.map((item) => item.toJson()).toList(),
      'valorTotal': valorTotal,
      'desconto': desconto,
      'dataVenda': dataVenda.toIso8601String(),
      'formaPagamento1': formaPagamento1,
      'formaPagamento2': formaPagamento2,
      'valorPagamento1': valorPagamento1,
      'valorPagamento2': valorPagamento2,
      'nomeVendedor': nomeVendedor,
      'tipoPixPagamento1': tipoPixPagamento1,
      'tipoPixPagamento2': tipoPixPagamento2,
    };
  }

  factory Venda.fromJson(Map<String, dynamic> json) {
    return Venda(
      id: json['id'] ?? '',
      itens: (json['itens'] as List).map((item) => VendaItem.fromJson(item)).toList(),
      valorTotal: json['valorTotal'],
      desconto: json['desconto'] ?? 0.0,
      dataVenda: DateTime.parse(json['dataVenda']),
      formaPagamento1: json['formaPagamento1'] ?? 'Não especificada',
      formaPagamento2: json['formaPagamento2'],
      valorPagamento1: json['valorPagamento1'] ?? 0.0,
      valorPagamento2: json['valorPagamento2'],
      nomeVendedor: json['nomeVendedor'] ?? 'Não informado',
      tipoPixPagamento1: json['tipoPixPagamento1'], // Pode ser nulo
      tipoPixPagamento2: json['tipoPixPagamento2'], // Pode ser nulo
    );
  }
}
