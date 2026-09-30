import 'package:flutter/material.dart';
// Certifique-se de que este import aponte para sua classe UserModel
import 'package:project/models/usuario.dart';
import 'package:project/services/user_service.dart';
import 'resetarSenhaPage.dart';
import 'cadastroPage.dart';
import 'homePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para ler o que foi digitado nos campos
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false; // para demonstrar que está logando

  // Função que executa a lógica de LOGIN e navegação
  void _realizarLogin() async {
    // 1. Validação simples: verifica se os campos não estão vazios
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha e-mail e senha!")));
      return; // Interrompe se estiver vazio
    }
    setState(() {
      _isLoading = true;
    });
    // 2. Chamar a função de consumo (o serviço de login)
    // A função 'login' (importada de login_service.dart) já cuida
    // da chamada HTTP, dos SnackBar de erro e de salvar em SharedPreferences.
    UserModel? user = await UserServiceClient("https://ggym-backend.onrender.com/user/auth").login(
      _emailController.text,
      _senhaController.text,
      context,
    );

    setState(() {
      _isLoading = false;
    });
    // 3. Tratar o resultado e navegar
    if (user != null) {
      // Login bem-sucedido. Navega para a Home
      Navigator.pushAndRemoveUntil(
        context,
        // Usamos o 'pushAndRemoveUntil' para que o usuário não volte para o Login
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
        (route) => false, // Remove todas as rotas anteriores
      );
    }
    // Se 'user' for null, a função 'login' já exibiu o SnackBar de erro.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (Logo e Título existentes) ...
              Image.asset(
                'assets/logo.png',
                height: 220,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.lock_reset, size: 100, color: Colors.red),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bem-vindo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Campos de texto
              TextField(
                controller: _emailController,
                // ... (Decoração existente) ...
                decoration: const InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: Icon(
                    Icons.alternate_email,
                    color: Color(0xFFE50000),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                ), // Adiciona estilo para texto digitado
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _senhaController,
                obscureText: true,
                // ... (Decoração existente) ...
                decoration: const InputDecoration(
                  hintText: 'Senha',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color(0xFFE50000),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                ), // Adiciona estilo para texto digitado
              ),

              const SizedBox(height: 30),

              // Botão Entrar
              ElevatedButton(
                onPressed: _realizarLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50000),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: const Color.fromARGB(
                    183,
                    189,
                    79,
                    72,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, // Cor do indicador
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 20),

              // ... (Links de Cadastro e Resetar Senha existentes) ...
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
                  );
                },
                child: const Text(
                  'Primeiro acesso? Cadastre-se',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetarSenhaPage(),
                    ),
                  );
                },
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: Color(0xFFE50000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
