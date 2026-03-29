import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hermanosalvarez_app/core/config/api_config.dart';

class ApiService {

  Future<List<Map<String, dynamic>>> getParadas() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/paradas'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar paradas');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getDestinosValidos({
    required String origen,
    required String dia,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/destinos-validos?origen=$origen&dia=$dia'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar destinos válidos');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getHorarios({
    required String origen,
    required String destino,
    required String dia,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/horarios?origen=$origen&destino=$destino&dia=$dia'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar horarios');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}