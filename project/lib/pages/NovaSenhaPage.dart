import 'package:flutter/material.dart';
import 'loginPage.dart';

class NovaSenhaPage extends StatefulWidget {
  const NovaSenhaPage({super.key});

  @override
  State<NovaSenhaPage> createState() => _NovaSenhaPageState();
}

class _NovaSenhaPageState extends State<NovaSenhaPage> {
  final _senhaController = TextEditingController();
  final _confirmaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Nova Senha"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 220,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
            const SizedBox(height: 40),
            const Text(
              "Crie uma nova senha",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nova Senha",
                prefixIcon: Icon(Icons.lock, color: Color(0xFFE50000)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar Senha",
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFE50000)),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                // Simula redefinição e volta pro Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Senha alterada com sucesso!")),
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
                "Redefinir Senha",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
