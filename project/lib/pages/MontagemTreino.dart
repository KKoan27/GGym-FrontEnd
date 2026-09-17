import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/pages/AdicionaExercicio.dart';
import 'package:project/models/usuario.dart';
import 'package:project/services/treino_service.dart';

class MontagemTreino extends StatefulWidget {
  final UserModel user;
  const MontagemTreino({super.key, required this.user});

  @override
  State<MontagemTreino> createState() {
    return MontagemTreinoState();
  }
}

class MontagemTreinoState extends State<MontagemTreino> {
  late TextEditingController nomeTreino;
  late TextEditingController descricaoTreino;

  String? selectItem;
  List<ExercicioComControles> bodyExercicios = [];
  final TreinoService _treinoService = TreinoService();

  @override
  void dispose() {
    nomeTreino.dispose();
    descricaoTreino.dispose();
    // Limpar os controles de cada exercício
    for (var item in bodyExercicios) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    nomeTreino = TextEditingController();
    descricaoTreino = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cancelar')),
      // 1. MUDANÇA: SingleChildScrollView envolve tudo para evitar erro com teclado
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Criar Novo Treino",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 16),

              entradaDeDados("Nome do treino", Icons.edit_sharp, nomeTreino),
              const SizedBox(height: 20),
              entradaDeDados("Descrição", Icons.list, descricaoTreino),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (() async {
                      final exerciciosSelecionados = await Navigator.push<List<Exercicio>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AdicionaExercicio();
                          },
                        ),
                      );

                      if (exerciciosSelecionados != null) {
                        final List<Exercicio> novosExercicios =
                            exerciciosSelecionados;

                        // Converter em ExercicioComControles
                        final listaComControles = novosExercicios
                            .map((e) => ExercicioComControles(exercicio: e))
                            .toList();

                        setState(() {
                          bodyExercicios = listaComControles;
                        });
                      }
                    }),
                    child: Text("Adicionar Exercicios"),
                  ),
                  const SizedBox(width: 20), // Ajustei levemente o espaçamento
                  ElevatedButton(
                    onPressed: () {
                      treinoPOST(context);
                    },
                    child: Text("Salvar treino"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. MUDANÇA: Removemos o Expanded aqui. A lista rola junto com a página.
              bodyExercicios.isNotEmpty
                  ? ListView.builder(
                      // Essas duas linhas fazem a lista ocupar só o espaço necessário
                      // e não ter rolagem interna (quem rola é a página toda)
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = bodyExercicios[index];
                        final ValueNotifier<int> intervaloCrtl = item.intervalo;
                        final ValueNotifier<int> repeticoesCrtl = item.repeticoes;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.exercicio.nome),

                            // 3. MUDANÇA: Reduzi de 250 para 170 para caber em telas menores
                            trailing: SizedBox(
                              width: 170,
                              child: Row(
                                children: [
                                  // --- Controles de INTERVALO ---
                                  Expanded(
                                    child: Column(
                                      // Mudei para Column para economizar largura se precisar
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Min",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              // Troquei IconButton por InkWell para tirar padding extra
                                              onTap: () {
                                                if (intervaloCrtl.value > 0)
                                                  intervaloCrtl.value -= 1;
                                              },
                                              child: Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            ValueListenableBuilder(
                                              valueListenable: intervaloCrtl,
                                              builder:
                                                  (context, value, child) =>
                                                      Text(
                                                        '$value',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {
                                                intervaloCrtl.value += 1;
                                              },
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const VerticalDivider(
                                    width: 10,
                                    thickness: 1,
                                  ),

                                  // --- Controles de REPETIÇÕES ---
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Reps",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (repeticoesCrtl.value > 0) {
                                                  repeticoesCrtl.value -= 1;
                                                }
                                              },
                                              child: Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            ValueListenableBuilder(
                                              valueListenable: repeticoesCrtl,
                                              builder:
                                                  (context, value, child) =>
                                                      Text(
                                                        '$value',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {
                                                repeticoesCrtl.value += 1;
                                              },
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: bodyExercicios.length,
                    )
                  : Center(
                      child: Text(
                        "Selecione os exercícios",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> treinoPOST(BuildContext context) async {
    try {
      await _treinoService.criarTreino(
        nomeTreino: nomeTreino.text,
        descricao: descricaoTreino.text,
        exercicios: bodyExercicios,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Treino criado com sucesso!")),
      );
      Navigator.pop(context, true);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro na conexão: $e")),
      );
    }
  }

  Widget entradaDeDados(
    String texto,
    IconData? icone,
    TextEditingController controller,
  ) {
    return Card(
      elevation: 2,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(texto),
          icon: Icon(icone),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
