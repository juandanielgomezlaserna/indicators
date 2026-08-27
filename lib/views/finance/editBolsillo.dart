import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/models/carteraBolsilloApi.dart';

void editBolsilloModal(BuildContext context, Map<String, dynamic> bolsilloData) {
  final TextEditingController nombreController = TextEditingController(text: bolsilloData['nombre'] ?? '');

  // Manejamos el balance actual como texto inicial
  final initialBalance = bolsilloData['balance'] != null ? bolsilloData['balance'].toString() : '0';
  final TextEditingController balanceController = TextEditingController(text: initialBalance);

  // Variable reactiva local inicializada con el tipo actual del bolsillo
  final RxString tipoSeleccionado = (bolsilloData['tipo'] as String? ?? 'debito').obs;

  // Estado local reactivo para manejar la carga y bloquear el botón
  final RxBool isLoading = false.obs;

  // Lista de tipos disponibles para el diseño
  final List<Map<String, dynamic>> tiposBolsillo = [
    {'id': 'debito', 'nombre': 'Débito', 'icon': Icons.payment_rounded},
    {'id': 'efectivo', 'nombre': 'Efectivo', 'icon': Icons.account_balance_wallet_rounded},
    {'id': 'credito', 'nombre': 'Crédito', 'icon': Icons.credit_card_rounded},
    {'id': 'ahorro', 'nombre': 'Ahorro', 'icon': Icons.savings_rounded},
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Global.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste para que el teclado no tape el modal
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "editar bolsillo",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Global.text,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Global.sutil),
                  )
                ],
              ),
              const SizedBox(height: 15),

              // Campo de Nombre
              Text(
                "nombre del bolsillo",
                style: TextStyle(color: Global.sutil, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nombreController,
                style: TextStyle(color: Global.text),
                decoration: InputDecoration(
                  hintText: "Ej: Bancolombia, Mi billetera...",
                  hintStyle: TextStyle(color: Global.sutil.withOpacity(0.5)),
                  filled: true,
                  fillColor: Global.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selector de Tipo de Bolsillo
              Text(
                "tipo de bolsillo",
                style: TextStyle(color: Global.sutil, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tiposBolsillo.map((tipo) {
                  final bool seleccionado = tipoSeleccionado.value == tipo['id'];
                  return GestureDetector(
                    onTap: () {
                      tipoSeleccionado.value = tipo['id'];
                    },
                    child: Container(
                      width: 75,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: seleccionado ? Global.action.withOpacity(0.15) : Global.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: seleccionado ? Global.action : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            tipo['icon'],
                            color: seleccionado ? Global.action : Global.sutil,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tipo['nombre'],
                            style: TextStyle(
                              color: seleccionado ? Global.action : Global.sutil,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: 20),

              // Campo de Saldo
              Text(
                "saldo actual (pesos colombianos)",
                style: TextStyle(color: Global.sutil, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                decoration: InputDecoration(
                  prefixText: "\$ ",
                  prefixStyle: TextStyle(color: Global.action, fontWeight: FontWeight.bold, fontSize: 18),
                  hintText: "0",
                  hintStyle: TextStyle(color: Global.sutil.withOpacity(0.5)),
                  filled: true,
                  fillColor: Global.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Actualizar envuelto en Obx para control de carga y bloqueo
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading.value
                      ? null // Se deshabilita mientras está cargando
                      : () async {
                    if (nombreController.text.trim().isEmpty) {
                      Get.snackbar(
                        "campo requerido",
                        "por favor ingresa un nombre para tu bolsillo",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    isLoading.value = true; // Activamos el estado de carga

                    try {
                      double balance = double.tryParse(balanceController.text) ?? 0.0;
                      int idBolsillo = bolsilloData['id'];

                      bool actualizado = await updateBolsillo(
                        id: idBolsillo,
                        nombre: nombreController.text.trim(),
                        tipo: tipoSeleccionado.value,
                        balance: balance,
                      );

                      if (actualizado) {
                        Get.back(); // Cerramos el modal
                        Get.snackbar(
                          "¡éxito!",
                          "bolsillo actualizado correctamente",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          "error",
                          "no se pudo actualizar el bolsillo. Revisa tu conexión.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    } finally {
                      isLoading.value = false; // Restauramos por seguridad al terminar
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading.value
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "guardar cambios",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 10),

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
                      title: "eliminar bolsillo",
                      titleStyle: GoogleFonts.poppins(color: Global.text, fontWeight: FontWeight.bold, fontSize: 18),
                      middleText: "¿estás seguro de que deseas eliminar este bolsillo? Esta acción no se puede deshacer.",
                      middleTextStyle: GoogleFonts.inter(color: Global.text.withOpacity(0.8), fontSize: 14),
                      textConfirm: "sí, eliminar",
                      textCancel: "cancelar",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      cancelTextColor: Global.text,
                      onConfirm: () async {
                        int idBolsillo = bolsilloData['id'];

                        // Cerramos primero el diálogo de confirmación
                        Get.back();

                        // Ejecutamos la petición de eliminación
                        bool eliminado = await deleteBolsillo(idBolsillo);

                        if (eliminado) {
                          // Cerramos también el modal de edición principal si fue exitoso
                          Get.back();
                        }
                      },
                    );
                  },
                  child: Text(
                    "eliminar bolsillo",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      );
    },
  );
}