import 'dart:core';
import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/services/exercicio_service.dart';

class AdicionaExercicio extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AdicionaExercicioState();
}

class AdicionaExercicioState extends State<AdicionaExercicio> {

  ExercicioService  exercicioService =  ExercicioService();

  late Future<List<Exercicio>> exercicioFuture;
  List<int> selectedIndex = [];
  TextEditingController searchController = TextEditingController();
  String search = "";


  List<Exercicio> bodySelect = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (texto) => 
            setState(() {
              search = texto;
            })
          ),
          Expanded(
            child: FutureBuilder(
              future: exercicioFuture,
              builder: (context, snapshot) {
                try {
                  if (snapshot.hasError) {
                    return Center(child: Text("Deu erro na requisição"));
                  }
                  // if (snapshot.connectionState == ConnectionState.waiting) {}
                  if (snapshot.hasData) {

                   final filtrados = exercicioService.filterExercicio(snapshot.data!, search);
                    return ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        var musculosAlvo = filtrados[index].musculosAlvo
                            .join(',');

                        final bool selecionado = bodySelect.contains(filtrados[index]);

                        return Card(
                          elevation: 3,
                          color: selecionado ? Colors.red[700] : Colors.black38,
                          margin: EdgeInsets.all(10),
 
                          child: CheckboxListTile(
                            title: Text(filtrados[index].nome),
                            subtitle: Text(musculosAlvo),

                            value: selecionado,
                            onChanged: (value)=> setState(() {
                                if (selecionado) {
                                  bodySelect.remove(filtrados[index]);
                                } else {
                                  bodySelect.add(filtrados[index]);
                                }
                              })
                            ,
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                } on Exception {
                  rethrow;
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: (() => Navigator.pop(context, bodySelect)),
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
super.initState();

    exercicioFuture =  exercicioService.fetchExercicios();
    
  }

  
  // Conceito adaptado para sua classe AdicionaExercicioState:

}
