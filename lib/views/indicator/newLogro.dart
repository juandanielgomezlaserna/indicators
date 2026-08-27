// Función ágil para llamar al modal desde cualquier parte sin BuildContext
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/utils/widgetsApp.dart';

void newLogro(int idIndicator) {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final puntosController = TextEditingController();

  final RxBool isLoading = false.obs;
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
              Text(
                "nuevo logro",
                style: GoogleFonts.inter(color: Global.action, fontWeight: FontWeight.w600, fontSize: 25, letterSpacing: -1.5),
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "nombre", label: "nombre del logro"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: Wapp.globalInput(hint: "puntos", label: "puntos que suma el indicador"),
                controller: puntosController,
                style: TextStyle(color: Global.text),
                keyboardType: TextInputType.number, // Teclado numérico para mayor velocidad del usuario
              ),
              const SizedBox(height: 25),

              // --- Botón de Acción ---
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading.value
                      ? null
                      : () async {
                    if (formKey.currentState!.validate()) {
                      isLoading.value = true; // Bloquea y activa el loader
                      try {
                        await controller.newLogroController(
                          nombreController.text.trim(),
                          puntosController.text.trim(),
                          idIndicator,
                        );
                        Get.back(); // Cierra el modal solo si se guarda con éxito
                      } finally {
                        isLoading.value = false; // Restaura por seguridad si ocurre un error
                      }
                    }
                  },
                  child: Text(
                    "guardar logro",
                    style: TextStyle(color: Global.bg, fontWeight: FontWeight.bold),
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}