import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraTransferenciaApi.dart';

void newTransferenciaModal(BuildContext context) {
  final montoController = TextEditingController();
  final descripcionController = TextEditingController();

  if (controller.bolsillos.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Necesitas al menos 2 bolsillos para realizar una transferencia.')),
    );
    return;
  }

  int bolsilloOrigen = int.parse(controller.bolsillos[0]['id'].toString());
  int bolsilloDestino = int.parse(controller.bolsillos[1]['id'].toString());

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
                  "Transferir entre Bolsillos",
                  style: TextStyle(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Dropdown Origen
                DropdownButtonFormField<int>(
                  value: bolsilloOrigen,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Desde (Origen)",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: controller.bolsillos.map<DropdownMenuItem<int>>((b) {
                    return DropdownMenuItem<int>(
                      value: int.parse(b['id'].toString()),
                      child: Text("${b['nombre']} (\$${b['balance']})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => bolsilloOrigen = val);
                  },
                ),
                const SizedBox(height: 12),

                // Dropdown Destino
                DropdownButtonFormField<int>(
                  value: bolsilloDestino,
                  dropdownColor: Global.card,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Hacia (Destino)",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                  ),
                  items: controller.bolsillos.map<DropdownMenuItem<int>>((b) {
                    return DropdownMenuItem<int>(
                      value: int.parse(b['id'].toString()),
                      child: Text("${b['nombre']} (\$${b['balance']})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => bolsilloDestino = val);
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Monto a Transferir",
                    labelStyle: TextStyle(color: Global.sutil),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: descripcionController,
                  style: TextStyle(color: Global.text),
                  decoration: InputDecoration(
                    labelText: "Nota / Descripción (Opcional)",
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
                      if (bolsilloOrigen == bolsilloDestino) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El bolsillo de origen y destino deben ser diferentes.')),
                        );
                        return;
                      }

                      if (monto > 0) {
                        final ok = await realizarTransferenciaApi(
                          bolsilloOrigenId: bolsilloOrigen,
                          bolsilloDestinoId: bolsilloDestino,
                          monto: monto,
                          descripcion: descripcionController.text.trim(),
                        );
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text("Confirmar Transferencia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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