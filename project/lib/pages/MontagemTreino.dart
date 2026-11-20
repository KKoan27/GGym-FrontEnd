import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/AdicionaExercicio.dart';
import 'package:project/services/treino_service.dart';

class MontagemTreino extends StatefulWidget {
  final UserModel user;

  const MontagemTreino({super.key, required this.user});

  @override
  State<MontagemTreino> createState() => MontagemTreinoState();
}

class MontagemTreinoState extends State<MontagemTreino> {
  static const _backgroundColor = Color(0xFF07090C);
  static const _cardColor = Color(0xFF111317);
  static const _inputColor = Color(0xFF121418);
  static const _borderColor = Color(0xFF22252C);
  static const _accentColor = Color(0xFFE11D48);

  final _nomeTreinoController = TextEditingController();
  final _descricaoTreinoController = TextEditingController();
  final _treinoService = TreinoService();

  List<ExercicioComControles> bodyExercicios = [];
  bool _salvando = false;

  @override
  void dispose() {
    _nomeTreinoController.dispose();
    _descricaoTreinoController.dispose();
    for (final item in bodyExercicios) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _adicionarExercicios() async {
    final exerciciosSelecionados = await Navigator.push<List<Exercicio>>(
      context,
      MaterialPageRoute(builder: (_) => AdicionaExercicio()),
    );

    if (!mounted || exerciciosSelecionados == null) return;

    final novosExercicios = exerciciosSelecionados
        .map((exercicio) => ExercicioComControles(exercicio: exercicio))
        .toList();

    setState(() {
      for (final item in bodyExercicios) {
        item.dispose();
      }
      bodyExercicios = novosExercicios;
    });
  }

  void _removerExercicio(int index) {
    setState(() {
      final removido = bodyExercicios.removeAt(index);
      removido.dispose();
    });
  }

  Future<void> _salvarTreino() async {
    if (_salvando) return;

    setState(() => _salvando = true);
    try {
      await _treinoService.criarTreino(
        nomeTreino: _nomeTreinoController.text,
        descricao: _descricaoTreinoController.text,
        exercicios: bodyExercicios,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino criado com sucesso!')),
      );
      Navigator.pop(context, true);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na conexão: $error')));
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        leadingWidth: 112,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, size: 22),
          label: const Text('Cancelar'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.only(left: 8),
          ),
        ),
        title: const Text(
          'Criar Novo Treino',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _campoTreino(
              label: 'TÍTULO',
              hint: 'Exemplo: treino focado em peito',
              controller: _nomeTreinoController,
            ),
            const SizedBox(height: 12),
            _campoTreino(
              label: 'DESCRIÇÃO (OPCIONAL)',
              hint: 'Exemplo: foco em hipertrofia',
              controller: _descricaoTreinoController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'EXERCÍCIOS SELECIONADOS',
                    style: TextStyle(
                      color: Color(0xFFD4D4D4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B111B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF652032)),
                  ),
                  child: Text(
                    '${bodyExercicios.length} ${bodyExercicios.length == 1 ? 'item' : 'itens'}',
                    style: const TextStyle(
                      color: Color(0xFFFF718B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (bodyExercicios.isEmpty)
              _estadoVazio()
            else
              ...bodyExercicios.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _cartaoExercicio(entry.key, entry.value),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarExercicios,
        tooltip: 'Adicionar exercício',
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: _cardColor,
            border: Border(top: BorderSide(color: Color(0xFF1C1F26))),
          ),
          child: FilledButton.icon(
            onPressed: _salvando ? null : _salvarTreino,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF181B22),
              disabledBackgroundColor: const Color(0xFF181B22),
              foregroundColor: const Color(0xFFE5E5E5),
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFF30343D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, color: Color(0xFFFF536C)),
            label: Text(_salvando ? 'Salvando...' : 'Salvar treino'),
          ),
        ),
      ),
    );
  }

  Widget _campoTreino({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFFA3A3A3),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
          hintStyle: const TextStyle(color: Color(0xFF737373), fontSize: 14),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _estadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFFFF536C), size: 32),
          const SizedBox(height: 10),
          const Text(
            'Nenhum exercício selecionado',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adicione exercícios para montar seu treino.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA3A3A3), fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _adicionarExercicios,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar exercícios'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF718B),
              side: const BorderSide(color: Color(0xFF652032)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoExercicio(int index, ExercicioComControles item) {
    final gruposMusculares = item.exercicio.musculosAlvo.isEmpty
        ? 'Grupo muscular não informado'
        : item.exercicio.musculosAlvo.join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2128)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF090B0D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFFD9475B),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: _accentColor, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.exercicio.nome,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              gruposMusculares,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFA3A3A3),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removerExercicio(index),
                        tooltip: 'Remover exercício',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF8A8A8A),
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0x1AFFFFFF)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _controleMetrica(
                          titulo: 'REPETIÇÕES',
                          valor: item.repeticoes,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _controleMetrica(
                          titulo: 'INTERVALO (MIN)',
                          valor: item.intervalo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controleMetrica({
    required String titulo,
    required ValueNotifier<int> valor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF17191F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFA3A3A3),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _botaoAjuste(
                icon: Icons.remove,
                onPressed: () {
                  if (valor.value > 0) valor.value--;
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: valor,
                builder: (context, atual, _) => Text(
                  '$atual',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _botaoAjuste(icon: Icons.add, onPressed: () => valor.value++),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botaoAjuste({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF242731),
          foregroundColor: const Color(0xFFE5E5E5),
        ),
        icon: Icon(icon, size: 15),
      ),
    );
  }
}
