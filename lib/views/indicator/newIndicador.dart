import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/utils/widgetsApp.dart';

void newIndicador(context) {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final puntosController = TextEditingController();

  // Estado local reactivo para el ícono seleccionado en este diálogo
  final RxString selectedIcono = "corazon".obs;

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
              Text(
                "nuevo indicador",
                style: GoogleFonts.inter(color: Global.action, fontWeight: FontWeight.w600, fontSize: 25, letterSpacing: -1.5),
              ),
              const SizedBox(height: 20),

              // --- Campos de Texto ---
              TextFormField(
                decoration: Wapp.globalInput(hint: "nombre", label: "nombre del indicador"),
                controller: nombreController,
                style: TextStyle(color: Global.text),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'el nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: Wapp.globalInput(hint: "puntos", label: "puntos iniciales del indicador"),
                controller: puntosController,
                style: TextStyle(color: Global.text),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              Text(
                "icono",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Global.text),
              ),
              const SizedBox(height: 10),

              // --- Selector de Iconos Reactivo con Obx ---
              Center(
                child: SizedBox(
                  height: 150,
                  child: ShaderMask(
                    shaderCallback: (Rect rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.75, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      child: Obx(() => Wrap(
                        spacing: 30,
                        runSpacing: 10,
                        children: Global.iconsIndicators.keys.map((String nombreKey) {
                          return _iconCard(nombreKey, selectedIcono, context);
                        }).toList(),
                      )),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                      isLoading.value = true;
                      try {
                        await controller.newIndicadorController(
                          nombreController.text.trim(),
                          puntosController.text.trim(),
                          selectedIcono.value, // Extraemos el valor con .value
                        );
                        Get.back();
                      } finally {
                        isLoading.value = false;
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
    barrierDismissible: false,
  );
}

// Actualizamos el widget para que reciba la variable reactiva
Widget _iconCard(String icon, RxString selectedIcono, BuildContext context) {
  // Evaluamos de manera reactiva comparando el .value
  final bool isSelected = selectedIcono.value == icon;

  return GestureDetector(
    onTap: () {
      selectedIcono.value = icon; // Actualiza el estado reactivo al instante
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Global.action.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Global.action : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Icon(
        Global.iconsIndicators[icon] ?? CupertinoIcons.heart,
        size: 30,
        color: isSelected ? Global.action : null,
      ),
    ),
  );
}