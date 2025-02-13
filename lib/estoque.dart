import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'classEstoque.dart';

class ListarProdutosPage extends StatefulWidget {
  @override
  _ListarProdutosPageState createState() => _ListarProdutosPageState();
}

class _ListarProdutosPageState extends State<ListarProdutosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<List<EstoqueItem>> _carregarProdutos() {
    return _firestore.collection('Estoque').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EstoqueItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase(); // Atualiza a query de busca
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

Future<void> _deletarProduto(EstoqueItem produto) async {
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Excluir Produto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Insira a senha de administrador para confirmar a exclusão:'),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha de Admin',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.green[900]),
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
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(backgroundColor: Colors.red),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text == 'admin123') {
                    await _firestore.collection('Estoque').doc(produto.id).delete(); // Exclui o produto do Firestore
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produto excluído com sucesso'), backgroundColor: Colors.green[900]),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Senha inválida!'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text('Excluir', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
              ),
            ],
          );
        },
      );
    },
  );
}



  Future<void> _editarProduto(EstoqueItem produto) async {
    TextEditingController nomeProdutoController = TextEditingController(text: produto.produto);
    TextEditingController quantidadeController = TextEditingController(text: produto.quantidadeRestante.toString());
    TextEditingController valorUnidadeController = TextEditingController(text: produto.valorUnidade.toStringAsFixed(2));
    TextEditingController passwordController = TextEditingController();
    bool _isPasswordVisible = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Produto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeProdutoController,
                    decoration: InputDecoration(labelText: 'Nome do Produto'),
                  ),
                  TextFormField(
                    controller: quantidadeController,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextFormField(
                    controller: valorUnidadeController,
                    decoration: InputDecoration(labelText: 'Valor Unidade (R\$)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha de Admin',
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.green[900]),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text == 'admin123') {
                      String novoNomeProduto = nomeProdutoController.text;
                      int novaQuantidade = int.parse(quantidadeController.text);
                      double novoValorUnidade = double.parse(valorUnidadeController.text);
                      
                      // Atualiza o produto com o novo nome, quantidade e valor por unidade
                      produto.produto = novoNomeProduto;
                      produto.quantidadeRestante = novaQuantidade;
                      produto.valorUnidade = novoValorUnidade;

                      await _firestore.collection('Estoque').doc(produto.id).update(produto.toJson());

                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Senha inválida!'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text('Salvar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos Cadastrados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 400, // Define a largura desejada do campo de pesquisa
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar Produto',
                    labelStyle: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold),
                    hintText: 'Digite o nome do produto',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.green[900]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.green[900]!, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<EstoqueItem>>(
                stream: _carregarProdutos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar produtos'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum produto cadastrado'));
                  } else {
                    List<EstoqueItem> produtos = snapshot.data!
                        .where((produto) => produto.produto.toLowerCase().contains(_searchQuery))
                        .toList(); // Filtra os produtos com base na pesquisa

                    return ListView.builder(
                      itemCount: produtos.length,
                      itemBuilder: (context, index) {
                        EstoqueItem produto = produtos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage('assets/fundoCard.png'), // Substitua pelo caminho da imagem
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(produto.imagemUrl!, fit: BoxFit.cover),
                                          )
                                        : Icon(Icons.inventory, size: 40, color: Colors.green[900]),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produto.produto,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                        ),
                                        SizedBox(height: 8),
                                        Text('Categoria: ${produto.categoria}', style: TextStyle(color: Colors.white, fontSize: 14)),
                                        SizedBox(height: 8),
                                        Text('Quantidade em estoque: ${produto.quantidadeRestante}', style: TextStyle(color: Colors.white, fontSize: 14)),
                                        SizedBox(height: 8),
                                        Text('Valor Unidade: R\$ ${produto.valorUnidade.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    onPressed: () => _editarProduto(produto),
                                  ),
                                     IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarProduto(produto), // Chama a função de exclusão
                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
