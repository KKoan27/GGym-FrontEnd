import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';
import 'package:project/services/exercicio_service.dart';
import 'package:project/pages/detalhe_exercicio_page.dart';

class ListaExerciciosPage extends StatefulWidget {
  const ListaExerciciosPage({super.key});

  @override
  // Usei StatefulWidget pois a lista precisa ser atualizada
  // dinamicamente quando o usuário faz uma pesquisa.
  State<ListaExerciciosPage> createState() => _ListaExerciciosPageState();
}

class _ListaExerciciosPageState extends State<ListaExerciciosPage> {
  final ExercicioService _exercicioService = ExercicioService();

  // [TÉCNICO] Variável que guarda o estado da promessa (Future).
  // Armazeno o Future numa variável para evitar que a requisição
  // seja refeita toda vez que o teclado abre ou a tela recarrega (build).
  late Future<List<Exercicio>> _futureExercicios;
   String search = "";

  // [TÉCNICO] Controlador para ler o texto do input de busca.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // [TÉCNICO] Carrega a lista completa ao iniciar a tela.
    _futureExercicios = _exercicioService.fetchExercicios();
  }

  @override
  void dispose() {
    // [BOAS PRÁTICAS] Limpar o controller da memória evita memory leaks.
    _searchController.dispose();
    super.dispose();
  }

  // [DICA DE EXERCÍCIO] O professor pode pedir para mudar a lógica da busca.
  void _realizarPesquisa() {
    setState(() {
      // [TÉCNICO] Ao mudar o _futureExercicios dentro do setState,
      // forçamos o FutureBuilder a rodar de novo com o novo parâmetro (query).
      _futureExercicios = _exercicioService.fetchExercicios(
        query: _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // [LAYOUT] Campo de busca customizado no AppBar
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          // O onChanged fica aqui, sozinho.
          // Adicionei o onChanged para que a pesquisa aconteça em tempo real.
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState((){
search = value;
              });

              
            },
            // O decoration é uma propriedade do TextField, fica fora do onChanged
            decoration: const InputDecoration(
              hintText: "Pesquisar exercícios...",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),

            // [UX] Pesquisa ao apertar "Enter" no teclado
            // O onSubmitted também é irmão, fica fora
            onSubmitted: (_) => _realizarPesquisa(),
          ),
        ),
        actions: [
          // [UX] Botão explícito de pesquisa
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _realizarPesquisa,
          ),
        ],
      ),

      // O FutureBuilder é essencial para chamadas de API, pois gerencia
      // os 3 estados da requisição: Carregando, Erro e Sucesso.
      body: FutureBuilder<List<Exercicio>>(
        future: _futureExercicios,
        builder: (context, snapshot) {
          // 1. ESTADO DE CARREGAMENTO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50000)),
            );
          }

          // 2. ESTADO DE ERRO
          // aqui trata o erros de internet
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar dados. ${snapshot.error}', // Pode adicionar: ${snapshot.error} para debugar
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // 3. ESTADO VAZIO (Sucesso mas sem dados)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum exercício encontrado.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // 4. SUCESSO
          final exercicios = snapshot.data!;
          final exerciciosFilter = _exercicioService.filterExercicio(exercicios, search);

          // [PERFORMANCE] ListView.separated é melhor que ListView padrão para listas grandes
          // pois renderiza apenas o que está na tela.
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exerciciosFilter.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final exercicio = exerciciosFilter[index];
              return _buildExercicioCard(context, exercicio);
            },
          );
        },
      ),
    );
  }

  // [BOAS PRÁTICAS] Método extraído para deixar o build mais limpo
  Widget _buildExercicioCard(BuildContext context, Exercicio exercicio) {
    return GestureDetector(
      // [NAVEGAÇÃO] Passagem de parâmetro (objeto exercicio) para a próxima tela
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheExercicioPage(exercicio: exercicio),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Lado Esquerdo: Imagem
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                // Tratamento de imagem quebrada/vazia
                child: exercicio.gifUrl.isNotEmpty
                    ? Image.network(
                        exercicio.gifUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                            ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        color: Colors.white24,
                        size: 40,
                      ),
              ),
            ),

            // Centro: Textos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exercicio.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis, // Corta texto longo com "..."
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercicio.musculosAlvo.isNotEmpty
                          ? exercicio.musculosAlvo.join(", ")
                          : "Geral",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Direita: Ícone
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFE50000),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
