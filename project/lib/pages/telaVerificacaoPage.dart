import 'package:flutter/material.dart';
import 'novaSenhaPage.dart'; // Próximo passo do fluxo

class TelaVerificacao extends StatefulWidget {
  const TelaVerificacao({super.key});

  @override
  State<TelaVerificacao> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<TelaVerificacao> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (index) => FocusNode());
    _controllers = List.generate(4, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }

  void _nextField(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/logo.png',
                  height: 220,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.security, size: 100, color: Colors.red),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Insira o código de\nverificação:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),

                // Campos de Código
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (value) => _nextField(value, index),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          counterText: "",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFE50000),
                              width: 2,
                            ),
                          ),
                          fillColor: Colors
                              .transparent, // Remove o fundo cinza padrão do tema global
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Código reenviado!")),
                    );
                  },
                  child: const Text(
                    'Reenviar código',
                    style: TextStyle(
                      color: Colors.white54,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: () {
                    String code = _controllers.map((c) => c.text).join();
                    print("Código digitado: $code");
                    // Vai para a tela de criar nova senha
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NovaSenhaPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Validar',
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
