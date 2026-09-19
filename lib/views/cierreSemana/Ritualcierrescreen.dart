import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/views/HomePrincipal.dart';

// Asume que estas funciones están definidas en tus servicios de API
// import 'package:indicator/services/ritual_service.dart';

class RitualCierreScreen extends StatefulWidget {
  const RitualCierreScreen({super.key});

  @override
  State<RitualCierreScreen> createState() => _RitualCierreScreenState();
}

class _RitualCierreScreenState extends State<RitualCierreScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Datos simulados/cargados para los 4 pasos del ritual
  List<Map<String, dynamic>> _logrosSemana = [
    {'id': 1, 'nombre': 'Entrenar 4 días en el gimnasio', 'completado': true, 'area': 'Gimnasio'},
    {'id': 2, 'nombre': 'Sesión de terapia semanal', 'completado': true, 'area': 'Psicología'},
    {'id': 3, 'nombre': 'Lectura de 30 min diarios', 'completado': false, 'area': 'Desarrollo'},
    {'id': 4, 'nombre': 'Cena familiar del domingo', 'completado': true, 'area': 'Familia'},
  ];

  double _totalGastado7Dias = 3450.00;
  double _balanceLibreQuincena = 5000.00;

  String _puntoFuerteGemini = "Excelente disciplina en tu área de Gimnasio y Salud física manteniendo constancia durante toda la semana.";
  String _areaDescuidadaGemini = "El indicador de Desarrollo Personal tuvo una baja tasa de cumplimiento en tus lecturas programadas.";
  String _recomendacionGemini = "Para la próxima semana, reduce la meta a 15 minutos diarios de lectura para retomar tracción sin fricción.";

  final TextEditingController _enfoqueProximaSemanaController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _enfoqueProximaSemanaController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finalizarRitual() async {
    setState(() => _isLoading = true);
    try {
      // 1. Invocar el endpoint de ejecución del ritual en la API
      // await ejecutarRitualCierreApi(
      //   logrosActualizados: _logrosSemana,
      //   enfoqueSemanaSiguiente: _enfoqueProximaSemanaController.text.trim(),
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulación de procesamiento

      if (mounted) {
        Get.snackbar(
          '¡Ritual Completado!',
          'Tus metas e indicadores han sido reiniciados para la nueva semana.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4EE1A0),
          colorText: Colors.black,
          margin: const EdgeInsets.all(16),
        );
        Get.offAll(() => const Homeprincipal());
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'No se pudo completar el ritual: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.bg,
      appBar: AppBar(
        backgroundColor: Global.bg,
        elevation: 0,
        title: Text(
          'Ritual de Cierre Semanal',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: _previousPage,
        )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de Progreso Superior
            _buildProgressBar(),

            // Cuerpo dinámico de 4 pasos
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Control mediante botones
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildPaso1RevisionLogros(),
                  _buildPaso2BalanceFinanciero(),
                  _buildPaso3DiagnosticoGemini(),
                  _buildPaso4PlanificacionPredictiva(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barrita de progreso superior
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso ${_currentStep + 1} de 4',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                _getNombrePaso(_currentStep),
                style: const TextStyle(
                  color: Color(0xFF4EE1A0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: const Color(0xFF161B22),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4EE1A0)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  String _getNombrePaso(int paso) {
    switch (paso) {
      case 0:
        return 'Ajuste de Logros';
      case 1:
        return 'Balance Financiero';
      case 2:
        return 'Diagnóstico Gemini';
      case 3:
        return 'Plan Predictivo';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // PASO 1: Revisión y Ajuste de Logros
  // ---------------------------------------------------------------------------
  Widget _buildPaso1RevisionLogros() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valida tus Logros Semanales',
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Confirma los objetivos completados antes de efectuar el reinicio semanal.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _logrosSemana.length,
                itemBuilder: (context, index) {
                  final logro = _logrosSemana[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Global.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      activeColor: const Color(0xFF4EE1A0),
                      checkColor: Colors.black,
                      title: Text(
                        logro['nombre'],
                        style: TextStyle(
                          color: Colors.white,
                          decoration: logro['completado']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        logro['area'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      value: logro['completado'],
                      onChanged: (bool? val) {
                        setState(() {
                          _logrosSemana[index]['completado'] = val ?? false;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            _buildBotonSiguiente(text: 'Continuar al Balance', onTap: _nextPage),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PASO 2: Balance Financiero Semanal
  // ---------------------------------------------------------------------------
  Widget _buildPaso2BalanceFinanciero() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Financiero de la Semana',
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Resumen del total gastado en los últimos 7 días frente a tu disponible.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Global.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Gastado (7 días)',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        '\$${_totalGastado7Dias.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Balance Libre Restante',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        '\$${_balanceLibreQuincena.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4EE1A0),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildBotonSiguiente(text: 'Ver Diagnóstico de IA', onTap: _nextPage),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PASO 3: Diagnóstico de Gemini
  // ---------------------------------------------------------------------------
  Widget _buildPaso3DiagnosticoGemini() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF4EE1A0)),
                const SizedBox(width: 8),
                Text(
                  'Diagnóstico de Gemini',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTarjetaAnalisis(
                    titulo: 'Punto Más Fuerte',
                    contenido: _puntoFuerteGemini,
                    icono: Icons.trending_up,
                    colorIcono: const Color(0xFF4EE1A0),
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaAnalisis(
                    titulo: 'Área Descuidada',
                    contenido: _areaDescuidadaGemini,
                    icono: Icons.warning_amber_rounded,
                    colorIcono: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaAnalisis(
                    titulo: 'Recomendación Estratégica',
                    contenido: _recomendacionGemini,
                    icono: Icons.lightbulb_outline,
                    colorIcono: Colors.lightBlueAccent,
                  ),
                ],
              ),
            ),
            _buildBotonSiguiente(text: 'Planificar Siguiente Semana', onTap: _nextPage),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaAnalisis({
    required String titulo,
    required String contenido,
    required IconData icono,
    required Color colorIcono,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorIcono, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  contenido,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PASO 4: Planificación Predictiva y Finalización
  // ---------------------------------------------------------------------------
  Widget _buildPaso4PlanificacionPredictiva() {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planificación Predictiva',
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Establece el enfoque principal y las prioridades para la próxima semana.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _enfoqueProximaSemanaController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: Enfocarme en la lectura diaria de 15 min y recortar gastos fuera de presupuesto...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Global.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            _buildBotonSiguiente(
              text: 'Completar Ritual y Reiniciar',
              onTap: _finalizarRitual,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  // Botón reutilizable inferior
  Widget _buildBotonSiguiente({
    required String text,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4EE1A0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
        )
            : Text(
          text,
          style: GoogleFonts.openSans(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}