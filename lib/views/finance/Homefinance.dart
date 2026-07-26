import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraBolsilloApi.dart';
import 'package:indicator/models/carteraDeudaApi.dart';
import 'package:indicator/models/carteraMovimientoApi.dart';
import 'package:indicator/views/finance/newBolsillo.dart';
import 'package:indicator/views/finance/newDeuda.dart';
import 'package:indicator/views/finance/newMovimiento.dart';
import 'package:indicator/views/finance/newTransferencia.dart'; // Asegúrate de que aquí esté tu controlador global
// Importa tus llamadas de API o controladores de finanzas correspondientes

class Homefinance extends StatefulWidget {
  const Homefinance({super.key});

  @override
  State<Homefinance> createState() => _HomefinanceState();
}

class _HomefinanceState extends State<Homefinance> {
  @override
  void initState() {
    super.initState();
    getBolsillos();
    getMovimientosApi();
    getDeudasApi();
  }

  // Mapeo dinámico de íconos según el tipo de bolsillo de base de datos
  IconData getBolsilloIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'efectivo':
        return Icons.account_balance_wallet_rounded;
      case 'debito':
        return Icons.payment_rounded;
      case 'credito':
        return Icons.credit_card_rounded;
      case 'ahorro':
        return Icons.savings_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. TARJETA RESUMEN DE BANCO (Balance Neto & Indicador Semanal)
            Card(
              color: Global.card,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DINERO TOTAL DISPONIBLE",
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Global.sutil,
                          letterSpacing: 1.1
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      final double total = controller.bolsillos.fold<double>(
                        0.0,
                            (sum, b) => sum + (double.tryParse(b['balance']?.toString() ?? '0') ?? 0.0),
                      );

                      return Text(
                        "\$${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Global.text,
                        ),
                      );
                    }),
                    const SizedBox(height: 15),
                    Divider(color: Global.bg, thickness: 1.5),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Límite Semanal Recomendado",
                              style: TextStyle(fontSize: 11, color: Global.sutil),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "\$450.000", // TODO: Cálculo dinámico
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Global.action),
                            ),
                          ],
                        ),
                        // Pequeño indicador visual del estado semanal
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Global.action.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Estable",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Global.action),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 2. FILA DE ACCIONES RÁPIDAS (Estilo Neobanco)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: "Nuevo Bolsillo",
                  onTap: () {
                    newBolsilloModal(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.swap_horiz_rounded,
                  label: "Transferir",
                  onTap: () {
                    newTransferenciaModal(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.trending_down_rounded,
                  label: "Gasto",
                  onTap: () {
                    newMovimientoModal(context, tipoInicial: 'gasto');
                  },
                ),
                _buildActionButton(
                  icon: Icons.trending_up_rounded,
                  label: "Ingreso",
                  onTap: () {
                    newMovimientoModal(context, tipoInicial: 'ingreso');
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. SECCIÓN: MIS BOLSILLOS (Scroll Horizontal)
            Text(
              "Mis Bolsillos",
              style: GoogleFonts.poppins(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 125,
              child: Obx(() {
                // 1. Si la lista en el controlador está vacía, mostramos un estado vacío elegante
                if (controller.bolsillos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "No tienes bolsillos creados. ¡Crea el primero usando el botón de arriba!",
                        style: TextStyle(color: Global.sutil, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // 2. Si hay datos, recorremos la lista del controlador en tiempo real
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.bolsillos.length,
                  itemBuilder: (context, index) {
                    final bolsillo = controller.bolsillos[index];

                    // Extraemos y parseamos los valores de forma segura
                    final String nombre = bolsillo['nombre'] ?? 'Sin Nombre';
                    final String tipo = bolsillo['tipo'] ?? 'debito';
                    final double balance = double.tryParse(bolsillo['balance']?.toString() ?? '0') ?? 0.0;

                    return _buildBolsilloCard(
                      nombre: nombre,
                      tipo: tipo,
                      balance: balance,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 25),

            // 3.5. SECCIÓN: MIS DEUDAS (Scroll Horizontal o Lista)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mis Deudas",
                  style: GoogleFonts.poppins(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: Global.action),
                  onPressed: () {
                    newDeudaModal(context); // 👈 Abre modal para crear deuda
                  },
                )
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 140,
              child: Obx(() {
                if (controller.deudas.isEmpty) {
                  return Card(
                    color: Global.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "No tienes deudas registradas. ¡Excelente!",
                          style: TextStyle(color: Global.sutil, fontSize: 13),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.deudas.length,
                  itemBuilder: (context, index) {
                    final deuda = controller.deudas[index];

                    final int id = int.tryParse(deuda['id']?.toString() ?? '0') ?? 0;
                    final String acreedor = deuda['acreedor'] ?? 'Desconocido';
                    final double montoInicial = double.tryParse(deuda['monto_inicial']?.toString() ?? '0') ?? 0.0;
                    final double montoPendiente = double.tryParse(deuda['monto_pendiente']?.toString() ?? '0') ?? 0.0;

                    return _buildDeudaCard(
                      id: id,
                      acreedor: acreedor,
                      montoInicial: montoInicial,
                      montoPendiente: montoPendiente,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 25),

            // 4. HISTORIAL RECIENTE (Estilo extracto)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Actividad Reciente",
                  style: GoogleFonts.poppins(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.history_rounded, color: Global.sutil, size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Lista reactiva de transacciones
            Obx(() {
              if (controller.movimientos.isEmpty) {
                return Card(
                  color: Global.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        "No hay transacciones registradas este mes.",
                        style: TextStyle(color: Global.sutil, fontSize: 13),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.movimientos.length,
                itemBuilder: (context, index) {
                  final mov = controller.movimientos[index];
                  final bool esGasto = (mov['tipo'] ?? '').toString().toLowerCase() == 'gasto';
                  final double monto = double.tryParse(mov['monto']?.toString() ?? '0') ?? 0.0;

                  return Card(
                    color: Global.card,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esGasto ? Colors.redAccent.withOpacity(0.15) : Global.action.withOpacity(0.15),
                        child: Icon(
                          esGasto ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: esGasto ? Colors.redAccent : Global.action,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        mov['categoria'] ?? 'Sin categoría',
                        style: TextStyle(color: Global.text, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        "${mov['bolsillo_nombre'] ?? 'Bolsillo'} • ${mov['descripcion'] ?? ''}",
                        style: TextStyle(color: Global.sutil, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        "${esGasto ? '-' : '+'}\$${monto.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: TextStyle(
                          color: esGasto ? Colors.redAccent : Global.action,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget Auxiliar: Botones de Acción Rápida
  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Global.card,
            child: Icon(icon, color: Global.action, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: Global.text, fontSize: 11, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  // Widget Auxiliar: Tarjeta de cada bolsillo
  Widget _buildBolsilloCard({required String nombre, required String tipo, required double balance}) {
    final bool esNegativo = balance < 0;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Global.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                  getBolsilloIcon(tipo),
                  color: esNegativo ? Colors.redAccent : Global.action,
                  size: 28
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Global.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    esNegativo
                        ? "-\$${(balance.abs()).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"
                        : "\$${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: esNegativo ? Colors.redAccent : Global.text.withOpacity(0.9)
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget Auxiliar: Tarjeta de cada Deuda
  Widget _buildDeudaCard({
    required int id,
    required String acreedor,
    required double montoInicial,
    required double montoPendiente,
  }) {
    // Cálculo de porcentaje pagado
    final double pagado = montoInicial - montoPendiente;
    final double porcentaje = montoInicial > 0 ? (pagado / montoInicial).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Global.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      acreedor,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Global.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      abonarDeudaModal(context, deudaId: id, acreedor: acreedor, montoPendiente: montoPendiente);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Global.action.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Abonar",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Global.action),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pendiente:",
                    style: TextStyle(fontSize: 10, color: Global.sutil),
                  ),
                  Text(
                    "\$${montoPendiente.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      backgroundColor: Global.bg,
                      color: Global.action,
                      minHeight: 6,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}