import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraDeudaApi.dart';

void newDeudaModal(BuildContext context) {
  final acreedorController = TextEditingController();
  final montoController = TextEditingController();

  // Estado para el tipo de deuda y el bolsillo opcional
  String tipoSeleccionado = 'cobrar';
  int? bolsilloSeleccionado = controller.bolsillos.isNotEmpty
      ? int.tryParse(controller.bolsillos.first['id']?.toString() ?? '')
      : null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Global.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nueva Deuda",
                  style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: acreedorController,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Acreedor / Deudor",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto Inicial",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Tipo de Deuda",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cobrar', child: Text("Por Cobrar (Me deben)")),
                    DropdownMenuItem(value: 'pagar', child: Text("Por Pagar (Debo)")),
                    DropdownMenuItem(value: 'no_obligatoria', child: Text("No Obligatoria")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => tipoSeleccionado = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: bolsilloSeleccionado,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Bolsillo Afectado (Opcional)",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: controller.bolsillos.map<DropdownMenuItem<int>>((b) {
                    final id = int.parse(b['id'].toString());
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text("${b['nombre']} (\$${b['balance']})"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => bolsilloSeleccionado = val),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Global.action,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final acreedor = acreedorController.text.trim();
                      final monto = double.tryParse(montoController.text) ?? 0;

                      if (acreedor.isNotEmpty && monto > 0) {
                        final ok = await createDeudaApi(
                          acreedor: acreedor,
                          montoInicial: monto,
                          tipo: tipoSeleccionado,
                          bolsilloId: bolsilloSeleccionado,
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text("Guardar Deuda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}

/// Modal para realizar un abono a la deuda
void abonarDeudaModal(BuildContext context, {required int deudaId, required String acreedor, required double montoPendiente}) {
  final montoController = TextEditingController();
  int? bolsilloSeleccionado = controller.bolsillos.isNotEmpty
      ? int.tryParse(controller.bolsillos.first['id']?.toString() ?? '')
      : null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Global.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Abonar a $acreedor",
                  style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Saldo pendiente: \$${montoPendiente.toStringAsFixed(0)}",
                  style: TextStyle(color: Global.sutil, fontSize: 12),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: bolsilloSeleccionado,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Bolsillo de Origen",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: controller.bolsillos.map<DropdownMenuItem<int>>((b) {
                    final id = int.parse(b['id'].toString());
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text("${b['nombre']} (\$${b['balance']})"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => bolsilloSeleccionado = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto a Abonar",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Global.action,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final monto = double.tryParse(montoController.text) ?? 0;

                      if (bolsilloSeleccionado != null && monto > 0) {
                        final ok = await abonarDeudaApi(
                          deudaId: deudaId,
                          bolsilloId: bolsilloSeleccionado!,
                          monto: monto,
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text("Confirmar Abono", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}