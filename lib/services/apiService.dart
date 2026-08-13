import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/models/authService.dart';

class ApiService {
  static const String baseUrl = 'https://indicators-api-dgij.onrender.com/api/v1';
  final AuthService _authService = AuthService();

  // Método genérico GET para traer datos (Bolsillos, Metas, Deseos, etc.)
  Future<dynamic> get(String endpoint) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Adjunta el token automático
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // El token cambió porque se inició sesión en otro lugar
      await _authService.logout();
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }
}