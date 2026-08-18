import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/utils/widgetsApp.dart';

/**
 * Función ágil para mostrar el modal de edición de un indicador.
 * Recibe el indicador actual para rellenar los campos por defecto.
 */
void editIndicador(Map<String, dynamic> indicadorActual) {
  final formKey = GlobalKey<FormState>();

  // Pre-cargamos los controladores con los valores existentes
  final nombreController = TextEditingController(text: indicadorActual['nombre'] ?? '');
  final valorController = TextEditingController(text: indicadorActual['valor']?.toString() ?? '0');

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
                    "editar indicador",
                    style: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "nombre", label: "nombre del indicador"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: Wapp.globalInput(hint: "valor", label: "valor del indicador"),
                controller: valorController,
                style: TextStyle(color: Global.text),
                keyboardType: TextInputType.number, // Teclado numérico
              ),
              const SizedBox(height: 25),

              // --- Botón de Acción: Actualizar ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    int idIndicador = indicadorActual['id'];
                    int parsedValor = int.tryParse(valorController.text) ?? 0;

                    await updateIndicator(
                      idIndicador,
                      nombre: nombreController.text,
                      valor: parsedValor,
                    );

                    Get.back(); // Cierra el modal al terminar
                  },
                  child: Text(
                    "actualizar indicador",
                    style: TextStyle(color: Global.bg, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Botón de Acción: Eliminar con Confirmación ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Diálogo de confirmación antes de eliminar
                    Get.defaultDialog(
                      backgroundColor: Global.card,
                      title: "eliminar indicador",
                      titleStyle: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                      middleText: "¿estás seguro de que deseas eliminar este indicador? Esta acción no se puede deshacer.",
                      middleTextStyle: GoogleFonts.inter(color: Global.text.withOpacity(0.8), fontSize: 14),
                      textConfirm: "sí, eliminar",
                      textCancel: "cancelar",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      cancelTextColor: Global.text,
                      onConfirm: () async {
                        int idIndicador = indicadorActual['id'];

                        // Cerramos primero el diálogo de confirmación
                        Get.back();

                        // Ejecutamos la petición de eliminación
                        bool eliminado = await deleteIndicator(idIndicador);

                        if (eliminado) {
                          // Cerramos también el modal de edición principal si fue exitoso
                          Get.back();
                        }
                      },
                    );
                  },
                  child: Text(
                    "eliminar indicador",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
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