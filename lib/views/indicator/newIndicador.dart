import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/utils/widgetsApp.dart';

void newIndicador() {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final puntosController = TextEditingController();

  // Estado local reactivo para controlar la carga y evitar clics múltiples
  final RxBool isLoading = false.obs;

  Get.dialog(
    Dialog(
      backgroundColor: Global.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
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
                    "Nuevo indicador",
                    style: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "Nombre", label: "Nombre del indicador"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: Wapp.globalInput(hint: "Puntos", label: "Puntos iniciales del indicador"),
                controller: puntosController,
                style: TextStyle(color: Global.text),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // --- Botón de Acción con Obx para bloquearse y mostrar carga ---
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  // Si está cargando, deshabilitamos el onPressed poniendo null
                  onPressed: isLoading.value
                      ? null
                      : () async {
                    if (formKey.currentState!.validate()) {
                      isLoading.value = true; // Bloquea el botón y muestra loader
                      try {
                        await controller.newIndicadorController(
                          nombreController.text.trim(),
                          puntosController.text.trim(),
                        );
                        Get.back(); // Cierra el modal solo si todo sale bien
                      } finally {
                        isLoading.value = false; // Restaura por si ocurre algún error
                      }
                    }
                  },
                  child: isLoading.value
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Global.bg,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Guardar Logro",
                    style: TextStyle(color: Global.bg, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false, // Evita que se cierre por accidente tocando fuera mientras guarda
  );
}