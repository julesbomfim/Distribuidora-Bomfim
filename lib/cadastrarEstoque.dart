import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; 
import 'package:distribuidora_bomfim/authentic.dart';
import 'package:distribuidora_bomfim/classEstoque.dart';

class EstoquePage extends StatefulWidget {
  @override
  _EstoquePageState createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _quantidadeEntradaController = TextEditingController();
  final TextEditingController _valorUnidadeController = TextEditingController();
  final TextEditingController _valorTotalController = TextEditingController();
  final TextEditingController _produtoController = TextEditingController();
  final String adminPassword = 'admin123'; 
  String produto = '';
  int quantidadeEntrada = 0;
  int quantidadeSaida = 0;
  int quantidadeRestante = 0;
  double valorUnidade = 0.0;
  double valorTotal = 0.0;
  String? imageUrl;
  String? categoriaSelecionada; // Categoria selecionada
  bool isUploadingImage = false; 
  Uint8List? imageBytes; 
  bool _isPasswordVisible = false; // Variável para controlar a visibilidade da senha


  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Função para calcular o valor total
  void _calcularValores() {
    setState(() {
      String cleanedValue = _valorUnidadeController.text.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.');
      valorUnidade = double.tryParse(cleanedValue) ?? 0.0;
      valorTotal = quantidadeEntrada * valorUnidade;
      _valorTotalController.text = _formatCurrency(valorTotal);
    });
  }

  String _formatCurrency(double value) {
    final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return format.format(value);
  }

  Future<void> _salvarDados() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != adminPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senha inválida!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Estoque')
            .where('produto', isEqualTo: produto)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produto já cadastrado!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        EstoqueItem item = EstoqueItem(
          produto: produto,
          quantidadeEntrada: quantidadeEntrada,
          quantidadeSaida: quantidadeSaida,
          quantidadeRestante: quantidadeEntrada,
          valorUnidade: valorUnidade,
          valorTotal: valorTotal,
          imagemUrl: imageUrl ?? '',
          categoria: categoriaSelecionada ?? '',
        );

        await authService.addUser(item);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green[900],
          ),
        );

        _formKey.currentState?.reset();
        _passwordController.clear();
        _quantidadeEntradaController.clear();
        _valorUnidadeController.clear();
        _valorTotalController.clear();
        _produtoController.clear();

        setState(() {
          produto = '';
          quantidadeEntrada = 0;
          quantidadeSaida = 0;
          quantidadeRestante = 0;
          valorUnidade = 0.0;
          valorTotal = 0.0;
          imageUrl = null;
          categoriaSelecionada = null; // Limpa a categoria selecionada
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          imageUrl = reader.result as String?;
        });
      });
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Status: $val'),
        onError: (val) => print('Error: $val'),
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
            _produtoController.text = val.recognizedWords.toUpperCase();
            produto = _produtoController.text;
          }),
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

  // Função para verificar se a URL da imagem é válida
  bool _isValidUrl(String? url) {
    return url != null && url.isNotEmpty;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _quantidadeEntradaController.dispose();
    _valorUnidadeController.dispose();
    _valorTotalController.dispose();
    _produtoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
  controller: _produtoController,
  decoration: InputDecoration(
    labelText: 'Produto',
    labelStyle: TextStyle(color: Colors.red),
    suffixIcon: IconButton(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      color: Colors.green[900],
      onPressed: _listen,
    ),
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
  // Adiciona TextCapitalization para garantir que todas as letras sejam maiúsculas
  textCapitalization: TextCapitalization.characters,
  onChanged: (value) {
    setState(() {
      produto = value.toUpperCase(); // Garante que o valor seja convertido para maiúsculas
      _produtoController.value = TextEditingValue(
        text: produto,
        selection: TextSelection.collapsed(offset: produto.length),
      );
    });
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o nome do produto';
    }
    return null;
  },
),

                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Categoria',
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
                      value: categoriaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          categoriaSelecionada = value;
                        });
                      },
                      items: [
                        'Rações e Núcleos Bovinos',
                        'Rações e Núcleos Suínos',
                        'Rações e Suplementos Equinos',
                        'Rações e sal mineral caprino e ovino',
                        'Rações de Cachorro',
                        'Rações de Gato',
                        'Rações de peixe',
                        'Feno',
                        'Rações de Pássaros',
                        'Rações de Aves',
                        'Bebidas',
                        'Arames Grampos',
                      ].map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image, color: Colors.green[900]),
                      label: Text('Selecionar Imagem', style: TextStyle(color: Colors.green[900])),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                    if (_isValidUrl(imageUrl))
                      Image.network(
                        imageUrl!,
                        height: 100,
                        width: 100,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Icon(Icons.error, size: 100, color: Colors.red);
                        },
                      )
                    else
                      Icon(Icons.image, size: 100, color: Colors.green[900]),
                    if (isUploadingImage) CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Container(
                      width: 400,
                      child: TextFormField(
                        controller: _quantidadeEntradaController,
                        decoration: InputDecoration(
                          labelText: 'Quantidade de Entrada',
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
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            quantidadeEntrada = int.tryParse(value) ?? 0;
                            _calcularValores();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a quantidade de entrada';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 400,
                      child: TextFormField(
                        controller: _valorUnidadeController,
                        decoration: InputDecoration(
                          labelText: 'Valor Unidade (R\$)',
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
                          CurrencyInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            valorUnidade = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                            _calcularValores();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor unitário';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 400,
                      child: TextFormField(
                        controller: _valorTotalController,
                        decoration: InputDecoration(
                          labelText: 'Valor Total (R\$)',
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
                          fillColor: Colors.grey[200],
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
  width: 400,
  child: TextFormField(
    controller: _passwordController,
    decoration: InputDecoration(
      labelText: 'Senha de Admin',
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
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.green[900],
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible; // Alterna a visibilidade
          });
        },
      ),
    ),
    obscureText: !_isPasswordVisible, // Controla se a senha está visível ou não
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Por favor, insira a senha do administrador';
      }
      return null;
    },
  ),
),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _salvarDados,
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Cadastrar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
}
//
