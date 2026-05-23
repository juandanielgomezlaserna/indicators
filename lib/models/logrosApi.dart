import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

Future<void> getLogros () async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}logro")
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
    controller.setLogros(result["data"]);
  }else{
    print("Error al obtener los logros: ${response.body}");
  }
}

Future<void> getLogrosPendientes () async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}logro/pendiente")
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
    controller.setLogros(result["data"]);
  }else{
    print("Error al obtener los logros: ${response.body}");
  }
}

Future<bool> newLogroApi(String nombre, int puntos, int idIndicador) async {
  try {
    final response = await http.post(
      Uri.parse("${Global.baseUrl}logro"),
      headers: {
        "Content-Type": "application/json", // 2. ESTO ES LO MÁS IMPORTANTE
      },
      // 3. Serializa el cuerpo con jsonEncode
      body: jsonEncode({
        "nombre": nombre,
        "puntos": puntos,
        "idIndicador": idIndicador
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Error de API: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción atrapada: $e");
    return false;
  }
}

// En tu archivo de API (getApi_21.dart o similar)
Future<bool> updateCheckLogro(int id) async {
  try {
    final response = await http.patch(
      Uri.parse("${Global.baseUrl}logro/check/$id"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Error en PATCH: $e");
    return false;
  }
}