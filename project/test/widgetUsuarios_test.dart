import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:project/models/usuario.dart';
import 'package:project/pages/login.dart';
import 'package:project/pages/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mockUsuariosService.dart';

void main() {
  group('LoginScreen', () {
    Future<void> abrirLogin(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    }

    testWidgets('exibe validação quando e-mail e senha estão vazios', (
      tester,
    ) async {
      await abrirLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Preencha e-mail e senha!'), findsOneWidget);
    });

    testWidgets('exibe validação quando somente a senha está vazia', (
      tester,
    ) async {
      await abrirLogin(tester);
      await tester.enterText(
        find.byType(TextField).first,
        'usuario@exemplo.com',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Preencha e-mail e senha!'), findsOneWidget);
    });

    testWidgets('faz login e abre a página inicial quando retorna 200', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final mockUsuariosService = MockUsuariosService(
        statusCode: 200,
        responseBody: jsonEncode({
          'body': {
            'response': {
              'id': 'usuario-1',
              'nome': 'Usuario Teste',
              'email': 'usuario@exemplo.com',
              'altura': 1.75,
              'peso': 70,
            },
            'token': 'token-de-teste',
          },
        }),
      );

      await http.runWithClient(() async {
        await abrirLogin(tester);
        await tester.enterText(
          find.byType(TextField).first,
          'usuario@exemplo.com',
        );
        await tester.enterText(find.byType(TextField).last, 'senha-valida');
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
        final user = await UserModel.loadFromPrefs();
        expect(user?.username, 'Usuario Teste');
        expect(user?.token, 'token-de-teste');
      }, mockUsuariosService.createClient);

      final request = mockUsuariosService.requests.firstWhere(
        (request) => request.method == 'POST',
      );
      expect(
        request.url.toString(),
        'https://ggym-backend.onrender.com/user/auth',
      );
      expect(jsonDecode(request.body), {
        'email': 'usuario@exemplo.com',
        'senha': 'senha-valida',
      });
    });

    testWidgets('exibe erro para credenciais não autorizadas', (tester) async {
      final mockUsuariosService = MockUsuariosService(statusCode: 401);

      await http.runWithClient(() async {
        await abrirLogin(tester);
        await tester.enterText(
          find.byType(TextField).first,
          'usuario@exemplo.com',
        );
        await tester.enterText(find.byType(TextField).last, 'senha-incorreta');
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.text('❌ Email ou senha incorreto'), findsOneWidget);
      }, mockUsuariosService.createClient);

      final request = mockUsuariosService.lastRequest;
      expect(request, isNotNull);
      expect(request!.method, 'POST');
      expect(
        request.url.toString(),
        'https://ggym-backend.onrender.com/user/auth',
      );
      expect(jsonDecode(request.body), {
        'email': 'usuario@exemplo.com',
        'senha': 'senha-incorreta',
      });
    });

    testWidgets('exibe erro para falha do servidor', (tester) async {
      final mockUsuariosService = MockUsuariosService(statusCode: 500);

      await http.runWithClient(() async {
        await abrirLogin(tester);
        await tester.enterText(
          find.byType(TextField).first,
          'usuario@exemplo.com',
        );
        await tester.enterText(find.byType(TextField).last, 'senha-valida');
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('❌ Erro 500: Falha na comunicação com o servidor.'),
          findsOneWidget,
        );
      }, mockUsuariosService.createClient);
    });

    testWidgets('abre a página de cadastro pelo link de primeiro acesso', (
      tester,
    ) async {
      await abrirLogin(tester);

      await tester.tap(find.text('Primeiro acesso? Cadastre-se'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Primeiro acesso? Cadastre-se'), findsNothing);
    });
  });
}
