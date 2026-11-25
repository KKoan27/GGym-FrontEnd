import 'package:flutter/material.dart';
import 'package:project/models/treino.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/montagemTreino.dart';
import 'package:project/pages/playTrainpage.dart';
import 'package:project/services/treino_service.dart';

class TreinoPage extends StatefulWidget {
  final UserModel user;

  const TreinoPage({super.key, required this.user});

  @override
  State<TreinoPage> createState() => _TreinoPageState();
}

class _TreinoPageState extends State<TreinoPage> {
  final TreinoService _treinoService = TreinoService();
  List<Treino> treinos = [];
  bool isLoading = true;

  static const Color _backgroundColor = Color(0xFF0C0F11);
  static const Color _cardColor = Color(0xFF14171A);
  static const Color _accentColor = Color(0xFFE62E2D);

  @override
  void initState() {
    super.initState();
    _loadTreinos();
  }

  Future<void> _loadTreinos() async {
    setState(() => isLoading = true);

    try {
      final fetchedTreinos = await _treinoService.fetchTreinos();
      setState(() {
        treinos = fetchedTreinos;
      });
    } catch (e) {
      setState(() => treinos = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openWorkout(Treino treino) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Playtrainpage(treino: treino)),
    );
  }

  Future<void> _createWorkout() async {
    final treinoAdicionado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MontagemTreino(user: widget.user),
      ),
    );

    if (treinoAdicionado == true) {
      _loadTreinos();
    }
  }

  Widget _buildWorkoutCard(Treino treino, int index) {
    return Card(
      color: _cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _openWorkout(treino),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.65,
                    child: Icon(Icons.sports_gymnastics_outlined),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x0014171A),
                          Color(0x8014171A),
                          _cardColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          treino.nomeTreino,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: _accentColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${treino.exercicios.length} exercícios',
                              style: const TextStyle(
                                color: Color(0xFFD4D4D4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Mais opções',
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFFD4D4D4),
                      size: 20,
                    ),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'deletar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Deletar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: _treinoService.deletarTreino(treino),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _accentColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _openWorkout(treino),
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'A consistência constrói resultados',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.bolt, color: _accentColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${treinos.length} ${treinos.length == 1 ? 'treino' : 'treinos'}',
                      style: const TextStyle(
                        color: _accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: _accentColor),
                    ),
                  )
                else if (treinos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'Nenhum treino encontrado.',
                        style: TextStyle(color: Color(0xFFA3A3A3)),
                      ),
                    ),
                  )
                else
                  ...treinos.indexed.map((item) {
                    final (index, treino) = item;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildWorkoutCard(treino, index),
                    );
                  }),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _createWorkout,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    label: const Text(
                      'Criar novo treino',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
