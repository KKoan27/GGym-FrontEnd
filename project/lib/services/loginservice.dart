import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/models/usuario.dart'; // Certifique-se de importar o modelo

// URL base da sua API
const String _baseUrl ="https://ggym-backend.onrender.com/user/auth";

/// Realiza o login do usuário.
/// * @param email O email fornecido pelo usuário.
/// @param senha A senha fornecida pelo usuário.
/// @param context O contexto para exibir SnackBars.
/// @return O UserModel se o login for bem-sucedido, ou null caso contrário.
Future<UserModel?> login(
  String email,
  String senha,
  BuildContext context,
) async {
  final Map<String, String> requestBody = {"email": email, "senha": senha};

  // Seu backend usa "authuser" como op (operação), vamos usá-lo na URL
  final Uri uri = Uri.parse(_baseUrl);

  try {
    var result = await http.post(
      uri,
      body: jsonEncode(requestBody), // Envia JSON
      headers: {'Content-Type': 'application/json'},
    );

    // Seu backend retorna 200 (OK) para sucesso e 401 (Unauthorized) para falha.
    if (result.statusCode == 200) {
      // Sucesso no Login
      final jsonResponse = jsonDecode(result.body);
      final body = jsonResponse['body'] as Map<String, dynamic>?;
      final userDataMap = body?['response'] as Map<String, dynamic>?;
      final token = body?['token']?.toString();

      if (userDataMap != null) {
        final UserModel user = UserModel.fromJson(userDataMap, token: token);

        // 🔑 Salvar dados no SharedPreferences
        await user.saveToPrefs();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("👋 Bem-vindo(a), ${user.username}!")),
        );

        return user;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Resposta do servidor incompleta.")),
        );
        return null;
      }
    } else if (result.statusCode == 401) {
     
      String errorMessage =  "Email ou senha incorreto" ;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $errorMessage"), duration: Duration(seconds: 2),));
      return null;
    } else {
      // Outros Erros de Servidor (400, 500 etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Erro ${result.statusCode}: Falha na comunicação com o servidor.",
          ),
        ),
      );
      return null;
    }
  } catch (e, s) {
    // Falha de Conexão (servidor offline, rede indisponível)

    print("\n $e \n $s");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Falha na conexão. Verifique a URL do servidor."),
      ),
    );
    return null;
  }
}
