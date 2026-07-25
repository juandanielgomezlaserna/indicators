import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/models/carteraBolsilloApi.dart'; // Importamos el API que creamos antes

void newBolsilloModal(BuildContext context) {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  // Variable reactiva local para controlar el tipo seleccionado en el modal
  final RxString tipoSeleccionado = 'debito'.obs;

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
                    "Crear Nuevo Bolsillo",
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
                "Nombre del Bolsillo",
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
                "Tipo de Bolsillo",
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

              // Campo de Saldo Inicial
              Text(
                "Saldo Inicial (Pesos Colombianos)",
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

              // Botón de Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nombreController.text.trim().isEmpty) {
                      Get.snackbar(
                        "Campo requerido",
                        "Por favor ingresa un nombre para tu bolsillo",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // 1. Obtienes el balance como double
                    double balance = double.tryParse(balanceController.text) ?? 0.0;

                    // 2. Llamas a la función sin pasarle el usuario (la función lo lee sola internamente)
                    bool creado = await createBolsillo(
                      nombre: nombreController.text.trim(),
                      tipo: tipoSeleccionado.value,
                      balance: balance,
                    );

                    if (creado) {
                      Get.back(); // Cerramos el modal
                      Get.snackbar(
                        "¡Éxito!",
                        "Bolsillo creado correctamente",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        "Error",
                        "No se pudo crear el bolsillo. Revisa tu conexión.",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Crear Bolsillo",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}