import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:distribuidora_bomfim/classVenda.dart';

class NotaVendaPage extends StatelessWidget {
  final Venda venda;

  NotaVendaPage({required this.venda});

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final pageFormat = PdfPageFormat(
      75 * PdfPageFormat.mm,
      330 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Distribuidora Bomfim',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '*Documento sem valor fiscal*',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Data: ${_formatDate(venda.dataVenda)}',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Hora: ${_formatTime(venda.dataVenda)}',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  venda.formaPagamento2 != null
                      ? 'Forma de Pagamento: ${venda.formaPagamento1} e ${venda.formaPagamento2}'
                      : 'Forma de Pagamento: ${venda.formaPagamento1}',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '${venda.formaPagamento1}: R\$ ${venda.valorPagamento1.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                if (venda.formaPagamento2 != null)
                  pw.Text(
                    '${venda.formaPagamento2}: R\$ ${venda.valorPagamento2?.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.Divider(),
                pw.Text(
                  'Itens Vendidos:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                ...venda.itens.map((item) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          item.produto,
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Quantidade: ${item.quantidade}',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Valor Unidade: R\$ ${item.valorUnidade.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Subtotal: R\$ ${(item.quantidade * item.valorUnidade).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Divider(),
                      ],
                    )),
                pw.Divider(),
                if (venda.desconto > 0) // Só mostra o desconto se for maior que zero
                  pw.Text(
                    'Desconto: R\$ ${venda.desconto.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Valor Total: R\$ ${venda.valorTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Obrigado pela preferência!',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  void _printPdf() async {
    try {
      final pdfBytes = await _generatePdf(PdfPageFormat.a4);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      print("Erro ao tentar imprimir: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota de Venda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Distribuidora Bomfim',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Documento sem valor fiscal',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Data: ${_formatDate(venda.dataVenda)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              'Hora: ${_formatTime(venda.dataVenda)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              venda.formaPagamento2 != null
                  ? 'Forma de Pagamento: ${venda.formaPagamento1} e ${venda.formaPagamento2}'
                  : 'Forma de Pagamento: ${venda.formaPagamento1}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${venda.formaPagamento1}: R\$ ${venda.valorPagamento1.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            if (venda.formaPagamento2 != null)
              Text(
                '${venda.formaPagamento2}: R\$ ${venda.valorPagamento2?.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            Divider(thickness: 2),
            Text(
              'Itens Vendidos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: venda.itens.length,
                itemBuilder: (context, index) {
                  final item = venda.itens[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.produto,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Quantidade: ${item.quantidade}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Valor Unidade: R\$ ${item.valorUnidade.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Subtotal: R\$ ${(item.quantidade * item.valorUnidade).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            if (venda.desconto > 0) // Só mostra o desconto se for maior que zero
              Text(
                'Desconto: R\$ ${venda.desconto.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            Text(
              'Valor Total: R\$ ${venda.valorTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Obrigado pela preferência!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 10),
          Center(
  child: ElevatedButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmação'),
            content: Text('Tem certeza que deseja imprimir a nota?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,       // Texto branco
                ),
                child: Text('Não'),
              ),
              TextButton(
                onPressed: () {
                  _printPdf(); // Aciona a impressão do PDF
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[900],         // Texto branco
                ),
                child: Text('Sim'),
              ),
            ],
          );
        },
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green[900], // Cor do botão
      foregroundColor: Colors.white,      // Cor do texto
    ),
    child: Text('Imprimir Nota'),
  ),
)

          ],
        ),
      ),
    );
  }
}
