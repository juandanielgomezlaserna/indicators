import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraMetaApi.dart';

/// Modal para editar o eliminar una meta de ahorro existente
void editarMetaModal(
    BuildContext context, {
      required int metaId,
      required String nombreActual,
      required double montoObjetivoActual,
      required double montoActualActual,
      int? bolsilloOrigenIdActual,
    }) {
  final nombreController = TextEditingController(text: nombreActual);
  final montoObjetivoController = TextEditingController(text: montoObjetivoActual.toString());
  final montoActualController = TextEditingController(text: montoActualActual.toString());

  int? bolsilloSeleccionado = bolsilloOrigenIdActual;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Editar Meta",
                      style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        // Diálogo de confirmación antes de eliminar
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Global.card,
                            title: Text("Eliminar Meta", style: TextStyle(color: Global.text)),
                            content: Text("¿Estás seguro de que deseas eliminar esta meta?", style: TextStyle(color: Global.sutil)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancelar", style: TextStyle(color: Global.sutil)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          final ok = await deleteMetaApi(metaId: metaId);
                          if (ok && context.mounted) {
                            Navigator.pop(context); // Cierra el modal de edición
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nombreController,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Nombre del objetivo",
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
                const SizedBox(height: 12),
                TextField(
                  controller: montoActualController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto Actual (\$)",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: bolsilloSeleccionado,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Bolsillo de Origen (Opcional)",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text("Ninguno"),
                    ),
                    ...controller.bolsillos.map<DropdownMenuItem<int?>>((b) {
                      final id = int.parse(b['id'].toString());
                      return DropdownMenuItem<int?>(
                        value: id,
                        child: Text("${b['nombre']} (\$${b['balance']})"),
                      );
                    }),
                  ],
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
                      final nombre = nombreController.text.trim();
                      final montoObjetivo = double.tryParse(montoObjetivoController.text);
                      final montoActual = double.tryParse(montoActualController.text);

                      if (nombre.isNotEmpty) {
                        final ok = await updateMetaApi(
                          metaId: metaId,
                          nombre: nombre,
                          montoObjetivo: montoObjetivo,
                          montoActual: montoActual,
                          bolsilloOrigenId: bolsilloSeleccionado,
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text("Actualizar Meta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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