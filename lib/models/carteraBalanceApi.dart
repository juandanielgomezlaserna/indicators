import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';

Future<Map<String, dynamic>?> getResumenBalanceApi(String usuario) async {
  try {
    final url = Uri.parse('${Global.baseUrl}cartera-balance/resumen/$usuario');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData['status'] == 'success') {
        return decodedData['data'];
      }
    }
    print("⚠️ Error Server Balance [${response.statusCode}]: ${response.body}");
    return null;
  } catch (e) {
    print("❌ Excepción en getResumenBalanceApi: $e");
    return null;
  }
}