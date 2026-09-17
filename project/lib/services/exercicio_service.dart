import 'package:http/http.dart' as http;
import 'package:project/models/exercicio.dart';
import 'package:project/models/usuario.dart';

class ExercicioService {
  final String _baseUrl = 'http://127.0.0.1:8090/api/getexercicios';

  Future<List<Exercicio>> fetchExercicios({String query = ''}) async {
    final user = await UserModel.loadFromPrefs();
    final token = user?.token ?? '';

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: query.trim().isEmpty ? null : {'q': query.trim()},
    );

    final response = await http.get(
      uri,
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return exercicioFromJson(response.body);
    }

    throw Exception('Falha ao carregar: ${response.statusCode}');
  }


List<Exercicio> filterExercicio(List<Exercicio> exercicios, String query){ 
   return exercicios.where((e) => e.nome.toLowerCase().contains(query.toLowerCase())).toList();
}}
