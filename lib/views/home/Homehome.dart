import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/iaApi.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/indicator/ViewLogrosIndicator.dart';
import 'package:indicator/views/indicator/newIndicador.dart';
import 'package:indicator/views/indicator/newLogro.dart';
import 'package:indicator/views/indicator/viewLogrosWeeks.dart';
// Importa tu archivo HTTP o servicio donde esté alojada la función de la IA
// import 'path/to/tu_archivo_api.dart';

class Homehome extends StatefulWidget {
  const Homehome({super.key});

  @override
  State<Homehome> createState() => _HomehomeState();
}

class _HomehomeState extends State<Homehome> {
  // Variables de estado para almacenar la tarjeta diaria de IA
  bool _isLoadingIa = true;
  Map<String, dynamic>? _tarjetaDiaria;

  @override
  void initState() {
    super.initState();
    getIndicators();
    getLogrosPendientes();
    _cargarTarjetaDiariaIa();
  }

  // Método para consumir la API de la tarjeta inteligente de IA
  Future<void> _cargarTarjetaDiariaIa() async {
    setState(() {
      _isLoadingIa = true;
    });

    // Llamada a la función HTTP que creamos previamente
    final resultado = await obtenerTarjetaDiariaIaApi();

    if (mounted) {
      setState(() {
        _tarjetaDiaria = resultado;
        _isLoadingIa = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.User;
      return Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Image.asset("lib/assets/complete_logo.png", width: 125,),
              ],
            ),
            SizedBox(height: 10,),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==========================================
                  _isLoadingIa
                      ? Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Global.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(color: Global.action),
                    ),
                  )
                      : Column(
                    children: [
                      // Tarjeta 1: Frase Motivacional
                      Card(
                        color: Global.card,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "mentor diario",
                                      style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.w600, color: Global.title, letterSpacing: -1.5),
                                    ),
                                    Text(
                                      _tarjetaDiaria?['frase_motivacional'] ?? 'El éxito es la suma de pequeños esfuerzos repetidos día tras día.',
                                      style: GoogleFonts.inter(fontSize: 15, color: Global.text, letterSpacing: -0.5,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Global.card,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "enfoque",
                                      style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.w600, color: Global.title, letterSpacing: -1.5),
                                    ),
                                    Text(
                                      _tarjetaDiaria?['consejo_financiero'] ?? 'Revisa tus prioridades de hoy y enfócate en avanzar en tu meta principal.',
                                      style: GoogleFonts.inter(fontSize: 15, color: Global.text, letterSpacing: -0.5,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // SECCIÓN: LOGROS DE LA SEMANA
                  // ==========================================
                  // 1. El botón de píldora exacto que abre el modal
                  Align(
                    alignment: AlignmentGeometry.centerRight,
                    child: SizedBox(
                      width: 130,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: () async {
                          final logrosWeeks = await getLogrosSemanas();
                          controller.setLogrosWeeks(logrosWeeks);

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Global.card,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.60,
                              minChildSize: 0.40,
                              maxChildSize: 0.90,
                              expand: false,
                              builder: (context, scrollController) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Global.sutil,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Logros de la semana",
                                            style: GoogleFonts.poppins(
                                              color: Global.text,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Global.text),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: Obx(() => ListView.builder(
                                          controller: scrollController,
                                          itemCount: controller.Logros.length,
                                          itemBuilder: (context, i) {
                                            final logro = controller.Logros[i];
                                            bool completado = logro["completado"] ?? false;

                                            return Card(
                                              color: Global.card.withOpacity(0.8),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                side: BorderSide(color: Global.sutil.withOpacity(0.3)),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${logro["nombre"]} (${logro["puntos"]}pts)",
                                                  style: TextStyle(
                                                    decoration: completado
                                                        ? TextDecoration.lineThrough
                                                        : TextDecoration.none,
                                                    color: Global.text,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${logro["nombre_indicador"] ?? ''}",
                                                  style: TextStyle(color: Global.text.withOpacity(0.8)),
                                                ),
                                                trailing: Checkbox(
                                                  value: completado,
                                                  checkColor: Global.card,
                                                  activeColor: Global.action,
                                                  onChanged: (value) async {
                                                    controller.toggleLogro(logro["id"]);
                                                  },
                                                  side: BorderSide(color: Global.sutil, width: 2.0),
                                                ),
                                              ),
                                            );
                                          },
                                        )),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Global.action,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "logros >",
                              style: GoogleFonts.poppins(
                                fontSize: 25,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: Global.bg,
                                letterSpacing: -1,
                                height: 1.0,
                              ),
                            ),
                            // Icon(
                            //   Icons.chevron_right,
                            //   size: 25,
                            //   color: Color(0xFF1E2229),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}