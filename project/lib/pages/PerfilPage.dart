import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/models/usuario.dart';
import 'package:project/pages/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  final UserModel user;

  const PerfilPage({super.key, required this.user});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late TextEditingController _alturaController;
  late TextEditingController _pesoController;

  double _imc = 0.0;

  @override
  void initState() {
    super.initState();
    // Iniciam vazios, mostrando apenas o Hint
    _alturaController = TextEditingController(text: "");
    _pesoController = TextEditingController(text: "");

    // O cálculo inicial do IMC usa os dados salvos do usuário, mesmo que os campos visuais estejam vazios
    _calcularIMCInicial();
  }

  @override
  void dispose() {
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  // Função separada apenas para calcular o IMC ao abrir a tela com os dados do usuário
  void _calcularIMCInicial() {
    if (widget.user.altura > 0 && widget.user.peso > 0) {
      setState(() {
        _imc = widget.user.peso / (widget.user.altura * widget.user.altura);
      });
    }
  }

  // Função chamada ao digitar ou clicar no botão
  void _calcularIMC() {
    // Se o campo estiver vazio, considera 0 para não dar erro
    if (_alturaController.text.isEmpty || _pesoController.text.isEmpty) return;

    double alturaInput =
        double.tryParse(_alturaController.text.replaceAll(',', '.')) ?? 0;
    double pesoInput =
        double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0;

    double alturaMetros = alturaInput > 3.0 ? alturaInput / 100 : alturaInput;

    if (alturaMetros > 0 && pesoInput > 0) {
      setState(() {
        _imc = pesoInput / (alturaMetros * alturaMetros);
      });
    }
  }

  Future<void> _atualizarDados() async {
    if (_alturaController.text.isEmpty || _pesoController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha altura e peso!")));
      return;
    }

    try {
      double alturaInput = double.parse(
        _alturaController.text.replaceAll(',', '.'),
      );
      double alturaMetros = alturaInput > 3.0 ? alturaInput / 100 : alturaInput;

      double novoPeso = double.parse(_pesoController.text.replaceAll(',', '.'));

      UserModel novoUsuario = UserModel(
        id: widget.user.id,
        username: widget.user.username,
        email: widget.user.email,
        altura: alturaMetros,
        peso: novoPeso,
      );

      await novoUsuario.saveToPrefs();
      _calcularIMC(); // Recalcula com os dados novos da tela

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Medidas atualizadas!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verifique os números digitados.")),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABEÇALHO
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[600],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFE50000),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      widget.user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // TÍTULO
              _buildSectionTitle("Medidas Corporais"),
              const SizedBox(height: 15),

              // INPUTS
              _buildRowInput(
                "Altura",
                _alturaController,
                suffix: "cm",
                hint: "Ex: 175",
                allowDecimals: false,
              ),
              const SizedBox(height: 12),
              _buildRowInput(
                "Peso",
                _pesoController,
                suffix: "kg",
                hint: "Ex: 70.5",
                allowDecimals: true,
              ),

              const SizedBox(height: 20),

              // BOTÃO
              SizedBox(
                width: 130,
                height: 40,
                child: ElevatedButton(
                  onPressed: _atualizarDados,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Calcular IMC",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // TABELA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Veja a interpretação do IMC",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 5),
              _buildTable(),

              const SizedBox(height: 25),

              // RESULTADO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SEU IMC:",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Center(
                          child: Text(
                            _imc.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Cálculo do IMC",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "O Índice de Massa Corporal (IMC) é usado para saber se você está no peso ideal. Para calcular, dividimos o seu peso pela sua altura ao quadrado.",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIARES
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      color: const Color(0xFF1A1A1A),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRowInput(
    String label,
    TextEditingController controller, {
    String suffix = "",
    String hint = "",
    bool allowDecimals = true,
  }) {
    return Row(
      children: [
        // Label (Caixa Escura)
        Container(
          width: 90,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),

        // Input (Caixa Branca)
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: allowDecimals,
              ),
              inputFormatters: [
                allowDecimals
                    ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlignVertical: TextAlignVertical.center,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none, // Sem borda
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none, // Sem borda quando ativo
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none, // Sem borda quando focado
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ), // Centraliza
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                suffixIcon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.black,
                ),
                suffixText: suffix.isNotEmpty ? suffix : null,
                suffixStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  "IMC",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Classificação",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Obesidade (grau)",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFE50000), thickness: 1, height: 1),
        _buildTableRow("Menor que 18,5", "Magreza", "0"),
        _buildTableRow("Entre 18,5 e 24,9", "Normal", "0"),
        _buildTableRow("Entre 25,0 e 29,9", "Sobrepeso", "I"),
        _buildTableRow("Entre 30,0 e 39,9", "Obesidade", "II"),
        _buildTableRow("Maior que 40,0", "Obesidade Grave", "III"),
      ],
    );
  }

  Widget _buildTableRow(String col1, String col2, String col3) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  col1,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  col2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  col3,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFE50000), thickness: 1, height: 1),
      ],
    );
  }
}
