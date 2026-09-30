import 'package:flutter/material.dart';
import 'telaVerificacaoPage.dart';

class ResetarSenhaPage extends StatefulWidget {
  const ResetarSenhaPage({super.key});

  @override
  State<ResetarSenhaPage> createState() => _ResetarSenhaPageState();
}

class _ResetarSenhaPageState extends State<ResetarSenhaPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background placeholders (opcional, mantive do seu código original)
          SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/logo.png',
                  height: 220,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lock_reset,
                    size: 100,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Redefinir Senha',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'E-mail',
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: Color(0xFFE50000),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: () {
                    // Simula envio de email
                    if (_emailController.text.isNotEmpty) {
                      print("Código enviado para ${_emailController.text}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaVerificacao(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Digite seu email")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
