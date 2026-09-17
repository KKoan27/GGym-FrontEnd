import 'package:flutter/material.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/treinoPage.dart';
import 'package:project/pages/lista_exercicios_page.dart';
import 'package:project/pages/PerfilPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final UserModel user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variável que guarda qual aba está selecionada (0, 1 ou 2)
  int _indiceAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O body muda dependendo do índice selecionado
      body: _selecionarTela(_indiceAtual),

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C1C), // Fundo cinza escuro
        currentIndex: _indiceAtual, // Diz à barra qual ícone deve brilhar
        selectedItemColor: const Color(0xFFE50000), // Cor do ícone ativo
        unselectedItemColor: Colors.grey, // Cor dos ícones inativos
        // Função chamada quando clica em um ícone
        onTap: (novoIndice) {
          setState(() {
            _indiceAtual = novoIndice; // Atualiza a variável e redesenha a tela
          });
        },
        
        items: [
          iconNavigationBarItem(Icons.fitness_center, "Exercicios"),
          iconNavigationBarItem(Icons.assignment_rounded, "Treinos"),
          iconNavigationBarItem(Icons.person, "Perfil")
        ],
      ),
    );
  }

  BottomNavigationBarItem iconNavigationBarItem(IconData icone, String label ) {
    return BottomNavigationBarItem(
          // Ícone padrão (Inativo)
          icon: Icon(icone),
          // Ícone Ativo (Com Zoom)
          activeIcon: Transform.scale(
            scale: 1.2,
            child: Icon(icone)
          ),
          label: label,
        );
  }

  // Método auxiliar que retorna o Widget correto baseado no índice
  Widget _selecionarTela(int index) {
    switch (index) {
      case 0:
        return const ListaExerciciosPage(); // Página de Exercícios
      case 1:
        return TreinoPage(user: widget.user); // Página de Treinos
      case 2:
        return PerfilPage(user: widget.user);
      default:
        return Container();
    }
  }
}
