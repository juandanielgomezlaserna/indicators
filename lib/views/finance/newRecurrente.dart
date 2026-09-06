import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraRecurrenteApi.dart';

/// Modal BottomSheet para registrar una Transacción Recurrente
void newRecurrenteModal(BuildContext context) {
  final descripcionController = TextEditingController();
  final montoController = TextEditingController();
  String tipoSeleccionado = 'gasto';
  String frecuenciaSeleccionada = 'mensual';

  // Por defecto, asignamos el primer bolsillo de la lista
  int? bolsilloSeleccionado = controller.bolsillos.isNotEmpty
      ? int.tryParse(controller.bolsillos.first['id']?.toString() ?? '')
      : null;

  // Fecha por defecto: hoy en formato YYYY-MM-DD
  DateTime fechaProxima = DateTime.now();

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nueva Transacción Recurrente",
                    style: TextStyle(
                      color: Global.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Selector Tipo: Gasto / Ingreso
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Gasto Fijo")),
                          selected: tipoSeleccionado == 'gasto',
                          selectedColor: Colors.redAccent.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: tipoSeleccionado == 'gasto' ? Colors.redAccent : Global.sutil,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => tipoSeleccionado = 'gasto');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("Ingreso Fijo")),
                          selected: tipoSeleccionado == 'ingreso',
                          selectedColor: Global.action.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: tipoSeleccionado == 'ingreso' ? Global.action : Global.sutil,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => tipoSeleccionado = 'ingreso');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Descripción (ej. Netflix, Arriendo, Salario)
                  TextField(
                    controller: descripcionController,
                    style: TextStyle(color: Global.text),
                    decoration: InputDecoration(
                      labelText: "Descripción (Ej. Netflix, Arriendo)",
                      labelStyle: TextStyle(color: Global.sutil),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Monto y Categoría
                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Global.text),
                    decoration: InputDecoration(
                      labelText: "Monto (\$)",
                      labelStyle: TextStyle(color: Global.sutil),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.action)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Selección de Frecuencia
                  DropdownButtonFormField<String>(
                    value: frecuenciaSeleccionada,
                    dropdownColor: Global.card,
                    style: TextStyle(color: Global.text),
                    decoration: InputDecoration(
                      labelText: "Frecuencia",
                      labelStyle: TextStyle(color: Global.sutil),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'diario', child: Text("Diario")),
                      DropdownMenuItem(value: 'semanal', child: Text("Semanal")),
                      DropdownMenuItem(value: 'quincenal', child: Text("Quincenal")),
                      DropdownMenuItem(value: 'mensual', child: Text("Mensual")),
                      DropdownMenuItem(value: 'anual', child: Text("Anual")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => frecuenciaSeleccionada = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selección de Bolsillo Asociado
                  DropdownButtonFormField<int>(
                    value: bolsilloSeleccionado,
                    dropdownColor: Global.card,
                    style: TextStyle(color: Global.text),
                    decoration: InputDecoration(
                      labelText: "Bolsillo Afectado",
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

                  // Selector de Próximo Vencimiento
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaProxima,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => fechaProxima = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Próxima Ejecución / Vencimiento",
                        labelStyle: TextStyle(color: Global.sutil),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Global.sutil)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${fechaProxima.year}-${fechaProxima.month.toString().padLeft(2, '0')}-${fechaProxima.day.toString().padLeft(2, '0')}",
                            style: TextStyle(color: Global.text),
                          ),
                          Icon(Icons.calendar_today_rounded, color: Global.action, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón de Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Global.action,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final desc = descripcionController.text.trim();
                        final monto = double.tryParse(montoController.text) ?? 0;
                        final fechaStr = "${fechaProxima.year}-${fechaProxima.month.toString().padLeft(2, '0')}-${fechaProxima.day.toString().padLeft(2, '0')}";

                        if (desc.isNotEmpty && monto > 0 && desc.isNotEmpty && bolsilloSeleccionado != null) {
                          final ok = await createRecurrenteApi(
                            monto: monto,
                            tipo: tipoSeleccionado,
                            categoria: desc,
                            frecuencia: frecuenciaSeleccionada,
                            bolsilloId: bolsilloSeleccionado!,
                            proximaEjecucion: fechaStr,
                            diaPago: fechaProxima.day,
                          );

                          if (ok && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text(
                        "Guardar Programación",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}