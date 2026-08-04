import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditarRecurrenteModal extends StatefulWidget {
  final Map<String, dynamic> recurrente;
  final Function(Map<String, dynamic> datosActualizados) onGuardar;

  const EditarRecurrenteModal({
    Key? key,
    required this.recurrente,
    required this.onGuardar,
  }) : super(key: key);

  @override
  State<EditarRecurrenteModal> createState() => _EditarRecurrenteModalState();
}

class _EditarRecurrenteModalState extends State<EditarRecurrenteModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descripcionController;
  late TextEditingController _montoController;

  late String _frecuenciaSeleccionada;
  late String _categoriaSeleccionada;
  late DateTime _proximaEjecucion;
  int? _bolsilloIdSeleccionado;
  late bool _activo;

  final List<String> _frecuencias = ['diario', 'semanal', 'quincenal', 'mensual', 'anual'];
  final List<String> _categorias = ['Vivienda', 'Suscripciones', 'Servicios', 'Alimentación', 'Educación', 'Otros'];

  // Simulación de lista de bolsillos (Ajustar según tu Controller/State)
  final List<Map<String, dynamic>> _bolsillosDisponibles = [
    {'id': 1, 'nombre': 'Alcancía'},
    {'id': 2, 'nombre': 'Ahorros'},
    {'id': 3, 'nombre': 'Efectivo'},
  ];

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.recurrente['descripcion'] ?? '');
    _montoController = TextEditingController(text: widget.recurrente['monto']?.toString() ?? '0');

    _frecuenciaSeleccionada = _frecuencias.firstWhere(
          (f) => f.toLowerCase() == (widget.recurrente['frecuencia'] ?? '').toString().toLowerCase(),
      orElse: () => 'Mensual',
    );

    _categoriaSeleccionada = _categorias.contains(widget.recurrente['categoria'])
        ? widget.recurrente['categoria']
        : 'Otros';

    _proximaEjecucion = DateTime.tryParse(widget.recurrente['proxima_ejecucion'] ?? '') ?? DateTime.now();
    _bolsilloIdSeleccionado = widget.recurrente['bolsillo_id'];
    _activo = widget.recurrente['activo'] ?? true;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _proximaEjecucion,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1DE9B6),
              onPrimary: Colors.black,
              surface: Color(0xFF1E2630),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _proximaEjecucion) {
      setState(() {
        _proximaEjecucion = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fechaFormateada = DateFormat('yyyy-MM-dd').format(_proximaEjecucion);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161C24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Editar Recurrente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo: Descripción
              TextFormField(
                controller: _descripcionController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Descripción", Icons.edit_note_rounded),
                validator: (val) => val == null || val.isEmpty ? "Ingresa un nombre o concepto" : null,
              ),
              const SizedBox(height: 12),

              // Campo: Monto
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Monto", Icons.attach_money_rounded),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingresa el monto";
                  if (double.tryParse(val) == null || double.parse(val) <= 0) return "Monto inválido";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Fila: Frecuencia y Categoría
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _frecuenciaSeleccionada,
                      dropdownColor: const Color(0xFF1E2630),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration("Frecuencia", Icons.update_rounded),
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (val) => setState(() => _frecuenciaSeleccionada = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada,
                      dropdownColor: const Color(0xFF1E2630),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration("Categoría", Icons.category_rounded),
                      items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Selección de Bolsillo
              DropdownButtonFormField<int>(
                value: _bolsilloIdSeleccionado,
                dropdownColor: const Color(0xFF1E2630),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _inputDecoration("Bolsillo Afectado", Icons.account_balance_wallet_rounded),
                items: _bolsillosDisponibles.map((b) {
                  return DropdownMenuItem<int>(
                    value: b['id'] as int,
                    child: Text(b['nombre'].toString()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _bolsilloIdSeleccionado = val),
                validator: (val) => val == null ? "Selecciona un bolsillo" : null,
              ),
              const SizedBox(height: 12),

              // Fecha de Próxima Ejecución
              InkWell(
                onTap: () => _seleccionarFecha(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2630),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1DE9B6)),
                          const SizedBox(width: 10),
                          Text(
                            "Próximo Cobro: $fechaFormateada",
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Switch Activo / Inactivo
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF1DE9B6),
                title: const Text("Suscripción Activa", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text("Pausar para congelar cobros futuros", style: TextStyle(color: Colors.grey, fontSize: 11)),
                value: _activo,
                onChanged: (val) => setState(() => _activo = val),
              ),
              const SizedBox(height: 16),

              // Botón Guardar Cambios
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DE9B6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final datosEditados = {
                        'id': widget.recurrente['id'],
                        'descripcion': _descripcionController.text.trim(),
                        'monto': double.parse(_montoController.text.trim()),
                        'frecuencia': _frecuenciaSeleccionada,
                        'categoria': _categoriaSeleccionada,
                        'bolsillo_id': _bolsilloIdSeleccionado,
                        'proxima_ejecucion': fechaFormateada,
                        'activo': _activo,
                      };

                      widget.onGuardar(datosEditados);
                      Get.back();
                    }
                  },
                  child: const Text(
                    "Guardar Cambios",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1DE9B6), size: 18),
      filled: true,
      fillColor: const Color(0xFF1E2630),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1DE9B6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}