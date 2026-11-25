import 'dart:convert';

import 'exercicio.dart';

List<Treino> treinoFromJson(String str) {
  final decoded = json.decode(str);
  final List<dynamic> treinosJson;

  if (decoded is List) {
    treinosJson = decoded;
  } else if (decoded is Map<String, dynamic>) {
    final bodyData = decoded['body'];
    final response = decoded['response'];

    if (bodyData is List) {
      treinosJson = bodyData;
    } else if (response is List) {
      treinosJson = response;
    } else {
      return [];
    }
  } else {
    return [];
  }

  return treinosJson
      .map((item) => Treino.fromJson(item as Map<String, dynamic>))
      .toList();
}

class Treino {
  final String nomeTreino;
  final String userId;
  final List<Exercicio> exercicios;

  Treino({
    required this.nomeTreino,
    required this.userId,
    required this.exercicios,
  });

  factory Treino.fromJson(Map<String, dynamic> json) {
    final exerciciosRaw = json['exercicios'] as List? ?? [];

    return Treino(
      nomeTreino: json['nomeTreino']?.toString() ?? 'Treino sem nome',
      userId: json['userId']?.toString() ?? '',
      exercicios: exerciciosRaw
          .map((item) => Exercicio.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
