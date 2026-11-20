import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/MontagemTreino.dart';

void main() {
  testWidgets('exibe e ajusta apenas repetições e intervalo', (tester) async {
    final key = GlobalKey<MontagemTreinoState>();
    final user = UserModel(
      id: 'usuario-teste',
      username: 'Teste',
      email: 'teste@exemplo.com',
      altura: 1.7,
      peso: 70,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MontagemTreino(key: key, user: user),
      ),
    );

    final state = key.currentState!;
    state.bodyExercicios = [
      ExercicioComControles(
        exercicio: Exercicio(
          nome: 'Supino reto',
          descricao: 'Supino com barra',
          musculosAlvo: ['Peito'],
          gifUrl: '',
        ),
        repeticoesInicial: 8,
        intervaloInicial: 2,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: MontagemTreino(key: key, user: user),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('REPETIÇÕES'), findsOneWidget);
    expect(find.text('INTERVALO (MIN)'), findsOneWidget);
    expect(find.text('SÉRIES'), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    expect(find.text('9'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
