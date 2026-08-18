/**
 * Función ágil para llamar al modal de edición de un logro desde cualquier parte sin BuildContext.
 * Recibe el logro actual para rellenar los campos (initialValues).
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/utils/widgetsApp.dart';

void editLogro(Map<String, dynamic> logro) {
  final formKey = GlobalKey<FormState>();

  // Extraemos los valores actuales del logro recibido
  final int logroId = logro['id'];
  final int idIndicator = logro['idIndicador'];

  final nombreController = TextEditingController(text: logro['nombre'] ?? '');
  final puntosController = TextEditingController(text: logro['puntos']?.toString() ?? '');

  Get.dialog(
    Dialog(
      backgroundColor: Global.card, // Fondo oscuro para mantener tu estética
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            // ¡CRÍTICO PARA MODALES! Evita que el Column explote la pantalla
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Cabecera del Modal ---
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    color: Global.action,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Editar Logro",
                    style: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto con datos precargados ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "Nombre", label: "Nombre del logro"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: Wapp.globalInput(hint: "Puntos", label: "Puntos que suma el indicador"),
                controller: puntosController,
                style: TextStyle(color: Global.text),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Introduce un número entero positivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // --- Botón de Acción ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final String nombre = nombreController.text.trim();
                      final int puntos = int.parse(puntosController.text.trim());

                      // Llamas a tu controlador o función de actualización por PUT
                      bool actualizado = await updateLogroApi(logroId, nombre, puntos, idIndicator);

                      if (actualizado) {
                        Get.back(); // Cierra el modal al completarse con éxito
                      }
                    }
                  },
                  child: Text(
                    "Actualizar Logro",
                    style: TextStyle(color: Global.bg, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true, // Permite cerrar tocando afuera
  );
}