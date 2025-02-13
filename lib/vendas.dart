import 'package:distribuidora_bomfim/ClassVendaItem.dart';
import 'package:distribuidora_bomfim/authentic.dart';
import 'package:distribuidora_bomfim/classEstoque.dart';
import 'package:distribuidora_bomfim/classVenda.dart';
import 'package:distribuidora_bomfim/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VendaPage extends StatefulWidget {
  @override
  _VendaPageState createState() => _VendaPageState();
}

class _VendaPageState extends State<VendaPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  String? produtoSelecionado;
  String? categoriaSelecionada;
  int quantidadeVendida = 0;
  double valorUnidade = 0.0;
  double desconto = 0.0;
  String nomeVendedor = '';
  List<VendaItem> carrinho = [];
  List<EstoqueItem> produtosEstoque = [];
  String? formaPagamento;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  TextEditingController _searchController = TextEditingController();
  bool _obscureText = true;

  TextEditingController _descontoController = TextEditingController();

  String? formaPagamento1;
String? formaPagamento2;
  String? tipoPixPagamento1; // Adicione esta variável para o tipo de Pix do primeiro pagamento
  String? tipoPixPagamento2; // Adicione esta variável para o tipo de Pix do segundo pagamento


double valorPagamento1 = 0.0;
double valorPagamento2 = 0.0;

TextEditingController _valorPagamento1Controller = TextEditingController();
TextEditingController _valorPagamento2Controller = TextEditingController();
 String? compradorSelecionado; // Variável para armazenar o comprador selecionado
  final List<String> compradores = ['Casa do Criador', 'Orlando', 'Odorico', 'Ricardo']; // Lista de compradores




  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _speech = stt.SpeechToText();
      _carregarStatusDesconto(); // Carrega o status do desconto ao iniciar
  }


// Adiciona a variável para armazenar o status persistente
String? _statusDesconto;
final String adminPassword = 'admin123'; // Defina a senha do administrador
bool _isDescontoEnabled = false;
String? _selectedOption = 'Recusar'; // Valor inicial do botão multiescolha


// Função para salvar o status no Firestore
  Future<void> _salvarStatusDesconto(String status) async {
    await FirebaseFirestore.instance.collection('statusDesconto').doc('status').set({
      'status': status,
    });
  }

// Função para carregar o status do Firestore em tempo real e habilitar/desabilitar o campo de desconto
// Future<void> _carregarStatusDesconto() async {
//   FirebaseFirestore.instance
//       .collection('statusDesconto')
//       .doc('status')
//       .snapshots()
//       .listen((snapshot) {
//     if (snapshot.exists) {
//       String status = snapshot.data()?['status'];
//       setState(() {
//         _statusDesconto = status;
//         _isDescontoEnabled = status == 'Aprovar'; // Habilita o campo de desconto se "Aprovar"
//       });
//     }
//   });
// }


Future<void> _verificarSenha() async {
  final TextEditingController passwordController = TextEditingController();
  bool _obscureTextDialog = true; // Controla a exibição da senha no diálogo

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Digite a senha de administrador'),
            content: TextFormField(
              controller: passwordController,
              obscureText: _obscureTextDialog, // Controla se a senha é visível ou não
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureTextDialog ? Icons.visibility_off : Icons.visibility,
                    color: Colors.green[900],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextDialog = !_obscureTextDialog; // Alterna entre esconder e mostrar a senha
                    });
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (passwordController.text == adminPassword) {
                    // Se a senha estiver correta, libera o campo de desconto
                    setState(() {
                      _isDescontoEnabled = true; // Libera o desconto localmente
                      _salvarStatusDesconto('Autorizar'); // Salva o status de "Autorizar" para todos os usuários
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Desconto autorizado para todos os usuários'),
                        backgroundColor: Colors.green[900],
                      ),
                    );
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
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


void _carregarStatusDesconto() {
  FirebaseFirestore.instance
      .collection('statusDesconto')
      .doc('status')
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists) {
      String status = snapshot.data()?['status'] ?? 'Recusar';
      setState(() {
        _isDescontoEnabled = status == 'Autorizar'; // Habilita o campo de desconto para todos os usuários se autorizado
      });
    }
  });
}


// Função para verificar o status de aprovação e verificar a senha
void _verificarStatusDesconto(String? status) {
  if (status == 'Aprovar') {
    _verificarSenha(); // Chama a função para abrir o diálogo de senha se tentar aprovar
  } else {
    setState(() {
      _isDescontoEnabled = false; // Bloqueia o campo de desconto
      _salvarStatusDesconto('Recusar'); // Salva o status de "Recusar"
    });
  }
}





  Future<void> _carregarProdutos() async {
    FirebaseFirestore.instance.collection('Estoque').snapshots().listen((snapshot) {
      List<EstoqueItem> produtos = snapshot.docs.map((doc) {
        return EstoqueItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        produtosEstoque = produtos;
      });
    });
  }

  void _adicionarAoCarrinho() {
    EstoqueItem? itemEstoque = produtosEstoque.firstWhere(
        (item) => item.produto == produtoSelecionado,
        orElse: () => EstoqueItem(
            id: '',
            produto: '',
            categoria: '',
            quantidadeEntrada: 0,
            quantidadeSaida: 0,
            quantidadeRestante: 0,
            valorUnidade: 0.0,
            valorTotal: 0.0,));
    if (itemEstoque.id.isNotEmpty &&
        quantidadeVendida <= itemEstoque.quantidadeRestante) {
      setState(() {
        carrinho.add(VendaItem(
            produto: produtoSelecionado!,
            quantidade: quantidadeVendida,
            valorUnidade: itemEstoque.valorUnidade));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quantidade inválida ou produto não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

Future<void> _venderProdutos() async {

  
  // Verifica se pelo menos uma forma de pagamento foi selecionada
  if (formaPagamento1 == null && formaPagamento2 == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor, selecione pelo menos uma forma de pagamento'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (carrinho.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('O carrinho está vazio. Adicione produtos ao carrinho antes de vender.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Verifica se o desconto é maior que 5% e a senha não foi validada
  if (desconto > 0.05 && !_isDescontoEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('O desconto é maior que 5%. Insira a senha de administrador para continuar.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Calcular o valor total da venda
  double valorTotalVenda = carrinho.fold(
    0, (total, item) => total + (item.quantidade * item.valorUnidade));

  // Aplicar o desconto corretamente em porcentagem
  double valorDesconto = valorTotalVenda * desconto; // valor do desconto em reais
  double valorFinalComDesconto = valorTotalVenda - valorDesconto; // valor final com o desconto

  // Arredondando os valores para garantir precisão
  valorDesconto = double.parse(valorDesconto.toStringAsFixed(2));
  valorFinalComDesconto = double.parse(valorFinalComDesconto.toStringAsFixed(2));

  // Se apenas uma forma de pagamento for selecionada, o valor total da venda será pago por essa forma
  if (formaPagamento2 == null) {
    valorPagamento1 = valorFinalComDesconto; // Atribui o valor total ao primeiro método
    valorPagamento2 = 0.0;
  }

  // Somar os dois valores de pagamento (se a forma de pagamento 2 estiver selecionada)
  double valorTotalPagamento = valorPagamento1 + (formaPagamento2 != null ? valorPagamento2 : 0.0);

  // Verifica se o valor pago cobre o valor da venda
  if (valorTotalPagamento < valorFinalComDesconto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('O valor pago é menor que o valor total da venda'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Verifica se o valor pago excede o valor total da venda
  if (valorTotalPagamento > valorFinalComDesconto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('O valor pago excede o valor total da venda!'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Criar o objeto Venda
  DateTime dataVenda = DateTime.now();
  String formaPagamentoFinal = formaPagamento2 == null
      ? formaPagamento1! // Se houver apenas uma forma de pagamento
      : '$formaPagamento1 e $formaPagamento2'; // Se houver duas formas de pagamento

  // Inicializa o objeto Venda com os valores já calculados
Venda venda = Venda(
  itens: List.from(carrinho),
  valorTotal: valorFinalComDesconto,
  desconto: valorDesconto,  // Agora o desconto está em reais
  dataVenda: dataVenda,
  nomeVendedor: nomeVendedor,
  formaPagamento1: formaPagamento1!, // Add formaPagamento1 (required)
  formaPagamento2: formaPagamento2, // Optional second payment method
  valorPagamento1: valorPagamento1, // First payment value
  valorPagamento2: formaPagamento2 != null ? valorPagamento2 : null, // Optional second payment value
  tipoPixPagamento1: formaPagamento1 == 'Pix' ? tipoPixPagamento1 : null, // Tipo de Pix para forma de pagamento 1
  tipoPixPagamento2: formaPagamento2 == 'Pix' ? tipoPixPagamento2 : null, // Tipo de Pix para forma de pagamento 2 (se houver)
);


  // Registrar a venda
  await authService.registrarVenda(venda);

  // Atualizar o estoque
  for (VendaItem item in carrinho) {
    EstoqueItem? itemEstoque = produtosEstoque.firstWhere(
        (e) => e.produto == item.produto,
        orElse: () => EstoqueItem(
            id: '',
            produto: '',
            categoria: '',
            quantidadeEntrada: 0,
            quantidadeSaida: 0,
            quantidadeRestante: 0,
            valorUnidade: 0.0,
            valorTotal: 0.0));
    if (itemEstoque.id.isNotEmpty) {
      itemEstoque.quantidadeRestante -= item.quantidade;
      await authService.updateStock(itemEstoque);
    }
  }

  // Limpar o carrinho e resetar os campos de pagamento e desconto
  setState(() {
    carrinho.clear();
    desconto = 0.0;
    _valorPagamento1Controller.clear();
    _valorPagamento2Controller.clear();
    formaPagamento1 = null;
    formaPagamento2 = null;

    _isDescontoEnabled = false; 
  });
    await _salvarStatusDesconto('Recusar');

  // Exibir a nota de venda
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return NotaVendaPage(venda: venda);
    },
  );
}



  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Microfone ativado, fale algo...'),
              backgroundColor: Colors.green[900],
            ),
          );
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _filterProducts(_searchController.text);
          }),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconhecimento de fala não disponível'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microfone desativado'),
            backgroundColor: Colors.red,
          ),
        );
      });
      _speech.stop();
    }
  }

  void _filterProducts(String query) {
    setState(() {
      EstoqueItem? selectedProduct = produtosEstoque.firstWhere(
        (item) => item.produto.toLowerCase().contains(query.toLowerCase()),
        orElse: () => EstoqueItem(
          id: '',
          produto: '',
          quantidadeEntrada: 0,
          quantidadeSaida: 0,
          quantidadeRestante: 0,
          valorUnidade: 0.0,
          valorTotal: 0.0,
          categoria: '',
        ),
      );

      produtoSelecionado = selectedProduct.produto;
      categoriaSelecionada = selectedProduct.categoria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vender Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.green[100],
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 250, vertical: 50),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Autocomplete<EstoqueItem>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<EstoqueItem>.empty();
                              }
                              return produtosEstoque.where((EstoqueItem item) {
                                return item.produto.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (EstoqueItem option) => option.produto,
                            onSelected: (EstoqueItem selection) {
                              setState(() {
                                produtoSelecionado = selection.produto;
                                valorUnidade = selection.valorUnidade;
                                categoriaSelecionada = selection.categoria;
                              });
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<EstoqueItem> onSelected,
                                Iterable<EstoqueItem> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  child: Container(
                                    width: 400,
                                    color: Colors.white,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final EstoqueItem option = options.elementAt(index);
                                        return ListTile(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                option.categoria,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.green[900],
                                                ),
                                              ),
                                              Text(option.produto),
                                            ],
                                          ),
                                          leading: option.imagemUrl != null && option.imagemUrl!.isNotEmpty
                                              ? Image.network(
                                                  option.imagemUrl!,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.inventory, size: 40, color: Colors.green[900]),
                                          subtitle: Text('R\$ ${option.valorUnidade.toStringAsFixed(2)}'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              _searchController = fieldTextEditingController;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (categoriaSelecionada != null && categoriaSelecionada!.isNotEmpty)
                                    Text(
                                      'Categoria: $categoriaSelecionada',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                  TextFormField(
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Pesquisar Produto',
                                      labelStyle: TextStyle(color: Colors.red),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: IconButton(
                                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                                        onPressed: _listen,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 400,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome do Vendedor',
                          labelStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            nomeVendedor = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do vendedor';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 400,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Quantidade Vendida',
                          labelStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          setState(() {
                            quantidadeVendida = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),

Row(
  children: [
    // Campo de desconto que permite a entrada de valores decimais como 0.5
Flexible(
  child: SizedBox(
    width: 200, // Define a largura desejada do campo de desconto
    child: TextFormField(
  controller: _descontoController,
  decoration: InputDecoration(
    labelText: 'Desconto (%)',
    labelStyle: TextStyle(color: Colors.red),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    filled: true,
    fillColor: Colors.white,
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Permite até 2 casas decimais
  ],
  onChanged: (value) {
    setState(() {
      desconto = (double.tryParse(value) ?? 0.0) / 100;

      // Verifica se o desconto é maior que 5%
      if (desconto > 0.05) {
        _verificarSenha(); // Abre o diálogo para inserir senha
        _isDescontoEnabled = false; // Desabilita o desconto até a senha ser validada
      } else {
        _isDescontoEnabled = true; // Desconto abaixo de 5% é permitido
      }
    });
  },
),

  ),
),


  

    SizedBox(width: 16), // Espaço entre o campo e o botão de multiescolha
 Flexible(
  child: SizedBox(
    width: 150,
    child: DropdownButtonFormField<String>(
      value: _selectedOption,
      decoration: InputDecoration(
        labelText: 'Autorizar Desconto',
        labelStyle: TextStyle(color: Colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.green[900]),
      style: TextStyle(color: Colors.black, fontSize: 16),
      dropdownColor: Colors.green[50],
      items: <String>['Autorizar', 'Recusar'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue;
          if (_selectedOption == 'Autorizar') {
            _verificarSenha(); // Solicita a senha para autorizar o desconto
          }
        });
      },
    ),
  ),
),


     if (desconto > 0)
                      Text(
                        '    Desconto aplicado: ${(desconto * 100).toStringAsFixed(2)}%', // Exibe o desconto em porcentagem
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red[300],
                        ),
                      ),     SizedBox(width: 16), // Espaço entre o campo de status e o campo de compradores

                        // Botão de múltipla escolha de comprador
              
                      
  ],
),


                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _adicionarAoCarrinho,
                        icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                        label: Text('Adicionar ao Carrinho', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[900],
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: carrinho.length,
                      itemBuilder: (context, index) {
                        VendaItem item = carrinho[index];

                        // Procura o item no estoque para obter a URL da imagem
                        EstoqueItem? itemEstoque = produtosEstoque.firstWhere(
                          (e) => e.produto == item.produto,
                          orElse: () => EstoqueItem(
                            id: '',
                            produto: '',
                            quantidadeEntrada: 0,
                            quantidadeSaida: 0,
                            quantidadeRestante: 0,
                            valorUnidade: 0.0,
                            valorTotal: 0.0,
                            imagemUrl: '',
                            categoria: '',
                          ),
                        );

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
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  leading: itemEstoque.imagemUrl != null && itemEstoque.imagemUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          itemEstoque.imagemUrl!,
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                        ),
                                      )
                                    : Icon(
                                        Icons.inventory,
                                        size: 40,
                                        color: Colors.green[900],
                                      ),
                                  title: Text(
                                    item.produto,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Quantidade: ${item.quantidade}, Valor Unidade: R\$ ${item.valorUnidade.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        carrinho.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          
                          Text(
                            'Formas de Pagamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                    
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
   Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Forma de Pagamento 1',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green[900],
        fontSize: 16,
      ),
    ),
    SizedBox(height: 8),
    Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: formaPagamento1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              labelText: 'Selecione o método',
              labelStyle: TextStyle(color: Colors.green[900]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.white, // Fundo branco
            ),
            items: <String>['Dinheiro', 'Pix', 'Cartão'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                formaPagamento1 = newValue;
              });
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
  child: TextFormField(
    controller: _valorPagamento1Controller,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      labelText: 'Valor 1',
      labelStyle: TextStyle(color: Colors.green[900]),
      prefixText: 'R\$ ',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white, // Fundo branco
    ),
    keyboardType: TextInputType.number,
    onChanged: (value) {
      setState(() {
        valorPagamento1 = double.tryParse(value) ?? 0.0;
      });
    },
  ),
),

      ],
    ),
    SizedBox(height: 24), // Espaço maior entre os métodos de pagamento
    Text(
      'Forma de Pagamento 2',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green[900],
        fontSize: 16,
      ),
    ),
    SizedBox(height: 8),
    Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: formaPagamento2,
            
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              labelText: 'Selecione o método',
              labelStyle: TextStyle(color: Colors.green[900]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.white, // Fundo branco
            ),
            items: <String>['Dinheiro', 'Pix', 'Cartão'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                formaPagamento2 = newValue;
              });
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _valorPagamento2Controller,
            enabled: formaPagamento2 != null, 
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              labelText: 'Valor 2',
              labelStyle: TextStyle(color: Colors.green[900]),
              prefixText: 'R\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.white, // Fundo branco
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                valorPagamento2 = double.tryParse(value) ?? 0.0;
              });
            },
          ),
        ),
      ],
    ),
  ],
),
// Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Text(
//       'Forma de Pagamento 1',
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         color: Colors.green[900],
//         fontSize: 16,
//       ),
//     ),
//     SizedBox(height: 8),
//     Row(
//       children: [
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: formaPagamento1,
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               labelText: 'Selecione o método',
//               labelStyle: TextStyle(color: Colors.green[900]),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             items: <String>['Dinheiro', 'Pix', 'Cartão'].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 formaPagamento1 = newValue;
//                 if (formaPagamento1 != 'Pix') {
//                   tipoPixPagamento1 = null; // Reseta o tipo de Pix se não for Pix
//                 }
//               });
//             },
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: TextFormField(
//             controller: _valorPagamento1Controller,
//             enabled: formaPagamento1 != null,
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               labelText: 'Valor 1',
//               labelStyle: TextStyle(color: Colors.green[900]),
//               prefixText: 'R\$ ',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               setState(() {
//                 valorPagamento1 = double.tryParse(value) ?? 0.0;
//               });
//             },
//           ),
//         ),
//       ],
//     ),
//     if (formaPagamento1 == 'Pix') // Exibe opção adicional se o pagamento for Pix
//       Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: DropdownButtonFormField<String>(
//           value: tipoPixPagamento1,
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//             labelText: 'Tipo de Pix',
//             labelStyle: TextStyle(color: Colors.green[900]),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           items: <String>['Pix maquineta', 'Pix conta'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               tipoPixPagamento1 = newValue;
//             });
//           },
//         ),
//       ),
//     SizedBox(height: 24),
//     // Repetir estrutura para Forma de Pagamento 2
//     Text(
//       'Forma de Pagamento 2',
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         color: Colors.green[900],
//         fontSize: 16,
//       ),
//     ),
//     SizedBox(height: 8),
//     Row(
//       children: [
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: formaPagamento2,
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               labelText: 'Selecione o método',
//               labelStyle: TextStyle(color: Colors.green[900]),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             items: <String>['Dinheiro', 'Pix', 'Cartão'].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 formaPagamento2 = newValue;
//                 if (formaPagamento2 != 'Pix') {
//                   tipoPixPagamento2 = null;
//                 }
//               });
//             },
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: TextFormField(
//             controller: _valorPagamento2Controller,
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               labelText: 'Valor 2',
//               labelStyle: TextStyle(color: Colors.green[900]),
//               prefixText: 'R\$ ',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//                 borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               setState(() {
//                 valorPagamento2 = double.tryParse(value) ?? 0.0;
//               });
//             },
//           ),
//         ),
//       ],
//     ),
//     if (formaPagamento2 == 'Pix')
//       Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: DropdownButtonFormField<String>(
//           value: tipoPixPagamento2,
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//             labelText: 'Tipo de Pix',
//             labelStyle: TextStyle(color: Colors.green[900]),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           items: <String>['Pix maquineta', 'Pix conta'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               tipoPixPagamento2 = newValue;
//             });
//           },
//         ),
//       ),
//   ],
// ),

SizedBox(height: 20,),

    Center(
  child: ElevatedButton.icon(
    onPressed: () {
      // Calcular o valor total do carrinho
      double valorTotalCarrinho = carrinho.fold(
        0, (total, item) => total + (item.quantidade * item.valorUnidade));

      // Calcular o valor total dos pagamentos inseridos
      double valorTotalPagamento = valorPagamento1 + valorPagamento2;

     // Aplicar o desconto, se houver
      double valorDesconto = desconto > 0 ? valorTotalCarrinho * desconto : 0.0;
      double valorFinalComDesconto = valorTotalCarrinho - valorDesconto;



      // Verificar se os valores são iguais ao valor com desconto ou sem desconto
      if ((desconto > 0 && valorTotalPagamento != valorFinalComDesconto) ||
          (desconto == 0 && valorTotalPagamento != valorTotalCarrinho)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Os valores informados devem ser iguais ao total da venda ${desconto > 0 ? "com desconto" : "sem desconto"}: R\$ ${(desconto > 0 ? valorFinalComDesconto : valorTotalCarrinho).toStringAsFixed(2)}'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Não exibe a caixa de diálogo
      }

      // Exibir caixa de diálogo de confirmação
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmação'),
            content: Text('Tem certeza que deseja realizar a venda?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: Text('Não'),
              ),
              TextButton(
                onPressed: () {
                  // Confirmar a venda
                  _venderProdutos();
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[900],
                ),
                child: Text('Sim'),
              ),
            ],
          );
        },
      );
    },
    icon: Icon(Icons.attach_money, color: Colors.white),
    label: Text('Vender', style: TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red[700],
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
),



                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0,00');
    }

    double value = double.parse(newValue.text.replaceAll(RegExp(r'[^\d]'), ''));
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String newText = formatter.format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}////




