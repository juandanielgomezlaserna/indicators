import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraDeudaApi.dart';

/// Modal para editar una deuda existente
void editarDeudaModal(
    BuildContext context, {
      required int deudaId,
      required String acreedorActual,
      required double montoInicialActual,
      required double montoPendienteActual,
      String tipoActual = 'cobrar',
    }) {
  final acreedorController = TextEditingController(text: acreedorActual);
  final montoInicialController = TextEditingController(
    text: montoInicialActual.toStringAsFixed(0),
  );
  final montoPendienteController = TextEditingController(
    text: montoPendienteActual.toStringAsFixed(0),
  );

  String tipoSeleccionado = tipoActual;

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
                  "Editar Deuda",
                  style: TextStyle(
                    color: Global.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: acreedorController,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Acreedor",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.sutil),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.action),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoInicialController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto Inicial",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.sutil),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.action),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoPendienteController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto Pendiente",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.sutil),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.action),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.sutil),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Global.action),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'cobrar',
                      child: Text('Por Cobrar'),
                    ),
                    DropdownMenuItem(value: 'pagar', child: Text('Por Pagar')),
                    DropdownMenuItem(
                      value: 'no_obligatoria',
                      child: Text('No Obligatoria'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => tipoSeleccionado = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Global.action,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final acreedor = acreedorController.text.trim();
                      final montoInicial = double.tryParse(
                        montoInicialController.text,
                      );
                      final montoPendiente = double.tryParse(
                        montoPendienteController.text,
                      );

                      if (acreedor.isNotEmpty) {
                        final ok = await updateDeudaApi(
                          deudaId: deudaId,
                          acreedor: acreedor,
                          montoInicial: montoInicial,
                          montoPendiente: montoPendiente,
                          tipo: tipoSeleccionado,
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text(
                      "Actualizar Deuda",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final ok = await deleteDeudaApi(deudaId: deudaId);
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Eliminar Deuda",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}