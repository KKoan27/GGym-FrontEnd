import 'package:flutter/material.dart';
import 'package:project/models/exercicio.dart';

class DetalheExercicioPage extends StatefulWidget {
  // Recebe o objeto 'Exercicio' via construtor. Assim, não preciso
  // buscar na API de novo, apenas exibo os dados que vieram da lista.
  final Exercicio exercicio;

  const DetalheExercicioPage({super.key, required this.exercicio});

  @override
  // Escolhi StatefulWidget porque preciso controlar qual aba
  // está visível ('Instruções' ou 'Detalhes') através de uma variável de estado.
  State<DetalheExercicioPage> createState() => _DetalheExercicioPageState();
}

class _DetalheExercicioPageState extends State<DetalheExercicioPage> {
  // Variável de controle: 0 mostra instrução, 1 mostra detalhes.
  int _abaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Cabeçalho: Botão Voltar/Cancelar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    // Uso o Navigator.pop(context) para desempilhar esta tela
                    // e voltar para a anterior (Lista).
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Título do Exercício
            Text(
              widget.exercicio.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 3. Imagem / GIF Centralizado
            // [LAYOUT] SizedBox define um tamanho fixo para a imagem não estourar a tela.
            SizedBox(
              height: 250,
              child: widget.exercicio.gifUrl.isNotEmpty
                  ? Image.network(
                      widget.exercicio.gifUrl,
                      // [LAYOUT] BoxFit.contain garante que o GIF apareça inteiro sem cortes.
                      fit: BoxFit.contain,
                      // [DEFESA] Tratamento de erro se a URL do GIF estiver quebrada.
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.movie, size: 80, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 4. Abas Customizadas Lógica de Troca de Abas
            // Implementei abas manuais usando Row e GestureDetector
            // para ter controle total do design, sem depender do TabBar padrão do Material.
            Row(
              children: [
                _buildCustomTab("Instruções", 0),
                _buildCustomTab("Detalhes", 1),
              ],
            ),

            // 5. Conteúdo Dinâmico (Aqui acontece a troca de abas)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                // Operador ternário: Se aba for 0, mostra Instruções, senão Detalhes.
                // O conteúdo muda dinamicamente baseado na variável _abaSelecionada,
                // usando renderização condicional.
                child: SingleChildScrollView(
                  child: _abaSelecionada == 0
                      ? _buildInstrucoesContent()
                      : _buildDetalhesContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [BOAS PRÁTICAS] Método para evitar repetição de código nos botões das abas
  Widget _buildCustomTab(String title, int index) {
    final bool isActive = _abaSelecionada == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Atualiza o estado para redesenhar a tela com a nova aba.
            _abaSelecionada = index;
          });
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          // [UX] Feedback visual: Cor muda se estiver ativo ou inativo.
          color: isActive
              ? const Color(0xFFE50000) // Vermelho Ativo
              : const Color(0xFF1C1C1C), // Cinza Inativo
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Conteúdo da Aba 1
  Widget _buildInstrucoesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Músculo Principal (Foco)",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Uso do operador spread (...) para inserir uma lista de Widgets dentro da Column.
          // O .map transforma cada String (músculo) em um Widget (Row com texto).
          ...widget.exercicio.musculosAlvo.map(
            (musculo) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
              child: Row(
                children: [
                  const Text("• ", style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Text(
                      musculo,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Execução",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercicio.descricao,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Conteúdo da Aba 2
  Widget _buildDetalhesContent() {
    // [LÓGICA] Verificação se existem dicas para não mostrar tela vazia.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.exercicio.dicas.isNotEmpty) ...[
            const Text(
              "Dicas e Erros Comuns",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.exercicio.dicas.map(
              (dica) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Text(
                        dica,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // [UX] Feedback caso não haja dados.
            const Text(
              "Nenhuma informação adicional disponível.",
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }
}
