import 'package:distribuidora_bomfim/main.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Definição dos dados de login válidos
  final String validEmail = "distribuidorabomfim@gmail.com";
  final String validPassword = "bomfim123";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() {
    // Verificação do login
    if (emailController.text == validEmail && passwordController.text == validPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green[900],
        ),
      );

      // Navegar para a HomePage
     Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email ou senha inválidos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Fundo branco para a tela de login
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.green[900],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.8, // Ajuste o fator de tamanho conforme necessário
                        child: ClipRRect(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                          child: Image.asset(
                            'assets/logo.png', // Substitua pelo caminho da sua imagem
                            fit: BoxFit.contain,
                            height: 480, // Defina uma altura fixa ou ajuste conforme necessário
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Cor branca para o texto
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: emailController, // Controlador para o email
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.red), // Cor do texto da label
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca quando habilitado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca quando focado
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController, // Controlador para a senha
                            obscureText: !_isPasswordVisible, // Controla a visibilidade da senha
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: TextStyle(color: Colors.red), // Cor do texto da label
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca quando habilitado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.white), // Borda branca quando focado
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
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
                          ),
                          SizedBox(height: 32),
                          Center(
                            child: ElevatedButton(
                              onPressed: _login, // Chama a função de login ao pressionar o botão
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.green[900]),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Fundo branco para o botão
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
