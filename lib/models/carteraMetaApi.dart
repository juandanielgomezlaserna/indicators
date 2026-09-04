import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Refresca bolsillos
import 'package:indicator/models/carteraMovimientoApi.dart'; // Refresca historial

// Instancia de almacenamiento seguro para recuperar el token JWT
const _storage = FlutterSecureStorage();

/**
 * Obtiene la lista de metas de ahorro del usuario autenticado
 */
Future<void> getMetasApi() async {
  try {
    // 1. Recuperamos el token JWT desde Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return;
    }

    // Ruta neutra: la identidad se determina mediante el JWT en la API
    final url = Uri.parse('${Global.baseUrl}cartera-metas');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        controller.setMetas(decodedData['data']);
      }
    } else {
      print("Error al obtener metas: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getMetasApi: $e");
  }
}

/**
 * Crear una nueva meta de ahorro para el usuario autenticado
 */
Future<bool> createMetaApi({
  required String nombre,
  required double montoObjetivo,
  double montoActual = 0.0,
  int? bolsilloOrigenId,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    print("BOLSILLO ID: $bolsilloOrigenId");

    final url = Uri.parse('${Global.baseUrl}cartera-metas');

    // No enviamos 'usuario': el ID proviene del token firmado en el backend
    final body = json.encode({
      'nombre': nombre,
      'monto_objetivo': montoObjetivo,
      'monto_actual': montoActual,
      'bolsillo_origen_id': bolsilloOrigenId,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        await getMetasApi();
        return true;
      }
    } else {
      print("Error al crear meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en createMetaApi: $e");
    return false;
  }
}

/**
 * Realiza un depósito a una meta de ahorro desde un bolsillo
 */
Future<bool> depositarAMetaApi({
  required int metaId,
  required int bolsilloId,
  required double monto,
  String? descripcion,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-metas/$metaId/deposito');

    // Mantenemos solo la información del movimiento; la propiedad y validación la realiza Express
    final body = json.encode({
      'bolsillo_id': bolsilloId,
      'monto': monto,
      'descripcion': descripcion,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescamos metas, bolsillos y movimientos en cascada
        await getMetasApi();
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al depositar a la meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en depositarAMetaApi: $e");
    return false;
  }
}

/**
 * Actualiza una meta de ahorro existente en el backend mediante su ID.
 */
Future<bool> updateMetaApi({
  required int metaId,
  String? nombre,
  double? montoObjetivo,
  double? montoActual,
  bool? completado,
  int? bolsilloOrigenId,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-metas/$metaId');

    // Construimos dinámicamente el body solo con los campos que no sean nulos
    final Map<String, dynamic> data = {};
    if (nombre != null) data['nombre'] = nombre;
    if (montoObjetivo != null) data['monto_objetivo'] = montoObjetivo;
    if (montoActual != null) data['monto_actual'] = montoActual;
    if (completado != null) data['completado'] = completado;
    if (bolsilloOrigenId != null) data['bolsillo_origen_id'] = bolsilloOrigenId;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescamos la lista de metas para reflejar los cambios en la UI
        await getMetasApi();
        return true;
      }
    } else {
      print("Error al actualizar meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en updateMetaApi: $e");
    return false;
  }
}

/**
 * Elimina una meta de ahorro existente en el backend mediante su ID.
 */
Future<bool> deleteMetaApi({required int metaId}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-metas/$metaId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescamos la lista de metas para actualizar la interfaz
        await getMetasApi();
        return true;
      }
    } else {
      print("Error al eliminar meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en deleteMetaApi: $e");
    return false;
  }
}