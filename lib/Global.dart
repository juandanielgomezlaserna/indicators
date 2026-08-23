import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Global{
  static Color bg = Color(0xFF1F2430);
  static Color card = Color(0xFF373C48);
  static Color menu = Color(0xFF32353B);
  static Color sutil = Color(0xFF9CD3D0);
  static Color action = Color(0xFF9CD3D0);
  static Color title = Color(0xFF9CD3D0);
  static Color text = Color(0xFFCCCCCC);
  static String baseUrl = "https://indicators-api-dgij.onrender.com/api/v1/";

  static Map<String, IconData> iconsIndicators = {
    // Salud y fitness
    'Pesas': Icons.fitness_center_outlined,
    'Correr': Icons.directions_run_outlined,
    'Ritmo cardíaco': Icons.monitor_heart_outlined,
    'Spa': Icons.spa_outlined,
    'Descanso': Icons.nightlight_outlined,
    'Nutrición': Icons.restaurant_outlined,
    'Hidratación': Icons.water_drop_outlined,
  // Espiritualidad y mente
  'Meditación': Icons.self_improvement_outlined,
  'Amanecer': Icons.brightness_5_outlined,
  'Inspiración': Icons.auto_awesome_outlined,
  'Modo noche': Icons.dark_mode_outlined,
  'Conexión interior': Icons.bubble_chart_outlined,
  'Enfoque': Icons.blur_circular_outlined,
  // Conocimiento y educación
  'Lectura': Icons.menu_book_outlined,
  'Estudio': Icons.school_outlined,
  'Ideas': Icons.lightbulb_outlined,
  'Psicología': Icons.psychology_outlined,
  'Idiomas': Icons.language_outlined,
  'Notas': Icons.edit_note_outlined,
  'Ciencia': Icons.science_outlined,
  'Podcast': Icons.headphones_outlined,
  // Finanzas
  'Billetera': Icons.account_balance_wallet_outlined,
  'Ahorros': Icons.savings_outlined,
  'Crecimiento': Icons.trending_up_outlined,
  'Indicadores': Icons.insights_outlined,
  'Tarjeta': Icons.credit_card_outlined,
  'Pagos': Icons.payments_outlined,
  'Distribución': Icons.pie_chart_outline,
  'Dinero': Icons.attach_money_outlined,
  // Relaciones y social
  'Amor': Icons.favorite_border,
  'Personas': Icons.people_outline,
  'Grupos': Icons.groups_outlined,
  'Conversación': Icons.chat_bubble_outline,
  'Celebración': Icons.celebration_outlined,
  'Comunidad': Icons.diversity_3_outlined,
  'Acuerdo': Icons.handshake_outlined,
  'corazon' : CupertinoIcons.heart,
  // Hogar y vida diaria
  'Hogar': Icons.home_outlined,
  'Muebles': Icons.chair_outlined,
  'Casa': Icons.cottage_outlined,
  'Vestuario': Icons.checkroom_outlined,
  'Limpieza': Icons.cleaning_services_outlined,
  'Plantas': Icons.local_florist_outlined,
  // Trabajo y carrera
  'Trabajo': Icons.work_outline,
  'Negocios': Icons.business_center_outlined,
  'Tecnología': Icons.laptop_mac_outlined,
  'Lanzamiento': Icons.rocket_launch_outlined,
  'Credencial': Icons.badge_outlined,
  'Tareas': Icons.assignment_outlined,
  // Creatividad y hobbies
  'Arte': Icons.palette_outlined,
  'Fotografía': Icons.camera_alt_outlined,
  'Música': Icons.music_note_outlined,
  'Pintura': Icons.brush_outlined,
  'Cine': Icons.movie_creation_outlined,
  'Videojuegos': Icons.videogame_asset_outlined,
  'Teatro': Icons.theater_comedy_outlined,
  // Viajes y aventura
  'Viajes': Icons.flight_takeoff_outlined,
  'Explorar': Icons.explore_outlined,
  'Montaña': Icons.terrain_outlined,
  'Playa': Icons.beach_access_outlined,
  'Carro': Icons.directions_car_outlined,
  'Moto': Icons.two_wheeler_outlined,
  'Mapa': Icons.map_outlined,
  // Naturaleza y abstractos
  'Naturaleza': Icons.eco_outlined,
  'Sol': Icons.wb_sunny_outlined,
  'Luna': Icons.nightlight_round_outlined,
  'Hexágono': Icons.hexagon_outlined,
  'Textura': Icons.grain_outlined,
  'Olas': Icons.waves_outlined,
};
}