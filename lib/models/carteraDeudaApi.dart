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
/**
 * Registra una nueva deuda (acreedor, monto inicial, saldo pendiente y opcionalmente un bolsillo)
 */
Future<bool> createDeudaApi({
  required String acreedor,
  required double montoInicial,
  double? montoPendiente,
  String tipo = 'cobrar',
  String? fechaLimitePago,
  int? bolsilloId, // <--- Nuevo parámetro opcional para vincular el bolsillo
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    print("ID DEL BOLSILLO: $bolsilloId");

    final url = Uri.parse('${Global.baseUrl}cartera-deudas');

    // Construimos el body incluyendo el bolsillo_id si el usuario lo seleccionó
    final Map<String, dynamic> bodyData = {
      'acreedor_deudor': acreedor,
      'monto_total': montoInicial,
      'monto_pendiente': montoPendiente ?? montoInicial,
      'tipo': tipo,
      'fecha_limite_pago': fechaLimitePago,
    };

    if (bolsilloId != null) {
      bodyData['bolsillo_id'] = bolsilloId;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(bodyData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Al crear una deuda que afecta un bolsillo, refrescamos ambos estados en la UI
        await getDeudasApi();
        if (bolsilloId != null) {
          await getBolsillos(); // Asegúrate de tener esta función importada para refrescar saldos
        }
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

    final url = Uri.parse('${Global.baseUrl}cartera-deudas/$deudaId/abono');

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

/**
 * Actualiza una deuda existente enviando los campos modificados al backend.
 */
Future<bool> updateDeudaApi({
  required int deudaId,
  String? acreedor,
  double? montoInicial,
  double? montoPendiente,
  String? tipo,
  String? fechaLimitePago,
  int? bolsilloId, // <--- Añadir soporte para edición de bolsillo
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-deudas/$deudaId');

    final Map<String, dynamic> data = {};
    if (acreedor != null) data['acreedor_deudor'] = acreedor;
    if (montoInicial != null) data['monto_inicial'] = montoInicial;
    if (montoPendiente != null) data['monto_pendiente'] = montoPendiente;
    if (tipo != null) data['tipo'] = tipo;
    if (fechaLimitePago != null) data['fecha_limite_pago'] = fechaLimitePago;
    if (bolsilloId != null) data['bolsillo_id'] = bolsilloId; // <--- Incluir en el payload si viene informado

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
        await getDeudasApi();
        return true;
      }
    } else {
      print("Error al actualizar deuda: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en updateDeudaApi: $e");
    return false;
  }
}

Future<bool> deleteDeudaApi({required int deudaId}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-deudas/$deudaId');

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
        // Refrescamos la lista de deudas para actualizar la interfaz
        await getDeudasApi();
        return true;
      }
    } else {
      print("Error al eliminar deuda: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en deleteDeudaApi: $e");
    return false;
  }
}