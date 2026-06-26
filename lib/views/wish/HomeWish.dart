import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/wishApi.dart';

class Homewish extends StatefulWidget {
  const Homewish({super.key});

  @override
  State<Homewish> createState() => _HomewishState();
}

class _HomewishState extends State<Homewish> {
  @override
  void initState() {
    super.initState();
    // Consigue los indicadores actualizados al entrar a la pantalla
    getIndicatorsWishes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usamos un Wrap con espaciado para que las tarjetas se organicen solas como cuadrícula
            Wrap(
              spacing: 15, // Espacio horizontal entre tarjetas
              runSpacing: 15, // Espacio vertical entre filas
              children: [
                // Renderizado dinámico mapeando los datos de tu controlador
                ...controller.IndicatorsWishes.map<Widget>((indicator) {
                  // Extraemos las variables del mapa JSON de forma segura
                  final String nombre = indicator['nombre'] ?? 'Sin nombre';
                  final int totalDeseos = indicator['total_deseos'] ?? 0;
                  final String tipo = indicator['tipo'] ?? '';

                  return SizedBox(
                    width: 160,
                    height: 160,
                    child: Card(
                      color: Global.card,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // ClipRRect asegura que el efecto visual del click (splash) respete los bordes redondeados
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            // Por ahora dejamos el evento listo para cuando necesites navegar o disparar otra función
                            print("Diste click al indicador: $nombre con ID: ${indicator['id']}");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icono dinámico o visual según el tipo de indicador
                                Icon(
                                  tipo == 'porcentaje' ? CupertinoIcons.percent : CupertinoIcons.star_fill,
                                  color: Global.action,
                                  size: 28,
                                ),
                                const SizedBox(height: 10),
                                // Nombre del indicador
                                Text(
                                  nombre,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Global.text
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Conteo de deseos acumulados (desde tu query SQL COUNT)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Global.action,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$totalDeseos futuros",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(), // Convertimos el map a una lista de widgets válida para el Wrap
              ],
            )
          ],
        ),
      ),
    );
  }
}