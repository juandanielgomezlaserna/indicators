import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

class Homehome extends StatefulWidget {
  const Homehome({super.key});

  @override
  State<Homehome> createState() => _HomehomeState();
}

class _HomehomeState extends State<Homehome> {
  final box = GetStorage();

  bool _isLoadingIa = false;
  Map<String, dynamic>? _tarjetaDiaria;

  @override
  void initState() {
    super.initState();
    getLogrosPendientes();
    _cargarTarjetaDesdeStorage();
  }

  // Método seguro para leer de GetStorage en el arranque
  void _cargarTarjetaDesdeStorage() {
    final savedTarjeta = box.read('tarjeta_diaria_ia');

    if (savedTarjeta != null && mounted) {
      setState(() {
        _tarjetaDiaria = Map<String, dynamic>.from(savedTarjeta);
      });
    }
  }

  // Método para consumir la API de la tarjeta inteligente y guardarla localmente
  Future<void> _generarTarjetaDiariaIa() async {
    setState(() {
      _isLoadingIa = true;
    });

    // Llamada a la función HTTP
    final resultado = await obtenerTarjetaDiariaIaApi();

    if (resultado != null) {
      // Guardamos en GetStorage para persistencia
      box.write('tarjeta_diaria_ia', resultado);
    }

    if (mounted) {
      setState(() {
        if (resultado != null) {
          _tarjetaDiaria = resultado;
        }
        _isLoadingIa = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.User;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Image.asset("lib/assets/complete_logo.png", width: 125),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ==========================================
                    // SECCIÓN: TARJETA DE IA + BOTÓN DE GENERAR
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mentor IA",
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Global.title
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoadingIa ? null : _generarTarjetaDiariaIa,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Global.action,
                            foregroundColor: Global.bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoadingIa
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Global.bg,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.refresh, size: 18),
                          label: Text(
                            _tarjetaDiaria == null ? "Generar Mentor" : "Actualizar",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Global.bg),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _isLoadingIa && _tarjetaDiaria == null
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
                        : _tarjetaDiaria == null
                        ? Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Global.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Presiona el botón 'Generar Mentor' para obtener tus consejos de IA del día.",
                        style: GoogleFonts.inter(fontSize: 14, color: Global.text),
                        textAlign: TextAlign.center,
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
                                      const SizedBox(height: 6),
                                      Text(
                                        _tarjetaDiaria?['frase_motivacional'] ?? 'El éxito es la suma de pequeños esfuerzos repetidos día tras día.',
                                        style: GoogleFonts.inter(fontSize: 15, color: Global.text, letterSpacing: -0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tarjeta 2: Enfoque / Consejo Financiero
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
                                      const SizedBox(height: 6),
                                      Text(
                                        _tarjetaDiaria?['consejo_financiero'] ?? 'Revisa tus prioridades de hoy y enfócate en avanzar en tu meta principal.',
                                        style: GoogleFonts.inter(fontSize: 15, color: Global.text, letterSpacing: -0.5),
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
                    Align(
                      alignment: Alignment.centerRight,
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
                                  return FutureBuilder(
                                    future: getLogrosSemanas(), // Llamamos la API aquí adentro de forma limpia
                                    builder: (context, snapshot) {
                                      // Si está cargando los logros de la red, mostramos un loader elegante
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          padding: const EdgeInsets.all(30),
                                          child: Center(
                                            child: CircularProgressIndicator(color: Global.action),
                                          ),
                                        );
                                      }

                                      // Si ya cargó, actualizamos el controlador de GetX con los datos
                                      if (snapshot.hasData) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          controller.setLogrosWeeks(snapshot.data as List<dynamic>);
                                        });
                                      }

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
                                              child: Obx(() {
                                                if (controller.Logros.isEmpty) {
                                                  return Center(
                                                    child: Text(
                                                      "No hay logros para esta semana.",
                                                      style: TextStyle(color: Global.text),
                                                    ),
                                                  );
                                                }

                                                return ListView.builder(
                                                  controller: scrollController, // Vital para el scroll del BottomSheet
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
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50,),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}