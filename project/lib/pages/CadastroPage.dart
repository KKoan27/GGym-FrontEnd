import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/pages/login.dart';
import 'package:http/http.dart' as http;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();
  bool cadastrando = false;

  void _realizarCadastro() async {



    // Validação básica
    if (_senhaController.text != _confirmaSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem!")));
      return;
    }

setState((){
cadastrando = true;
});
    // Aqui você conectaria com o backend
    // print("Cadastrando: ${_nomeController.text}, ${_emailController.text}");
   register({
      'nome': _nomeController.text,
      'email': _emailController.text,
      'senha': _senhaController.text,
    }, context);


    // Vai direto para a Home após cadastro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Stack para manter o fundo se quiser adicionar as imagens de background depois
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 220,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person_add, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 30),
              const Text(
                'Cadastre-se',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              _buildInput(
                controller: _nomeController,
                label: "Nome completo",
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _emailController,
                label: "E-mail",
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _senhaController,
                label: "Senha",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _confirmaSenhaController,
                label: "Senha novamente",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _realizarCadastro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:  cadastrando ?CircularProgressIndicator(
                          color: Colors.white, // Cor do indicador
                          strokeWidth: 2.5,
                        ):
                         const Text(
                  'Cadastrar',
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
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE50000)),
      ),
    );
  }

  Future<void> register(Map<String, String> body, BuildContext context) async {
    Map<String, String?> requestbody = {
      "nome": body['nome'],
      "email": body['email'],
      "senha": body['senha'],
    };

    try {
      var result = await http.post(
        Uri.parse("http://127.0.0.1:8090/user/register"),
        body: jsonEncode(requestbody),
        headers: {'Content-Type': 'application/json'},
      );

      print(result.body);
      print(result.statusCode);
      if (result.statusCode == 400) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao cadastrar!")));
        throw Exception("erro na requisição : ${result.body}");
      } else if (result.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cadastro completo!")));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } on Exception  {
      rethrow;
    }
    finally{
      setState((){
cadastrando = false;
});
    }
  }
}
