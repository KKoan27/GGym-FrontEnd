import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/models/exercicio.dart';
import 'package:project/models/treino.dart';
import 'package:project/pages/PlayTrainpage.dart';

void main() {
  testWidgets('PlayTrainpage initializes remaining time from exercise interval', (tester) async {
    final treino = Treino(
      nomeTreino: 'Treino A',
      userId: 'usuario-1',
      exercicios: [
        Exercicio(
          nome: 'Supino',
          descricao: 'Supino teste',
          gifUrl: '',
          musculosAlvo: const ['Peito'],
          dicas: const ['Respire bem'],
          repeticoes: 10,
          intervalo: 1,
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(home: Playtrainpage(treino: treino)));

    expect(find.text('01:00'), findsOneWidget);
  });
}
