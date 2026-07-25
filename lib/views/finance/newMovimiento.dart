import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraMovimientoApi.dart';

void newMovimientoModal(BuildContext context, {String tipoInicial = 'gasto'}) {
  final TextEditingController montoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  // Variables de estado local para el modal
  String tipoSeleccionado = tipoInicial; // 'gasto' o 'ingreso'
  int? bolsilloIdSeleccionado = controller.bolsillos.isNotEmpty
      ? controller.bolsillos.first['id']
      : null;
  String categoriaSeleccionada = 'Varios';

  final List<String> categoriasGasto = [
    'Comida / Alimentación',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Compras',
    'Salud',
    'Varios'
  ];

  final List<String> categoriasIngreso = [
    'Sueldo / Salario',
    'Ventas',
    'Transferencia',
    'Regalo',
    'Otros Ingresos'
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Global.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          final categoriasActuales = tipoSeleccionado == 'gasto'
              ? categoriasGasto
              : categoriasIngreso;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER DEL MODAL ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Registrar Movimiento",
                        style: GoogleFonts.poppins(
                          color: Global.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: Global.sutil),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- TOGGLE TIPO (GASTO / INGRESO) ---
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setStateModal(() {
                              tipoSeleccionado = 'gasto';
                              categoriaSeleccionada = categoriasGasto.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: tipoSeleccionado == 'gasto'
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : Global.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: tipoSeleccionado == 'gasto'
                                    ? Colors.redAccent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Gasto",
                                style: TextStyle(
                                  color: tipoSeleccionado == 'gasto'
                                      ? Colors.redAccent
                                      : Global.sutil,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setStateModal(() {
                              tipoSeleccionado = 'ingreso';
                              categoriaSeleccionada = categoriasIngreso.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: tipoSeleccionado == 'ingreso'
                                  ? Global.action.withOpacity(0.2)
                                  : Global.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: tipoSeleccionado == 'ingreso'
                                    ? Global.action
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Ingreso",
                                style: TextStyle(
                                  color: tipoSeleccionado == 'ingreso'
                                      ? Global.action
                                      : Global.sutil,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- MONTO ---
                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Global.text, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Monto (\$)",
                      labelStyle: TextStyle(color: Global.sutil),
                      filled: true,
                      fillColor: Global.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.attach_money_rounded, color: Global.action),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- SELECTOR DE BOLSILLO ---
                  DropdownButtonFormField<int>(
                    value: bolsilloIdSeleccionado,
                    dropdownColor: Global.card,
                    style: TextStyle(color: Global.text, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Afectar Bolsillo",
                      labelStyle: TextStyle(color: Global.sutil),
                      filled: true,
                      fillColor: Global.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: Global.action),
                    ),
                    items: controller.bolsillos.map<DropdownMenuItem<int>>((bolsillo) {
                      return DropdownMenuItem<int>(
                        value: bolsillo['id'],
                        child: Text("${bolsillo['nombre']} (\$${bolsillo['balance']})"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateModal(() {
                        bolsilloIdSeleccionado = val;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- SELECTOR DE CATEGORÍA ---
                  DropdownButtonFormField<String>(
                    value: categoriasActuales.contains(categoriaSeleccionada)
                        ? categoriaSeleccionada
                        : categoriasActuales.first,
                    dropdownColor: Global.card,
                    style: TextStyle(color: Global.text, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Categoría",
                      labelStyle: TextStyle(color: Global.sutil),
                      filled: true,
                      fillColor: Global.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.category_rounded, color: Global.action),
                    ),
                    items: categoriasActuales.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateModal(() {
                          categoriaSeleccionada = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- DESCRIPCIÓN (OPCIONAL) ---
                  TextField(
                    controller: descripcionController,
                    style: TextStyle(color: Global.text, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Descripción (Opcional)",
                      labelStyle: TextStyle(color: Global.sutil),
                      filled: true,
                      fillColor: Global.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.description_rounded, color: Global.sutil),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- BOTÓN GUARDAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.action,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final double? monto = double.tryParse(montoController.text);

                        if (monto == null || monto <= 0) {
                          Get.snackbar("Atención", "Ingresa un monto válido",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orangeAccent,
                              colorText: Colors.white);
                          return;
                        }

                        if (bolsilloIdSeleccionado == null) {
                          Get.snackbar("Atención", "Selecciona un bolsillo",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orangeAccent,
                              colorText: Colors.white);
                          return;
                        }

                        // Llamada a la API creada anteriormente
                        bool exito = await createMovimientoApi(
                          bolsilloId: bolsilloIdSeleccionado!,
                          tipo: tipoSeleccionado,
                          monto: monto,
                          categoria: categoriaSeleccionada,
                          descripcion : descripcionController.text.trim(),
                        );

                        if (exito) {
                          Navigator.pop(context);
                          Get.snackbar("¡Éxito!", "Movimiento registrado correctamente",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white);
                        } else {
                          Get.snackbar("Error", "No se pudo registrar el movimiento",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                        }
                      },
                      child: Text(
                        "Guardar Movimiento",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}