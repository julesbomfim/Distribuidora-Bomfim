import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:distribuidora_bomfim/classDespesas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'classVenda.dart';
import 'ClassVendaItem.dart';

class HistoricoPage extends StatelessWidget {
  final String adminPassword = "admin123"; // Defina a senha do administrador aqui



/////////////////////////

Future<Map<String, double>> _carregarDespesasPorMes() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('despesas').get();

  Map<String, double> despesasPorMes = {};

  for (var doc in snapshot.docs) {
    try {
      DateTime dataDespesa = DateTime.parse(doc['data']);
      String mesAno = DateFormat('MM/yyyy').format(dataDespesa);
      double valorDespesa = doc['valor'] ?? 0.0;

      if (despesasPorMes.containsKey(mesAno)) {
        despesasPorMes[mesAno] = despesasPorMes[mesAno]! + valorDespesa;
      } else {
        despesasPorMes[mesAno] = valorDespesa;
      }
    } catch (e) {
      print('Erro ao processar despesa: $e');
    }
  }

  return despesasPorMes;
}


Future<Map<String, Map<String, double>>> _carregarSomaVendasPorMes() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Vendas').get();

  Map<String, Map<String, double>> vendasPorMes = {};

  for (var doc in snapshot.docs) {
    try {
      DateTime dataVenda = DateTime.parse(doc['dataVenda']);
      String mesAno = DateFormat('MM/yyyy').format(dataVenda);
      double valorTotal = doc['valorTotal'] ?? 0.0;

      // Extrai os valores e formas de pagamento
      double valorPagamento1 = doc['valorPagamento1'] ?? 0.0;
      double valorPagamento2 = doc['valorPagamento2'] ?? 0.0;
      String formaPagamento1 = doc['formaPagamento1']?.toLowerCase() ?? '';
      String formaPagamento2 = doc['formaPagamento2']?.toLowerCase() ?? '';

      // Inicializa o mapa de formas de pagamento para o mês, se não existir
      vendasPorMes[mesAno] ??= {
        'pix': 0.0,
        'cartao': 0.0,
        'dinheiro': 0.0,
        'total': 0.0,
      };

      // Acumula os valores conforme a forma de pagamento
      if (formaPagamento1 == 'pix') {
        vendasPorMes[mesAno]!['pix'] = (vendasPorMes[mesAno]!['pix'] ?? 0) + valorPagamento1;
      } else if (formaPagamento1 == 'cartão') {
        vendasPorMes[mesAno]!['cartao'] = (vendasPorMes[mesAno]!['cartao'] ?? 0) + valorPagamento1;
      } else if (formaPagamento1 == 'dinheiro') {
        vendasPorMes[mesAno]!['dinheiro'] = (vendasPorMes[mesAno]!['dinheiro'] ?? 0) + valorPagamento1;
      }

      if (formaPagamento2 == 'pix') {
        vendasPorMes[mesAno]!['pix'] = (vendasPorMes[mesAno]!['pix'] ?? 0) + valorPagamento2;
      } else if (formaPagamento2 == 'cartão') {
        vendasPorMes[mesAno]!['cartao'] = (vendasPorMes[mesAno]!['cartao'] ?? 0) + valorPagamento2;
      } else if (formaPagamento2 == 'dinheiro') {
        vendasPorMes[mesAno]!['dinheiro'] = (vendasPorMes[mesAno]!['dinheiro'] ?? 0) + valorPagamento2;
      }

      // Acumula o total de vendas para o mês
      vendasPorMes[mesAno]!['total'] = (vendasPorMes[mesAno]!['total'] ?? 0) + valorTotal;

    } catch (e) {
      print('Erro ao processar venda: $e');
    }
  }

  return vendasPorMes;
}



// Future<Map<String, Map<String, double>>> _carregarSomaVendasPorMes() async {
//   // Carrega todas as vendas
//   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Vendas').get();

//   // Inicializa um mapa para acumular valores mensais
//   Map<String, Map<String, double>> vendasPorMes = {};

//   // Itera sobre cada documento de venda
//   for (var doc in snapshot.docs) {
//     try {
//       // Extrai a data e formata para MM/yyyy
//       DateTime dataVenda = DateTime.parse(doc['dataVenda']);
//       String mesAno = DateFormat('MM/yyyy').format(dataVenda);

//       // Extrai os valores de pagamento e total
//       double valorPagamento1 = doc['valorPagamento1'] ?? 0.0;
//       double valorPagamento2 = doc['valorPagamento2'] ?? 0.0;
//       double valorTotal = doc['valorTotal'] ?? 0.0;

//       // Verifica as formas de pagamento
//       String formaPagamento1 = doc['formaPagamento1']?.toLowerCase() ?? '';
//       String formaPagamento2 = doc['formaPagamento2']?.toLowerCase() ?? '';
//       String tipoPixPagamento1 = doc['tipoPixPagamento1']?.toLowerCase() ?? '';
//       String tipoPixPagamento2 = doc['tipoPixPagamento2']?.toLowerCase() ?? '';

//       // Garante que o mês tenha uma estrutura inicial, preservando valores anteriores
//       vendasPorMes[mesAno] ??= {
//         'pix maquineta': 0.0,
//         'pix conta': 0.0,
//         'cartao': 0.0,
//         'dinheiro': 0.0,
//         'total': 0.0,
//       };

//       // Acumula os valores de acordo com a forma de pagamento e tipo de Pix
//       if (formaPagamento1 == 'pix') {
//         if (tipoPixPagamento1 == 'pix maquineta') {
//           vendasPorMes[mesAno]!['pix maquineta'] = vendasPorMes[mesAno]!['pix maquineta']! + valorPagamento1;
//         } else if (tipoPixPagamento1 == 'pix conta' || tipoPixPagamento1 == '') {
//           vendasPorMes[mesAno]!['pix conta'] = vendasPorMes[mesAno]!['pix conta']! + valorPagamento1;
//         }
//       } else if (formaPagamento1 == 'cartão') {
//         vendasPorMes[mesAno]!['cartao'] = vendasPorMes[mesAno]!['cartao']! + valorPagamento1;
//       } else if (formaPagamento1 == 'dinheiro') {
//         vendasPorMes[mesAno]!['dinheiro'] = vendasPorMes[mesAno]!['dinheiro']! + valorPagamento1;
//       }

//       if (formaPagamento2 == 'pix') {
//         if (tipoPixPagamento2 == 'pix maquineta') {
//           vendasPorMes[mesAno]!['pix maquineta'] = vendasPorMes[mesAno]!['pix maquineta']! + valorPagamento2;
//         } else if (tipoPixPagamento2 == 'pix conta' || tipoPixPagamento2 == '') {
//           vendasPorMes[mesAno]!['pix conta'] = vendasPorMes[mesAno]!['pix conta']! + valorPagamento2;
//         }
//       } else if (formaPagamento2 == 'cartão') {
//         vendasPorMes[mesAno]!['cartao'] = vendasPorMes[mesAno]!['cartao']! + valorPagamento2;
//       } else if (formaPagamento2 == 'dinheiro') {
//         vendasPorMes[mesAno]!['dinheiro'] = vendasPorMes[mesAno]!['dinheiro']! + valorPagamento2;
//       }

//       // Atualiza o total de vendas para o mês
//       vendasPorMes[mesAno]!['total'] = vendasPorMes[mesAno]!['total']! + valorTotal;

//     } catch (e) {
//       print('Erro ao processar venda: $e');
//     }
//   }

//   return vendasPorMes;
// }




///////////// esse //////////////////////////
// Future<Map<String, Map<String, double>>> _carregarSomaVendasPorMes() async {
//   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Vendas').get();

//   Map<String, Map<String, double>> vendasPorMes = {};

//   for (var doc in snapshot.docs) {
//     try {
//       DateTime dataVenda = DateTime.parse(doc['dataVenda']);
//       String mesAno = DateFormat('MM/yyyy').format(dataVenda);
//       double valorVenda = doc['valorTotal'] ?? 0.0;

//       // Verificar as formas de pagamento para cada venda
//       String formaPagamento1 = doc['formaPagamento1']?.toLowerCase() ?? '';
//       String formaPagamento2 = doc['formaPagamento2']?.toLowerCase() ?? '';

//       // Inicializando o mapa de formas de pagamento para o mês, se não existir
//       if (!vendasPorMes.containsKey(mesAno)) {
//         vendasPorMes[mesAno] = {
//           'pix maquineta': 0.0,
//           'pix conta': 0.0,
//           'cartao': 0.0,
//           'dinheiro': 0.0,
//           'total': 0.0,
//         };
//       }

//       // Acumulando os valores conforme a forma de pagamento
//       if (formaPagamento1 == 'pix maquineta') {
//         vendasPorMes[mesAno]!['Pix maquineta'] = vendasPorMes[mesAno]!['Pix maquineta']! + valorVenda;
//       } else if (formaPagamento1 == 'Pix conta') {
//         vendasPorMes[mesAno]!['Pix conta'] = vendasPorMes[mesAno]!['Pix conta']! + valorVenda;
//       } else if (formaPagamento1 == 'cartão') {
//         vendasPorMes[mesAno]!['cartao'] = vendasPorMes[mesAno]!['cartao']! + valorVenda;
//       } else if (formaPagamento1 == 'dinheiro') {
//         vendasPorMes[mesAno]!['dinheiro'] = vendasPorMes[mesAno]!['dinheiro']! + valorVenda;
//       }

//       // Considerando o segundo pagamento
//       if (formaPagamento2 == 'pix maquineta') {
//         vendasPorMes[mesAno]!['Pix maquineta'] = vendasPorMes[mesAno]!['pix maquineta']! + valorVenda;
//       } else if (formaPagamento2 == 'pix conta') {
//         vendasPorMes[mesAno]!['pix conta'] = vendasPorMes[mesAno]!['pix conta']! + valorVenda;
//       } else if (formaPagamento2 == 'cartão') {
//         vendasPorMes[mesAno]!['cartao'] = vendasPorMes[mesAno]!['cartao']! + valorVenda;
//       } else if (formaPagamento2 == 'dinheiro') {
//         vendasPorMes[mesAno]!['dinheiro'] = vendasPorMes[mesAno]!['dinheiro']! + valorVenda;
//       }

//       // Acumulando o total de vendas para o mês
//       vendasPorMes[mesAno]!['total'] = vendasPorMes[mesAno]!['total']! + valorVenda;

//     } catch (e) {
//       print('Erro ao processar venda: $e');
//     }
//   }

//   return vendasPorMes;
// }
///////////////////////////////////////////////////////

Future<Map<String, Map<String, double>>> _carregarVendasEDespesasPorMes() async {
  // Carregar vendas detalhadas (com Pix, Cartão e Dinheiro) e despesas de todos os meses
  Map<String, Map<String, double>> vendasPorMes = await _carregarSomaVendasPorMes();
  Map<String, double> despesasPorMes = await _carregarDespesasPorMes();

  // Criar o mapa final com os resultados de cada mês
  Map<String, Map<String, double>> resultadoPorMes = {};

  vendasPorMes.forEach((mes, vendasMap) {
    double totalVendas = vendasMap['total'] ?? 0.0;
    double totalPix = vendasMap['pix'] ?? 0.0;
    double totalCartao = vendasMap['cartao'] ?? 0.0;
    double totalDinheiro = vendasMap['dinheiro'] ?? 0.0;
    double totalDespesas = despesasPorMes[mes] ?? 0.0;
    double saldo = totalVendas - totalDespesas;

    resultadoPorMes[mes] = {
      'vendas': totalVendas,
      'pix': totalPix,
      'cartao': totalCartao,
      'dinheiro': totalDinheiro,
      'despesas': totalDespesas,
      'saldo': saldo,
    };
  });

  return resultadoPorMes;
}

// Future<Map<String, Map<String, double>>> _carregarVendasEDespesasPorMes() async {
//   // Carregar vendas e despesas de todos os meses
//   Map<String, Map<String, double>> vendasPorMes = await _carregarSomaVendasPorMes();  // Agora deve ser Map<String, Map<String, double>>
//   Map<String, double> despesasPorMes = await _carregarDespesasPorMes();

//   // Criar o mapa final com os resultados de cada mês
//   Map<String, Map<String, double>> resultadoPorMes = {};

//   vendasPorMes.forEach((mes, vendasMap) {
//     double totalVendas = vendasMap['total'] ?? 0.0;  // Acessando o total de vendas do mapa
//     double totalDespesas = despesasPorMes[mes] ?? 0.0; // Caso não haja despesas para o mês
    
//     // Adicionando as informações de vendas e despesas no resultado final
//     resultadoPorMes[mes] = {
//       'vendas': totalVendas,
//       'despesas': totalDespesas,
//       'saldo': totalVendas - totalDespesas, // Calcular o saldo
//       'pix maquineta': vendasMap['pix maquineta'] ?? 0.0,
//       'pix conta': vendasMap['pix conta'] ?? 0.0,
//       'cartao': vendasMap['cartao'] ?? 0.0,
//       'dinheiro': vendasMap['dinheiro'] ?? 0.0,
//     };
//   });

//   return resultadoPorMes;
// }

// Future<void> _gerarTabelaVendasPorMes(BuildContext context) async {
//   // Carregar vendas, despesas e saldo para todos os meses
//   Map<String, Map<String, double>> resultadoPorMes = await _carregarVendasEDespesasPorMes();

//   double totalVendas = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['vendas']!);
//   double totalDespesas = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['despesas']!);
//   double totalPixMaquineta = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['pix maquineta']!);
//   double totalPixConta = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['pix conta']!);
//   double totalCartao = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['cartao']!);
//   double totalDinheiro = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['dinheiro']!);
//   double saldoFinal = totalVendas - totalDespesas;

//   final pdf = pw.Document();

//   // Primeiro, cria uma lista temporária com os dados a serem exibidos
//   List<List<String>> dadosTabela = resultadoPorMes.entries
//       .map((entry) => [
//             entry.key, // Mês e ano
//             'R\$ ${entry.value['vendas']!.toStringAsFixed(2)}', // Total de vendas
//             'R\$ ${entry.value['pix maquineta']!.toStringAsFixed(2)}', // Valor de Pix Maquineta
//             'R\$ ${entry.value['pix conta']!.toStringAsFixed(2)}', // Valor de Pix Conta
//             'R\$ ${entry.value['cartao']!.toStringAsFixed(2)}', // Valor de Cartão
//             'R\$ ${entry.value['dinheiro']!.toStringAsFixed(2)}', // Valor de Dinheiro
//             'R\$ ${entry.value['despesas']!.toStringAsFixed(2)}', // Total de despesas
//             'R\$ ${entry.value['saldo']!.toStringAsFixed(2)}', // Saldo
//           ])
//       .toList();

//   // Ordena a lista temporária em ordem decrescente com base no mês
//   dadosTabela.sort((a, b) => DateFormat('MM/yyyy').parse(b[0]).compareTo(DateFormat('MM/yyyy').parse(a[0])));

//   // Adiciona a linha dos totais gerais
//   dadosTabela.add([
//     'Total Geral',
//     'R\$ ${totalVendas.toStringAsFixed(2)}',
//     'R\$ ${totalPixMaquineta.toStringAsFixed(2)}', 
//     'R\$ ${totalPixConta.toStringAsFixed(2)}', 
//     'R\$ ${totalCartao.toStringAsFixed(2)}', 
//     'R\$ ${totalDinheiro.toStringAsFixed(2)}', 
//     'R\$ ${totalDespesas.toStringAsFixed(2)}', 
//     'R\$ ${saldoFinal.toStringAsFixed(2)}'
//   ]);

//   // Adiciona a página ao PDF com a tabela ordenada
//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4, // Define o formato da página como A4
//       margin: pw.EdgeInsets.all(8), // Reduz as margens da página
//       build: (pw.Context context) => pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text('Relatório de Vendas e Despesas por Mês', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//           pw.SizedBox(height: 5), // Reduz o espaço vertical entre os elementos

//           pw.Table.fromTextArray(
//             headers: ['Mês', 'Total Vendas (R\$)', 'Pix Maquineta (R\$)', 'Pix Conta (R\$)', 'Cartão (R\$)', 'Dinheiro (R\$)', 'Total Despesas (R\$)', 'Saldo (R\$)'],
//             headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//             cellStyle: pw.TextStyle(fontSize: 9), // Diminui o tamanho da fonte
//             data: dadosTabela, // Usa a lista de dados ordenada
//             columnWidths: {
//               0: pw.FlexColumnWidth(2), // Aumenta o espaço da coluna do mês
//               1: pw.FlexColumnWidth(1.5),
//               2: pw.FlexColumnWidth(1.5),
//               3: pw.FlexColumnWidth(1.5),
//               4: pw.FlexColumnWidth(1.5),
//               5: pw.FlexColumnWidth(1.5),
//               6: pw.FlexColumnWidth(1.5),
//               7: pw.FlexColumnWidth(1.5),
//             },
//             border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey), // Diminui a espessura das bordas
//             cellPadding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Reduz o padding das células
//           ),
//         ],
//       ),
//     ),
//   );

//   // Imprimir o PDF
//   await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
// }


Future<void> _gerarTabelaVendasPorMes(BuildContext context) async {
  // Carregar vendas, despesas e saldo para todos os meses
  Map<String, Map<String, double>> resultadoPorMes = await _carregarVendasEDespesasPorMes();

  // Ordenar o mapa em ordem decrescente de meses
  var mesesOrdenados = resultadoPorMes.entries.toList()
    ..sort((a, b) => DateFormat('MM/yyyy').parse(b.key).compareTo(DateFormat('MM/yyyy').parse(a.key)));

  // Calcular os totais gerais
  double totalVendas = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['vendas']!);
  double totalDespesas = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['despesas']!);
  double totalPix = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['pix']!);
  double totalCartao = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['cartao']!);
  double totalDinheiro = resultadoPorMes.values.fold(0.0, (previousValue, value) => previousValue + value['dinheiro']!);
  double saldoFinal = totalVendas - totalDespesas;

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(8),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Vendas e Despesas por Mês', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          
          pw.Table.fromTextArray(
            headers: ['Mês', 'Total Vendas (R\$)', 'Pix (R\$)', 'Cartão (R\$)', 'Dinheiro (R\$)', 'Total Despesas (R\$)', 'Saldo (R\$)'],
            headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 9),
            data: [
              ...mesesOrdenados.map((entry) => [
                entry.key, // Mês e ano
                'R\$ ${entry.value['vendas']!.toStringAsFixed(2)}',
                'R\$ ${entry.value['pix']!.toStringAsFixed(2)}',
                'R\$ ${entry.value['cartao']!.toStringAsFixed(2)}',
                'R\$ ${entry.value['dinheiro']!.toStringAsFixed(2)}',
                'R\$ ${entry.value['despesas']!.toStringAsFixed(2)}',
                'R\$ ${entry.value['saldo']!.toStringAsFixed(2)}',
              ]).toList(),
              // Linha de totais gerais para cada coluna
              [
                'Total Geral',
                'R\$ ${totalVendas.toStringAsFixed(2)}',
                'R\$ ${totalPix.toStringAsFixed(2)}',
                'R\$ ${totalCartao.toStringAsFixed(2)}',
                'R\$ ${totalDinheiro.toStringAsFixed(2)}',
                'R\$ ${totalDespesas.toStringAsFixed(2)}',
                'R\$ ${saldoFinal.toStringAsFixed(2)}',
              ],
            ],
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.5),
              5: pw.FlexColumnWidth(1.5),
              6: pw.FlexColumnWidth(1.5),
            },
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            cellPadding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          ),
        ],
      ),
    ),
  );

  // Imprimir o PDF
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}







////////////////////////////////



  Stream<List<Venda>> _carregarHistoricoVendas() {
    return FirebaseFirestore.instance
        .collection('Vendas')
        .orderBy('dataVenda', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Venda.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

Future<void> _imprimirHistoricoPorData(BuildContext context) async {
  DateTime? dataSelecionada = await _selecionarData(context);

  if (dataSelecionada == null) return; // Se o usuário não escolheu nenhuma data

  // Removemos as horas para fazer a comparação apenas da data
  DateTime inicioDoDia = DateTime(dataSelecionada.year, dataSelecionada.month, dataSelecionada.day);

  // Buscar vendas da coleção e filtrar pela data
  QuerySnapshot snapshotVendas = await FirebaseFirestore.instance.collection('Vendas').get();

  List<Venda> vendasDoDia = snapshotVendas.docs.map((doc) {
    try {
      // Convertendo a string de data no formato ISO para DateTime
      DateTime dataVenda = DateTime.parse(doc['dataVenda']);
      
      // Comparando apenas o dia, mês e ano
      if (dataVenda.year == inicioDoDia.year && dataVenda.month == inicioDoDia.month && dataVenda.day == inicioDoDia.day) {
        return Venda.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Erro ao converter data: $e');
    }
    return null; // Retorna null se não atender aos critérios
  }).whereType<Venda>().toList();

  // Carregar as despesas do dia
  List<Despesa> despesasDoDia = await _carregarDespesasPorData(dataSelecionada);

  // Gerar o PDF com as vendas e as despesas
  final pdf = await _gerarPDF(vendasDoDia, dataSelecionada, despesasDoDia);

  // Imprimir o PDF
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf);
}



Future<List<Despesa>> _carregarDespesasPorData(DateTime data) async {
  String dataFormatada = DateFormat('yyyy-MM-dd').format(data);

  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('despesas').get();

  List<Despesa> despesasDoDia = snapshot.docs
      .map((doc) => Despesa.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .where((despesa) => DateFormat('yyyy-MM-dd').format(despesa.data) == dataFormatada)
      .toList();

  return despesasDoDia;
}



Future<Uint8List> _gerarPDF(List<Venda> vendas, DateTime data, List<Despesa> despesas) async {
  final pdf = pw.Document();

  double totalVendas = 0.0;
  double totalPix = 0.0;
  double totalCartao = 0.0;
  double totalDinheiro = 0.0;
  double totalDespesas = despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);

  // Calcular o total de vendas e somar valores por forma de pagamento
  vendas.forEach((venda) {
    totalVendas += venda.valorTotal;

    if (venda.formaPagamento1.toLowerCase() == 'pix') {
      totalPix += venda.valorPagamento1;
    } else if (venda.formaPagamento1.toLowerCase() == 'cartão') {
      totalCartao += venda.valorPagamento1;
    } else if (venda.formaPagamento1.toLowerCase() == 'dinheiro') {
      totalDinheiro += venda.valorPagamento1;
    }

    if (venda.formaPagamento2 != null) {
      if (venda.formaPagamento2!.toLowerCase() == 'pix') {
        totalPix += venda.valorPagamento2!;
      } else if (venda.formaPagamento2!.toLowerCase() == 'cartão') {
        totalCartao += venda.valorPagamento2!;
      } else if (venda.formaPagamento2!.toLowerCase() == 'dinheiro') {
        totalDinheiro += venda.valorPagamento2!;
      }
    }
  });

  const int vendasPorPagina = 15;
  List<List<Venda>> paginasVendas = [];

  // Dividir as vendas em páginas
  for (int i = 0; i < vendas.length; i += vendasPorPagina) {
    paginasVendas.add(vendas.sublist(i, i + vendasPorPagina > vendas.length ? vendas.length : i + vendasPorPagina));
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
      margin: pw.EdgeInsets.all(4), 
      build: (pw.Context context) {
        List<pw.Widget> pages = [];
        
        // Cabeçalho só na primeira página
        bool isFirstPage = true;

        paginasVendas.forEach((paginaVendas) {
          pages.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (isFirstPage)
                  pw.Text(
                    'Histórico de Vendas - ${DateFormat('dd/MM/yyyy').format(data)}',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                pw.SizedBox(height: 4),
                pw.Table.fromTextArray(
                  headers: [
                    'Produto', 'Qtd', 'Unit', 'Desc', 'Pagamento', 'Subtotal', 'Total'
                  ],
                  headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(fontSize: 6),
                  data: paginaVendas.map((venda) {
                    // Agrupar os itens em uma única célula
                    String produtos = venda.itens.map((item) => item.produto).join(', ');
                    String quantidades = venda.itens.map((item) => item.quantidade.toString()).join(', ');
                    String valoresUnitarios = venda.itens.map((item) => 'R\$ ${item.valorUnidade.toStringAsFixed(2)}').join(', ');
                    String subtotais = venda.itens.map((item) => 'R\$ ${(item.quantidade * item.valorUnidade).toStringAsFixed(2)}').join(', ');

                    return [
                      produtos, // Todos os produtos juntos
                      quantidades, // Todas as quantidades juntas
                      valoresUnitarios, // Todos os valores unitários juntos
                      venda.desconto > 0 ? 'R\$ ${venda.desconto.toStringAsFixed(2)}' : 'Sem Desconto',
                      venda.formaPagamento2 != null
                          ? '${venda.formaPagamento1} (R\$ ${venda.valorPagamento1.toStringAsFixed(2)}) + ${venda.formaPagamento2} (R\$ ${venda.valorPagamento2!.toStringAsFixed(2)})'
                          : '${venda.formaPagamento1} (R\$ ${venda.valorPagamento1.toStringAsFixed(2)})',
                      subtotais, // Todos os subtotais juntos
                      'R\$ ${venda.valorTotal.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2.5), // Ajustar a largura da coluna do Produto
                    1: pw.FlexColumnWidth(1.0), // Quantidade
                    2: pw.FlexColumnWidth(2.5), // Valor Unitário
                    3: pw.FlexColumnWidth(1.5), // Desconto
                    4: pw.FlexColumnWidth(3.0), // Pagamento
                    5: pw.FlexColumnWidth(2.5), // Subtotal
                    6: pw.FlexColumnWidth(2.5), // Total
                  },
                  cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  headerDecoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(2),
                    color: PdfColors.grey300,
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          );
          isFirstPage = false; // Desativar o cabeçalho nas páginas subsequentes
        });

        // Adicionar a tabela de despesas com o total de despesas na última linha
        pages.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Despesas do dia:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Table.fromTextArray(
                headers: ['Descrição', 'Valor (R\$)'],
                headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 6),
                data: [
                  ...despesas.map((despesa) => [
                    despesa.descricao,
                    'R\$ ${despesa.valor.toStringAsFixed(2)}',
                  ]).toList(),
                  ['Total de Despesas', 'R\$ ${totalDespesas.toStringAsFixed(2)}'], // Linha do total de despesas
                ],
                cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              ),
              pw.SizedBox(height: 6),
            ],
          ),
        );

        // Adicionar a tabela de totais por forma de pagamento
        pages.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Totais por forma de pagamento:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Table.fromTextArray(
                headers: ['Forma de Pagamento', 'Total (R\$)'],
                headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 6),
                data: [
                  ['PIX', 'R\$ ${totalPix.toStringAsFixed(2)}'],
                  ['Cartão', 'R\$ ${totalCartao.toStringAsFixed(2)}'],
                  ['Dinheiro', 'R\$ ${totalDinheiro.toStringAsFixed(2)}'],
                ],
                cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              ),
              pw.SizedBox(height: 10),
            ],
          ),
        );

        // Adicionar a tabela separada para "Total de Vendas" e "Valor Final Após Despesas"
        pages.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resumo de Vendas:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Table.fromTextArray(
                headers: ['Descrição', 'Valor (R\$)'],
                headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 6),
                data: [
                  ['Total de Vendas', 'R\$ ${totalVendas.toStringAsFixed(2)}'],
                  ['Valor Final Após Despesas', 'R\$ ${(totalVendas - totalDespesas).toStringAsFixed(2)}'],
                ],
                cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              ),
              pw.SizedBox(height: 10),
            ],
          ),
        );

        return pages;
      },
    ),
  );

  return pdf.save();
}

// Future<Uint8List> _gerarPDF(List<Venda> vendas, DateTime data, List<Despesa> despesas) async {
//   final pdf = pw.Document();

//   double totalVendas = 0.0;
//   double totalPixMaquineta = 0.0;
//   double totalPixConta = 0.0;
//   double totalCartao = 0.0;
//   double totalDinheiro = 0.0;
//   double totalDespesas = despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);

//   vendas.forEach((venda) {
//     totalVendas += venda.valorTotal;

//     if (venda.formaPagamento1.toLowerCase() == 'pix') {
//       if (venda.tipoPixPagamento1 == 'Pix maquineta') {
//         totalPixMaquineta += venda.valorPagamento1;
//       } else if (venda.tipoPixPagamento1 == 'Pix conta') {
//         totalPixConta += venda.valorPagamento1;
//       }
//     } else if (venda.formaPagamento1.toLowerCase() == 'cartão') {
//       totalCartao += venda.valorPagamento1;
//     } else if (venda.formaPagamento1.toLowerCase() == 'dinheiro') {
//       totalDinheiro += venda.valorPagamento1;
//     }

//     if (venda.formaPagamento2 != null) {
//       if (venda.formaPagamento2!.toLowerCase() == 'pix') {
//         if (venda.tipoPixPagamento2 == 'Pix maquineta') {
//           totalPixMaquineta += venda.valorPagamento2!;
//         } else if (venda.tipoPixPagamento2 == 'Pix conta') {
//           totalPixConta += venda.valorPagamento2!;
//         }
//       } else if (venda.formaPagamento2!.toLowerCase() == 'cartão') {
//         totalCartao += venda.valorPagamento2!;
//       } else if (venda.formaPagamento2!.toLowerCase() == 'dinheiro') {
//         totalDinheiro += venda.valorPagamento2!;
//       }
//     }
//   });

//   double valorFinalAposDespesas = totalVendas - totalDespesas;

//   const int vendasPorPagina = 15;
//   List<List<Venda>> paginasVendas = [];

//   for (int i = 0; i < vendas.length; i += vendasPorPagina) {
//     paginasVendas.add(vendas.sublist(i, i + vendasPorPagina > vendas.length ? vendas.length : i + vendasPorPagina));
//   }

//   pdf.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
//       margin: pw.EdgeInsets.all(4),
//       build: (pw.Context context) {
//         List<pw.Widget> pages = [];

//         bool isFirstPage = true;

//         paginasVendas.forEach((paginaVendas) {
//           pages.add(
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 if (isFirstPage)
//                   pw.Text(
//                     'Histórico de Vendas - ${DateFormat('dd/MM/yyyy').format(data)}',
//                     style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
//                   ),
//                 pw.SizedBox(height: 4),
//                 pw.Table.fromTextArray(
//                   headers: [
//                     'Produto', 'Qtd', 'Unit', 'Desc', 'Pagamento', 'Subtotal', 'Total'
//                   ],
//                   headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
//                   cellStyle: pw.TextStyle(fontSize: 6),
//                   data: paginaVendas.map((venda) {
//                     String produtos = venda.itens.map((item) => item.produto).join(', ');
//                     String quantidades = venda.itens.map((item) => item.quantidade.toString()).join(', ');
//                     String valoresUnitarios = venda.itens.map((item) => 'R\$ ${item.valorUnidade.toStringAsFixed(2)}').join(', ');
//                     String subtotais = venda.itens.map((item) => 'R\$ ${(item.quantidade * item.valorUnidade).toStringAsFixed(2)}').join(', ');

//                     String descricaoPagamento1 = _descricaoPagamento(venda.formaPagamento1, venda.valorPagamento1, venda.tipoPixPagamento1);
//                     String descricaoPagamento2 = venda.formaPagamento2 != null 
//                       ? _descricaoPagamento(venda.formaPagamento2!, venda.valorPagamento2!, venda.tipoPixPagamento2)
//                       : '';

//                     return [
//                       produtos,
//                       quantidades,
//                       valoresUnitarios,
//                       venda.desconto > 0 ? 'R\$ ${venda.desconto.toStringAsFixed(2)}' : 'Sem Desconto',
//                       descricaoPagamento1 + (descricaoPagamento2.isNotEmpty ? ' + ' + descricaoPagamento2 : ''),
//                       subtotais,
//                       'R\$ ${venda.valorTotal.toStringAsFixed(2)}',
//                     ];
//                   }).toList(),
//                   columnWidths: {
//                     0: pw.FlexColumnWidth(2.5),
//                     1: pw.FlexColumnWidth(1.0),
//                     2: pw.FlexColumnWidth(2.5),
//                     3: pw.FlexColumnWidth(1.5),
//                     4: pw.FlexColumnWidth(3.0),
//                     5: pw.FlexColumnWidth(2.5),
//                     6: pw.FlexColumnWidth(2.5),
//                   },
//                   cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                   headerDecoration: pw.BoxDecoration(
//                     borderRadius: pw.BorderRadius.circular(2),
//                     color: PdfColors.grey300,
//                   ),
//                 ),
//                 pw.SizedBox(height: 8),
//               ],
//             ),
//           );
//           isFirstPage = false;
//         });

//         pages.add(
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Despesas do dia:',
//                 style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Table.fromTextArray(
//                 headers: ['Descrição', 'Valor (R\$)'],
//                 headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
//                 cellStyle: pw.TextStyle(fontSize: 6),
//                 data: [
//                   ...despesas.map((despesa) => [
//                     despesa.descricao,
//                     'R\$ ${despesa.valor.toStringAsFixed(2)}',
//                   ]).toList(),
//                   ['Total de Despesas', 'R\$ ${totalDespesas.toStringAsFixed(2)}'],
//                 ],
//                 cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//               ),
//               pw.SizedBox(height: 6),
//             ],
//           ),
//         );

//         pages.add(
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Totais por forma de pagamento:',
//                 style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Table.fromTextArray(
//                 headers: ['Forma de Pagamento', 'Total (R\$)'],
//                 headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
//                 cellStyle: pw.TextStyle(fontSize: 6),
//                 data: [
//                   ['Pix Maquineta', 'R\$ ${totalPixMaquineta.toStringAsFixed(2)}'],
//                   ['Pix Conta', 'R\$ ${totalPixConta.toStringAsFixed(2)}'],
//                   ['Cartão', 'R\$ ${totalCartao.toStringAsFixed(2)}'],
//                   ['Dinheiro', 'R\$ ${totalDinheiro.toStringAsFixed(2)}'],
//                 ],
//                 cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//               ),
//               pw.SizedBox(height: 10),
//             ],
//           ),
//         );

//         pages.add(
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Resumo Financeiro:',
//                 style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Table.fromTextArray(
//                 headers: ['Descrição', 'Valor (R\$)'],
//                 headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
//                 cellStyle: pw.TextStyle(fontSize: 6),
//                 data: [
//                   ['Total de Vendas', 'R\$ ${totalVendas.toStringAsFixed(2)}'],
//                   ['Total de Despesas', 'R\$ ${totalDespesas.toStringAsFixed(2)}'],
//                   ['Valor Final Após Despesas', 'R\$ ${valorFinalAposDespesas.toStringAsFixed(2)}'],
//                 ],
//                 cellPadding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//               ),
//               pw.SizedBox(height: 10),
//             ],
//           ),
//         );

//         return pages;
//       },
//     ),
//   );

//   return pdf.save();
// }




// Função que retorna a descrição detalhada do pagamento, incluindo o tipo de Pix, se houver
String _descricaoPagamento(String formaPagamento, double valorPagamento, String? tipoPix) {
  if (formaPagamento.toLowerCase() == 'pix') {
    return tipoPix != null ? '$tipoPix (R\$ ${valorPagamento.toStringAsFixed(2)})' : '(R\$ ${valorPagamento.toStringAsFixed(2)})';
  } else if (formaPagamento.toLowerCase() == 'cartão') {
    return 'Cartão (R\$ ${valorPagamento.toStringAsFixed(2)})';
  } else if (formaPagamento.toLowerCase() == 'dinheiro') {
    return 'Dinheiro (R\$ ${valorPagamento.toStringAsFixed(2)})';
  } else {
    return 'Pagamento (R\$ ${valorPagamento.toStringAsFixed(2)})';
  }
}





// Função que exibe um DatePicker para o usuário escolher a data
Future<DateTime?> _selecionarData(BuildContext context) async {
  DateTime? dataEscolhida = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    helpText: 'Selecione a Data',
    cancelText: 'Cancelar',
    confirmText: 'Confirmar',
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.green, // Cor principal (borda do botão, texto, etc.)
          colorScheme: ColorScheme.light(
            primary: Colors.green, // Cor do cabeçalho e da seleção da data
            onPrimary: Colors.white, // Cor do texto no cabeçalho
            onSurface: Colors.green[900]!, // Use ! para garantir que não seja nulo
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary, // Texto do botão "Confirmar"
          ),
        ),
        child: child!,
      );
    },
  );
  return dataEscolhida;
}


  void _confirmarExclusao(BuildContext context, String vendaId) {
    bool _isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController passwordController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirmação de Exclusão'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Insira a senha de administrador para confirmar a exclusão:'),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.green[900],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (passwordController.text == adminPassword) {
                      _excluirVenda(vendaId, context);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Senha incorreta'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Confirmar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _excluirVenda(String vendaId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Vendas').doc(vendaId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venda excluída com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir venda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Vendas'),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.green[900]),
            onPressed: () => _imprimirHistoricoPorData(context),
          ),
       IconButton(
  icon: Icon(Icons.calendar_month, color: Colors.green[900]),
  onPressed: () => _gerarTabelaVendasPorMes(context), // Chama a função para gerar o PDF
),

        ],
      ),
      body: StreamBuilder<List<Venda>>(
        stream: _carregarHistoricoVendas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico de vendas'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma venda encontrada'));
          }

          List<Venda> vendas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: vendas.length,
            itemBuilder: (context, index) {
                if (index >= vendas.length) return null;
    Venda venda = vendas[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/fundoCard.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Data da Venda: ${DateFormat('dd/MM/yyyy HH:mm').format(venda.dataVenda)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmarExclusao(context, venda.id),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: venda.itens.length,
                            itemBuilder: (context, itemIndex) {
                              VendaItem item = venda.itens[itemIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.produto,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                          ),
                                          Text(
                                            'Quantidade: ${item.quantidade}, Valor: R\$ ${item.valorUnidade.toStringAsFixed(2)}',
                                            style: TextStyle(color: Colors.grey[300]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Subtotal: R\$ ${(item.quantidade * item.valorUnidade).toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[300]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(color: Colors.white),
                          Text(
                            'Vendedor: ${venda.nomeVendedor}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[300]),
                          ),
                          if (venda.desconto > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Desconto: R\$ ${venda.desconto.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[300]),
                                ),
                                Text(
                                  'Desconto em porcentagem: ${(venda.desconto / (venda.valorTotal + venda.desconto) * 100).toStringAsFixed(2)}%',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[300]),
                                ),
                              ],
                            ),
                          Text(
                            'Valor Total: R\$ ${venda.valorTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[300]),
                          ),
                       Text(
  venda.formaPagamento2 != null
      ? 'Forma de Pagamento: ${venda.formaPagamento1}: R\$ ${venda.valorPagamento1.toStringAsFixed(2)}'
        '${venda.formaPagamento1 == 'Pix' && venda.tipoPixPagamento1 != null ? ' ( ${venda.tipoPixPagamento1})' : ''} '
        'e ${venda.formaPagamento2}: R\$ ${venda.valorPagamento2!.toStringAsFixed(2)}'
        '${venda.formaPagamento2 == 'Pix' && venda.tipoPixPagamento2 != null ? ' (${venda.tipoPixPagamento2})' : ''}'
      : 'Forma de Pagamento: ${venda.formaPagamento1}: R\$ ${venda.valorPagamento1.toStringAsFixed(2)}'
        '${venda.formaPagamento1 == 'Pix' && venda.tipoPixPagamento1 != null ? ' ( ${venda.tipoPixPagamento1})' : ''}',
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[300]),
),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

////
///
///
///
