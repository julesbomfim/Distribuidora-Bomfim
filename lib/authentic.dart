import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:distribuidora_bomfim/classVenda.dart';
import 'classEstoque.dart';


class AuthService {
  Future<void> addUser(EstoqueItem produto) async {
    final docUser = FirebaseFirestore.instance.collection('Estoque').doc();
    produto.id = docUser.id;
    await docUser.set(produto.toJson());
  }

  Future<void> updateStock(EstoqueItem item) async {
    await FirebaseFirestore.instance.collection('Estoque').doc(item.id).update({
      'quantidadeRestante': item.quantidadeRestante,
    });
  }

  Future<void> registrarVenda(Venda venda) async {
    final docVenda = FirebaseFirestore.instance.collection('Vendas').doc();
    venda.id = docVenda.id;
    await docVenda.set(venda.toJson());
  }
}
 

