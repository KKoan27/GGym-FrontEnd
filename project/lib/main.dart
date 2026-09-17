import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'package:project/pages/AdicionaExercicio.dart';
// import 'package:project/pages/HomePage.dart';
// import 'package:project/pages/MontagemTreino.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      // ROTA INICIAL
      initialRoute: '/login',

      // DEFINIÇÃO DAS ROTAS
      routes: {
        '/login': (context) => const LoginScreen(),
        '/selectexercicio': (context) => AdicionaExercicio(),
      },

      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50000),
          secondary: Color(0xFFE50000),
          surface: Color(0xFF1C1C1C),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFFE50000), width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFFE50000), width: 3.0),
          ),
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
