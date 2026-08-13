import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraBolsilloApi.dart';
import 'package:indicator/models/carteraMovimientoApi.dart';

// Instancia para la lectura segura del token de sesión
const _storage = FlutterSecureStorage();

/**
 * Obtiene la lista de transacciones recurrentes del usuario autenticado
 */
Future<void> getRecurrentesApi() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes');

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
        controller.setRecurrentes(decodedData['data']);
      }
    } else {
      print("Error al obtener recurrentes: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getRecurrentesApi: $e");
  }
}

/**
 * Crear una nueva transacción recurrente para el usuario autenticado
 */
Future<bool> createRecurrenteApi({
  required String descripcion,
  required double monto,
  required String tipo,
  required String categoria,
  required String frecuencia,
  required int bolsilloId,
  required String proximaEjecucion,
  int? diaPago,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes');

    final body = json.encode({
      'descripcion': descripcion,
      'monto': monto,
      'tipo': tipo,
      'categoria': categoria,
      'frecuencia': frecuencia.toLowerCase(),
      'dia_pago': diaPago,
      'proxima_ejecucion': proximaEjecucion.split('T').first,
      'bolsillo_id': bolsilloId,
      'activo': true,
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
        await getRecurrentesApi();
        return true;
      }
    } else {
      print("Error al crear recurrente: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en createRecurrenteApi: $e");
    return false;
  }
}

/**
 * Ejecuta manualmente el cobro/ingreso de una transacción recurrente
 */
Future<bool> ejecutarRecurrenteApi(int id) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes/$id/ejecutar');

    final response = await http.post(
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
        // Refrescar bolsillos, movimientos y recurrentes en orden descendente
        await getBolsillos();
        await getMovimientosApi();
        await getRecurrentesApi();
        return true;
      }
    } else {
      print("Error al ejecutar recurrente: [${response.statusCode}] ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error al ejecutar recurrente: $e");
    return false;
  }
}

/**
 * Actualiza los datos de una transacción recurrente existente
 */
Future<bool> editarRecurrenteApi({
  required int id,
  String? descripcion,
  double? monto,
  String? categoria,
  String? frecuencia,
  String? proximaEjecucion,
  int? bolsilloId,
  bool? activo,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes/$id');

    final Map<String, dynamic> body = {};

    if (descripcion != null && descripcion.isNotEmpty) body['descripcion'] = descripcion;
    if (monto != null) body['monto'] = monto;
    if (categoria != null && categoria.isNotEmpty) body['categoria'] = categoria;
    if (frecuencia != null && frecuencia.isNotEmpty) body['frecuencia'] = frecuencia.toLowerCase();
    if (proximaEjecucion != null && proximaEjecucion.isNotEmpty) {
      body['proxima_ejecucion'] = proximaEjecucion.split('T').first;
    }
    if (bolsilloId != null) body['bolsillo_id'] = bolsilloId;
    if (activo != null) body['activo'] = activo;

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await getRecurrentesApi();
      return true;
    }

    print("⚠️ Error Server [${response.statusCode}]: ${response.body}");
    return false;
  } catch (e) {
    print("❌ Excepción en editarRecurrenteApi: $e");
    return false;
  }
}