import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart'; // Para formatar e comparar datas

import 'classDespesas.dart';

class FluxoDeCaixaPage extends StatefulWidget {
  @override
  _FluxoDeCaixaPageState createState() => _FluxoDeCaixaPageState();
}

class _FluxoDeCaixaPageState extends State<FluxoDeCaixaPage> {
  final TextEditingController _despesaController = TextEditingController();

  List<Despesa> despesas = [];
  double totalDespesas = 0.0;
  DateTime? _dataSelecionada;
  DateTime? _dataFiltro;
 final MoneyMaskedTextController _valorController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
  @override
  void initState() {
    super.initState();
    _carregarDespesas();
  }

  Future<void> _adicionarDespesa() async {
  String descricao = _despesaController.text;
  double valor = double.tryParse(_valorController.text.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;

  if (descricao.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, insira a descrição da despesa.'), backgroundColor: Colors.red),
    );
    return;
  }

  if (valor <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, insira um valor válido.'), backgroundColor: Colors.red),
    );
    return;
  }

  if (_dataSelecionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, selecione a data da despesa.'), backgroundColor: Colors.red),
    );
    return;
  }

  // Se todos os campos forem preenchidos corretamente
  Despesa novaDespesa = Despesa(
    id: '',
    descricao: descricao,
    valor: valor,
    data: _dataSelecionada!, // Usando a data selecionada
  );

  // Adiciona a nova despesa no Firestore
  await FirebaseFirestore.instance.collection('despesas').add(novaDespesa.toMap());

  // Atualiza o estado local
  setState(() {
    despesas.add(novaDespesa);
    _calcularTotalDespesas();
  });

  // Clear the controllers, ensuring the masked controller is reset correctly
  _despesaController.clear();
  
  // Set the MoneyMaskedTextController value back to 0 safely
  _valorController.updateValue(0.00);
  
  _dataSelecionada = null;
}


Future<void> _excluirDespesa(Despesa despesa) async {
  try {
    if (despesa.id.isNotEmpty) {
      await FirebaseFirestore.instance.collection('despesas').doc(despesa.id).delete();

      // Atualizando a lista local após a exclusão
      setState(() {
        despesas.remove(despesa);
        _calcularTotalDespesas();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Despesa excluída com sucesso!'), backgroundColor: Colors.green[900]),
      );
    } else {
      throw 'ID da despesa não encontrado';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao excluir despesa: $e'), backgroundColor: Colors.red),
    );
  }
}


void _confirmarExclusao(BuildContext context, Despesa despesa) {
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
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
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: Text('Cancelar', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  if (passwordController.text == 'admin123') { // Substitua pela sua senha
                    _excluirDespesa(despesa);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Senha incorreta'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text('Confirmar', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    },
  );
}


  // Abre o DatePicker para selecionar a data
  Future<void> _selecionarData(BuildContext context, {bool filtro = false}) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green[900], // Cor de destaque do DatePicker
            colorScheme: ColorScheme.light(
              primary: Colors.green[900]!, // Cor de destaque do DatePicker
              onSurface: Colors.green[900]!,
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() {
        if (filtro) {
          _dataFiltro = dataSelecionada;
          _filtrarDespesasPorData();
        } else {
          _dataSelecionada = dataSelecionada;
        }
      });
    }
  }

Future<void> _carregarDespesas() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('despesas').get();

  List<Despesa> despesasCarregadas = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Check if 'data' is a Timestamp or String, and handle accordingly
    DateTime date;
    if (data['data'] is Timestamp) {
      // If it is a Timestamp, convert to DateTime
      date = (data['data'] as Timestamp).toDate();
    } else if (data['data'] is String) {
      // If it is a String, parse it into DateTime
      date = DateTime.parse(data['data'] as String);
    } else {
      throw 'Unknown date format';
    }

    return Despesa(
      id: doc.id, // Salva o ID do documento Firestore
      descricao: data['descricao'],
      valor: data['valor'],
      data: date, // Ensure the date is a DateTime object
    );
  }).toList();

  setState(() {
    despesas = despesasCarregadas;
    _calcularTotalDespesas();
  });
}




  // Filtra as despesas pela data selecionada
  Future<void> _filtrarDespesasPorData() async {
    if (_dataFiltro == null) return;

    String dataFormatada = DateFormat('yyyy-MM-dd').format(_dataFiltro!);

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('despesas').get();

    List<Despesa> despesasFiltradas = snapshot.docs
        .map((doc) => Despesa.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((despesa) =>
            DateFormat('yyyy-MM-dd').format(despesa.data) == dataFormatada)
        .toList();

    setState(() {
      despesas = despesasFiltradas;
      _calcularTotalDespesas();
    });
  }

  // Calcula o total das despesas
  void _calcularTotalDespesas() {
    totalDespesas = despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Fluxo de Caixa - Despesas do Dia'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          color: Colors.green[100],
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar Despesa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 20),
                // Campo de texto para a descrição da despesa
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _despesaController,
                        decoration: InputDecoration(
                          labelText: 'Descrição da Despesa',
                          labelStyle: TextStyle(color: Colors.red),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green[900]!,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green[900]!,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                   SizedBox(
      width: 200,
      child: TextField(
        controller: _valorController, // Agora o controller lida com formatação de moeda
        decoration: InputDecoration(
          labelText: 'Valor',
          labelStyle: TextStyle(color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green[900]!,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green[900]!,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true), // Aceitar decimais
      ),
    ),

                  ],
                ),
                SizedBox(height: 20),
                // Campo de seleção da data
                Row(
                  children: [
                    Text(
                      _dataSelecionada == null
                          ? 'Selecione a data'
                          : 'Data selecionada: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _selecionarData(context),
                      icon: Icon(Icons.calendar_today, color: Colors.white,),
                      label: Text('Selecionar Data', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Botão para adicionar despesa
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _adicionarDespesa,
                    icon: Icon(Icons.add, color: Colors.white,),
                    label: Text(
                      'Adicionar Despesa',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900],
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Botão para filtrar por data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dataFiltro == null
                          ? 'Filtrar por data'
                          : 'Data do filtro: ${DateFormat('dd/MM/yyyy').format(_dataFiltro!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selecionarData(context, filtro: true),
                      icon: Icon(Icons.filter_list,color: Colors.white,),
                      label: Text('Filtrar por Data', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Despesas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 10),
                // Lista de despesas filtradas ou carregadas
                Card(
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
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: despesas.length,
                          itemBuilder: (context, index) {
                            final despesa = despesas[index];
                            return ListTile(
  title: Text(
    despesa.descricao,
    style: TextStyle(color: Colors.white, fontSize: 14),
  ),
  subtitle: Text(
    'Data: ${DateFormat('dd/MM/yyyy').format(despesa.data)}',
    style: TextStyle(color: Colors.white70, fontSize: 12),
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'R\$ ${despesa.valor.toStringAsFixed(2)}',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _confirmarExclusao(context, despesa),
      ),
    ],
  ),
);

                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Total de despesas
                Card(
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
                            Text(
                              'Total de Despesas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'R\$ ${totalDespesas.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}
///
///