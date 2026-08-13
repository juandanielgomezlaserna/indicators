import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Para refrescar bolsillos al abonar
import 'package:indicator/models/carteraMovimientoApi.dart'; // Para refrescar movimientos al abonar

// Instancia de almacenamiento seguro para recuperar el JWT token
const _storage = FlutterSecureStorage();

/**
 * Obtiene la lista de deudas activas del usuario autenticado
 */
Future<void> getDeudasApi() async {
  try {
    // 1. Recuperamos el token JWT guardado en Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return;
    }

    // Ruta neutra: la identidad del usuario la determina el backend mediante el token
    final url = Uri.parse('${Global.baseUrl}cartera-deudas');

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
        // Actualizamos las deudas en el controlador global de la app
        controller.setDeudas(decodedData['data']);
      }
    } else {
      print("Error al obtener deudas: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión al servidor en getDeudasApi: $e");
  }
}

/**
 * Registra una nueva deuda (acreedor, monto inicial y saldo pendiente)
 */
Future<bool> createDeudaApi({
  required String acreedor,
  required double montoInicial,
  double? montoPendiente,
  String tipo = 'cobrar',
  String? fechaLimitePago,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-deudas');

    // No enviamos 'usuario': el ID proviene del token firmado
    final body = json.encode({
      'acreedor_deudor': acreedor,
      'monto_total': montoInicial,
      'monto_pendiente': montoPendiente ?? montoInicial,
      'tipo': tipo,
      'fecha_limite_pago': fechaLimitePago,
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
        // Refrescamos la lista de deudas para actualizar la UI en Flutter
        await getDeudasApi();
        return true;
      }
    } else {
      print("Error al crear deuda: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en createDeudaApi: $e");
    return false;
  }
}

/**
 * Realiza un abono a una deuda.
 * Impacta la deuda, descuenta del bolsillo y registra un movimiento de gasto.
 */
Future<bool> abonarDeudaApi({
  required int deudaId,
  required int bolsilloId,
  required double monto,
  String categoria = 'Pago Deuda',
  String? descripcion,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-deudas/$deudaId/abonar');

    // No enviamos 'usuario': la autorización y validación de propiedad se hacen en el backend
    final body = json.encode({
      'bolsillo_id': bolsilloId,
      'monto': monto,
      'categoria': categoria,
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
        // Al abonar, sincronizamos: Deudas, Bolsillos y Movimientos
        await getDeudasApi();
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al abonar deuda: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en abonarDeudaApi: $e");
    return false;
  }
}