import 'dart:convert';
import 'package:flutter/material.dart';

List<Exercicio> exercicioFromJson(String str) {
  final decoded = json.decode(str);

  if (decoded is Map<String, dynamic>) {
    final lista = decoded['body']?['exercicios'];

    if (lista is List) {
      return List<Exercicio>.from(
        lista.map((item) => Exercicio.fromJson(item as Map<String, dynamic>)),
      );
    }

    if (decoded.containsKey('exercicios')) {
      return List<Exercicio>.from(
        (decoded['exercicios'] as List).map(
          (x) => Exercicio.fromJson(x as Map<String, dynamic>),
        ),
      );
    }

    if (decoded.containsKey('response')) {
      return List<Exercicio>.from(
        (decoded['response'] as List).map(
          (x) => Exercicio.fromJson(x as Map<String, dynamic>),
        ),
      );
    }

    return [];
  }

  if (decoded is List) {
    return List<Exercicio>.from(
      decoded.map((x) => Exercicio.fromJson(x as Map<String, dynamic>)),
    );
  }

  return [];
}

class Exercicio {
  final String? id;
  final String nome;
  final String descricao;
  final List<String> musculosAlvo;
  final String gifUrl;
  final List<String> dicas;

  int? repeticoes;
   int? intervalo;

  Exercicio({
    this.id,
    required this.nome,
    required this.descricao,
    required this.musculosAlvo,
    required this.gifUrl,
    this.dicas = const [],
    this.repeticoes,
    this.intervalo,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: json['_id'] ?? '',
      nome: json['nome'] ?? 'Sem nome',
      descricao: json['descricao'] ?? 'Sem descrição disponível.',
      gifUrl: json['execucao'] ?? '',
      musculosAlvo:
          (json['musculosAlvo'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      dicas:
          (json['dicas'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      repeticoes: json['repeticoes'] as int?,
      intervalo: json['intervalo'] as int?,
    );
  }
}

/// Classe Wrapper que encapsula um Exercicio com seus controles reativo
class ExercicioComControles {
  final Exercicio exercicio;
  final ValueNotifier<int> intervalo;
  final ValueNotifier<int> repeticoes;

  ExercicioComControles({
    required this.exercicio,
    int? intervaloInicial,
    int? repeticoesInicial,
  })  : intervalo = ValueNotifier(intervaloInicial ?? exercicio.intervalo ?? 0),
        repeticoes = ValueNotifier(repeticoesInicial ?? exercicio.repeticoes ?? 0);

  void dispose() {
    intervalo.dispose();
    repeticoes.dispose();
  }
}
