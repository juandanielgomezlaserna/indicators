import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraMetaApi.dart';

/// Modal para crear una nueva Meta de Ahorro
void newMetaModal(BuildContext context) {
  final nombreController = TextEditingController();
  final montoObjetivoController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Global.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
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
              "Nueva Meta de Ahorro",
              style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nombreController,
              style: TextStyle(color: Global.text),
              decoration: InputDecoration(
                labelText: "Nombre del objetivo (Ej. Teclado, Viaje)",
                labelStyle: TextStyle(color: Global.sutil),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: montoObjetivoController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Global.text),
              decoration: InputDecoration(
                labelText: "Monto Objetivo (\$)",
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
                  final nombre = nombreController.text.trim();
                  final monto = double.tryParse(montoObjetivoController.text) ?? 0;

                  if (nombre.isNotEmpty && monto > 0) {
                    final ok = await createMetaApi(nombre: nombre, montoObjetivo: monto);
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Guardar Meta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      );
    },
  );
}

/// Modal para realizar un depósito a la meta de ahorro
void depositarMetaModal(BuildContext context, {required int metaId, required String nombreMeta, required double montoObjetivo, required double montoActual}) {
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
                  "Abonar a $nombreMeta",
                  style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Llevas \$${montoActual.toStringAsFixed(0)} de \$${montoObjetivo.toStringAsFixed(0)}",
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
                    labelText: "Monto a Guardar",
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
                        final ok = await depositarAMetaApi(
                          metaId: metaId,
                          bolsilloId: bolsilloSeleccionado!,
                          monto: monto,
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text("Confirmar Depósito", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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