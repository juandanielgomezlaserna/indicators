import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:indicator/main.dart';
import 'package:indicator/views/login/login.dart';

class AuthService {
  static const String baseUrl = 'https://indicators-api-dgij.onrender.com/api/v1';
  final _storage = const FlutterSecureStorage();

  /// 1. LOGIN
  Future<bool> login(String usuario, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['status'] == 'success') {
      final String token = responseData['data']['token'];
      await _storage.write(key: 'jwt_token', value: token);

      // 🚀 Guardar usuario en el Map de GetX
      if (responseData['data']['usuario'] != null) {
        controller.setUser(Map<String, dynamic>.from(responseData['data']['usuario']));
      }

      return true;
    } else {
      throw Exception(responseData['message'] ?? 'Credenciales incorrectas');
    }
  }

  /// 2. REGISTER
  Future<bool> register({
    required String nombreCompleto,
    required String usuario,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre_completo': nombreCompleto,
        'usuario': usuario,
        'email': email,
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (responseData['data'] != null) {
        if (responseData['data']['token'] != null) {
          final String token = responseData['data']['token'];
          await _storage.write(key: 'jwt_token', value: token);
        }

        // 🚀 Guardar usuario en el Map de GetX
        if (responseData['data']['usuario'] != null) {
          controller.setUser(Map<String, dynamic>.from(responseData['data']['usuario']));
        }
      }
      return true;
    } else {
      throw Exception(responseData['message'] ?? 'Error al registrar usuario');
    }
  }

  /// 3. AUTO-LOGIN (Verificar Token y Cargar Perfil)
  Future<bool> checkAuth() async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/auth/me'); // Endpoint para obtener perfil del usuario autenticado

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // 🚀 Cargar los datos del usuario persistido en el Map
        controller.setUser(Map<String, dynamic>.from(responseData['data']['usuario']));
        print(controller.User);
        return true;
      } else {
        // Si el token expiró o es inválido, limpiamos storage
        await logout();
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  /// Recupera el token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Cierra la sesión y limpia el Map
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    controller.clearUser();

    // Redirección con GetX eliminando todo el historial previo de navegación
    Get.offAll(() => const LoginPage());
  }
}