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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : treinos.isEmpty
          ? const Center(child: Text('Nenhum treino encontrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: treinos.length,
              itemBuilder: (context, index) {
                final treino = treinos[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Playtrainpage(treino: treino),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            treino.nomeTreino,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${treino.exercicios.length} exercícios',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.playlist_add_rounded),
        onPressed: () async {
          final bool? treinoAdicionado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MontagemTreino(user: widget.user),
            ),
          ) as bool?;

          if (treinoAdicionado == true) {
            _loadTreinos();
          }
        },
      ),
    );
  }
}

//  PRIMEIRO CÓDIGO FEITO //

// import 'package:flutter/material.dart';

// class TreinoPage extends StatefulWidget {
//   const TreinoPage({super.key});

//   @override
//   State<TreinoPage> createState() => _TreinoPageState();
// }

// class _TreinoPageState extends State<TreinoPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Meus Treinos"),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Treino A",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "Nome do treino",
//                       style: TextStyle(
//                         fontSize: 15,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Exemplo: 5 exercícios · Foco: Hipertrofia",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.playlist_add_rounded),
//         onPressed: () {
//           Navigator.pushNamed(context, '/addtreino');
//         },
//       ),
//     );
//   }
// }
