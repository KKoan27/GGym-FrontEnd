import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/models/treino.dart';
import 'package:project/pages/detalhe_exercicio_page.dart';

class Playtrainpage extends StatefulWidget {
  // A lista de Exercicios com repetições e intervalo
  final Treino treino;
  Playtrainpage({super.key, required this.treino});
  @override
  State<Playtrainpage> createState() => PlaytrainpageState();
}

class PlaytrainpageState extends State<Playtrainpage> {
  late PageController _pageViewController;

  late List<List<bool>> _seriesConcluidasPorExercicio;
  bool exercicioConcluido = false;
  int _paginaAtual = 0;
  late ValueNotifier<int> _tempoRestante;
  late ValueNotifier<Timer?> _timer;
  final ValueNotifier<bool> _timerAtivo = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _seriesConcluidasPorExercicio = List.generate(
      widget.treino.exercicios.length,
      (index) => [false, false, false],
    );
    _pageViewController = PageController(initialPage: 0);
    _tempoRestante = ValueNotifier<int>(0);
    _timer = ValueNotifier<Timer?>(null);
    _reiniciarTimer();
  }

  @override
  void dispose() {
    _timer.value?.cancel();
    _timer.dispose();
    _tempoRestante.dispose();
    _timerAtivo.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  void _reiniciarTimer() {
    _timer.value?.cancel();
    _timerAtivo.value = false;

    _tempoRestante.value =
        (widget.treino.exercicios[_paginaAtual].intervalo ?? 0) * 60;
  }

  void _iniciarTimer() {
    if (_tempoRestante.value <= 0) return;

    _timerAtivo.value = true;
    _timer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempoRestante.value <= 1) {
        timer.cancel();
        _timer.value = null;
        _tempoRestante.value = 0;
        _timerAtivo.value = false;
        return;
      }

      _tempoRestante.value--;
    });
  }

  void _alternarTimer() {
    if (_timerAtivo.value) {
      _timer.value?.cancel();
      _timer.value = null;
      _timerAtivo.value = false;
    } else if (_tempoRestante.value > 0) {
      _iniciarTimer();
    }
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  void upPage() {
    if (_paginaAtual < widget.treino.exercicios.length - 1) {
      _pageViewController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void downPage() {
    if (_paginaAtual > 0) {
      _pageViewController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool verificaCheckBoxs(int value) {
    return _seriesConcluidasPorExercicio[value].every(
      (serieConcluida) => serieConcluida,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.treino.nomeTreino,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageViewController,
        onPageChanged: (index) {
          setState(() {
            _paginaAtual = index;
            exercicioConcluido = verificaCheckBoxs(index);
            _reiniciarTimer();
          });
        },
        itemCount: widget.treino.exercicios.length,
        itemBuilder: (context, index) {
          Exercicio exercicioatual = widget.treino.exercicios[index];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cabeçalho do Exercício
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercicioatual.nome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: const Icon(
                        Icons.help_outline,
                        size: 28,
                        color: Colors.redAccent,
                      ),
                      // PENDENTE
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalheExercicioPage(exercicio: exercicioatual),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // GIF do Exercício com bordas arredondadas e altura controlada
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 200,
                    child: exercicioatual.gifUrl.trim().isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: Colors.grey,
                            ),
                          )
                        : Image.network(
                            exercicioatual.gifUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Timer / Intervalo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.alarm, color: Colors.red),
                    ValueListenableBuilder<int>(
                      valueListenable: _tempoRestante,
                      builder: (context, tempoRestante, _) {
                        return Text(
                          _formatarTempo(tempoRestante),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 40,
                            letterSpacing: 1.2,
                          ),
                        );
                      },
                    ),

                    GestureDetector(
                      onTap: _alternarTimer,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _timerAtivo,
                          builder: (context, ativo, _) {
                            return Icon(
                              ativo
                                  ? Icons.pause_outlined
                                  : Icons.play_arrow_outlined,
                              size: 30,
                              color: const Color.fromARGB(255, 233, 110, 110),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _reiniciarTimer();
                      },
                      icon: const Icon(Icons.refresh),
                      color: const Color.fromARGB(255, 233, 110, 110),
                      tooltip: 'Reiniciar timer',
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Lista de Séries
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int serie = 1; serie <= 3; serie++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "S$serie",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${exercicioatual.repeticoes}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  "reps",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 80),
                            Checkbox(
                              // Acessa a matriz bidimensional de estados: para cada exercício atual
                              // (indexExercicio), temos uma lista interna contendo o estado das 3 séries.
                              // O loop avança pelas séries (1 a 3), mapeando os dados linha por linha.
                              value:
                                  _seriesConcluidasPorExercicio[index][serie -
                                      1],
                              onChanged: (bool? valor) {
                                setState(() {
                                  _seriesConcluidasPorExercicio[index][serie -
                                          1] =
                                      valor ?? false;
                                  exercicioConcluido = verificaCheckBoxs(index);
                                  _reiniciarTimer();
                                  _iniciarTimer();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          children: [
            // Botão "Anterior" (ou "Próximo" dependendo da sua regra)
            Expanded(
              child: TextButton(
                onPressed: _paginaAtual > 0 ? downPage : null,
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Botão "Finalizar / Próximo" com fundo vermelho (#e62e2d)
            Expanded(
              child: TextButton(
                onPressed: exercicioConcluido
                    ? () async {
                        if (_paginaAtual <
                            widget.treino.exercicios.length - 1) {
                          upPage();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Treino concluido")),
                          );
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.pop(context);
                        }
                      }
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor: exercicioConcluido
                      ? const Color(0xFFE62E2D)
                      : Colors.grey, // Cor primaria vermelha
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Próximo',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.skip_next_outlined, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
