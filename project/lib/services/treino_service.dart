import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/exercicio.dart';
import 'package:project/models/treino.dart';
import 'package:project/models/usuario.dart';

class TreinoService {
  final String _baseUrl = 'http://127.0.0.1:8090/api/treino';

  Future<List<Treino>> fetchTreinos() async {
    final user = await UserModel.loadFromPrefs();
    final userId = user?.id ?? '';
    final token = user?.token ?? '';

    if (userId.isEmpty) {
      return [];
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'userid': userId,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return treinoFromJson(response.body);
    }

    throw Exception('Falha ao carregar treinos: ${response.statusCode}');
  }

  Future<bool> criarTreino({
    required String nomeTreino,
    required String descricao,
    required List<ExercicioComControles> exercicios,
  }) async {
    final user = await UserModel.loadFromPrefs();
    final userId = user?.id ?? '';
    final token = user?.token ?? '';

    if (userId.isEmpty) {
      throw Exception('Usuário não autenticado');
    }

    // Converter ExercicioComControles em payload
    final exerciciosPayload = exercicios.map((item) {
      return {
        'id': item.exercicio.id,
        'nome': item.exercicio.nome,
        'repeticoes': item.repeticoes.value,
        'intervalo': item.intervalo.value,
      };
    }).toList();

    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'nomeTreino': nomeTreino,
      // 'descricao': descricao, - AINDA NÂO
      'exercicios': exerciciosPayload,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Erro na requisição: ${response.statusCode}. Corpo: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}