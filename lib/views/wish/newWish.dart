// Función ágil para llamar al modal desde cualquier parte sin BuildContext
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/utils/widgetsApp.dart';

void newWish(int idIndicator) {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();

  // Variable local para controlar el estado de carga
  bool isLoading = false;

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
                    "Nuevo deseo",
                    style: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "Nombre", label: "Nombre del deseo"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- Botón de Acción con Carga Progresiva ---
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.action,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      // Si está cargando, desactivamos el onPressed pasando null
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (formKey.currentState!.validate()) {
                          // 1. Cambiamos el estado a cargando y refrescamos el botón
                          setModalState(() {
                            isLoading = true;
                          });

                          try {
                            // 2. Ejecutamos la petición al controlador
                            await controller.newWishController(
                              nombreController.text.trim(),
                              idIndicator, // Usamos el parámetro directo que recibe la función
                            );

                            // 3. Si todo sale bien, cerramos el modal
                            Get.back();
                          } catch (e) {
                            print("Error al guardar el deseo: $e");
                          } finally {
                            // 4. En caso de error, liberamos el botón por seguridad
                            if (Get.isDialogOpen ?? false) {
                              setModalState(() {
                                isLoading = false;
                              });
                            }
                          }
                        }
                      },
                      child: isLoading
                          ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Global.bg,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        "Guardar Deseo",
                        style: TextStyle(color: Global.bg, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}