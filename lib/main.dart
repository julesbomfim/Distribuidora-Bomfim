import 'package:distribuidora_bomfim/fluxodecaixa.dart';
import 'package:distribuidora_bomfim/landingPage.dart';
import 'package:distribuidora_bomfim/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastrarEstoque.dart';
import 'vendas.dart';
import 'estoque.dart';
import 'historico.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAB12oPw9AS9mJf73Bo9K7p5sZaCcCzlgM",
      authDomain: "distribuidora-bomfim.firebaseapp.com",
      projectId: "distribuidora-bomfim",
      storageBucket: "distribuidora-bomfim.appspot.com",
      messagingSenderId: "644437503757",
      appId: "1:644437503757:web:3d49b3078e2459a6e70a44",
    ),
  );
  setUrlStrategy(PathUrlStrategy());
 
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distribuidora Bomfim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[900],
        hintColor: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          headline6: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          button: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/landing': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/estoque': (context) => EstoquePage(),
        '/vendas': (context) => VendaPage(),
        '/listar': (context) => ListarProdutosPage(),
        '/historico': (context) => HistoricoPage(),
        '/fluxoCaixa': (context) => FluxoDeCaixaPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    EstoquePage(),
    VendaPage(),
    ListarProdutosPage(),
    HistoricoPage(),
     FluxoDeCaixaPage(),
  ];

  void _logout() {
    // Implementação do logout (por exemplo, redirecionar para a tela de login)
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fundo.png'), // Caminho para sua imagem
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              title: Text('Distribuidora Bomfim', style: TextStyle(color: Colors.white)),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo.png'), // Caminho para sua imagem
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo
          Row(
            children: [
              Container(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png', // Substitua pelo caminho da sua imagem
                        height: 200,
                      ),
                      SizedBox(height: 16),
                      HomeButton(
                        text: 'Cadastro Estoque',
                        icon: Icons.inventory_2,
                        index: 0,
                        selectedIndex: _selectedIndex,
                        onPressed: () => _onItemTapped(0),
                      ),
                      SizedBox(height: 16),
                      HomeButton(
                        text: 'Venda Estoque',
                        icon: Icons.sell,
                        index: 1,
                        selectedIndex: _selectedIndex,
                        onPressed: () => _onItemTapped(1),
                      ),
                      SizedBox(height: 16),
                      HomeButton(
                        text: 'Lista Estoque',
                        icon: Icons.list_alt,
                        index: 2,
                        selectedIndex: _selectedIndex,
                        onPressed: () => _onItemTapped(2),
                      ),
                      SizedBox(height: 16),
                      HomeButton(
                        text: 'Histórico de Vendas',
                        icon: Icons.history,
                        index: 3,
                        selectedIndex: _selectedIndex,
                        onPressed: () => _onItemTapped(3),
                      ),
                        SizedBox(height: 16),
                      HomeButton(
                        text: 'Despesas do dia', // Novo botão adicionado aqui
                        icon: Icons.monetization_on, // Ícone representativo
                        index: 4,
                        selectedIndex: _selectedIndex,
                        onPressed: () => _onItemTapped(4),
                      ),
                   
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.8), // Fundo semi-transparente para legibilidade
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final int index;
  final int selectedIndex;
  final VoidCallback onPressed;

  HomeButton({
    required this.text,
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.green[900],
        backgroundColor: isSelected ? Colors.green[900] : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green[900]!),
        ),
        elevation: 4,
      ),
      icon: Icon(icon, size: 28, color: isSelected ? Colors.white : Colors.green[900]),
      label: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.green[900])),
      onPressed: onPressed,
    );
  }
}
