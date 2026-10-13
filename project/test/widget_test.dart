import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/models/treino.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/HomePage.dart';
import 'package:project/pages/PlayTrainpage.dart';
import 'package:project/pages/lista_exercicios_page.dart';
import 'package:project/pages/treinoPage.dart';
import 'mockExercicioService.dart';

void main() {
  testWidgets("Testando serviço de exercicios", (tester) async {
    final mockExercicios = [
      Exercicio(
        nome: "Supino Reto",
        descricao: "Execução em supino com barra reta.",
        musculosAlvo: ["Peito", "Tríceps", "Ombros"],
        gifUrl: "https://example.com/supino_reto.gif",
      ),
      Exercicio(
        nome: "Agachamento",
        descricao: "Agachamento profundo com postura correta.",
        musculosAlvo: ["Quadríceps", "Glúteos", "Posterior"],
        gifUrl: "https://example.com/agachamento.gif",
      ),
      Exercicio(
        nome: "Levantamento Terra",
        descricao: "Movimento de puxada e extensão do corpo.",
        musculosAlvo: ["Costas", "Glúteos", "Posterior"],
        gifUrl: "https://example.com/levantamento_terra.gif",
      ),
      Exercicio(
        nome: "Rosca Direta",
        descricao: "Flexão de cotovelos com barra reta.",
        musculosAlvo: ["Bíceps", "Antebraço"],
        gifUrl: "https://example.com/rosca_direta.gif",
      ),
      Exercicio(
        nome: "Desenvolvimento",
        descricao: "Pressão acima da cabeça com barra.",
        musculosAlvo: ["Ombros", "Tríceps"],
        gifUrl: "https://example.com/desenvolvimento.gif",
      ),
    ];

    final mockExercicioService = MockExercicioService();

    when(
      () => mockExercicioService.fetchExercicios(),
    ).thenAnswer((_) => Future.value(mockExercicios));

    final user = UserModel(
      id: "0001",
      username: "TesteUsuario",
      email: "koan.teste@gmail.com",
      altura: 10,
      peso: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(user: user, exercicioService: mockExercicioService),
      ),
    );
    // AQUI ESTAMOS NA TELA DE Exercicios (Tela pós login )
    expect(find.byType(ListaExerciciosPage), findsOne);

    // Passando para a tela de Treino
    await tester.tap(find.text('Treinos'));
    // Use um pump com tempo determinado:
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Exercicios'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ListaExerciciosPage), findsOneWidget);

    verify(() => mockExercicioService.fetchExercicios()).called(2);
  });
}
