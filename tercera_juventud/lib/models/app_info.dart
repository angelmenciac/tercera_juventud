// lib/models/app_info.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modelo que representa una aplicación (categoría) y sus topics.
/// Se usa para mostrar el listado (Instagram, Whatsapp, Facebook, TikTok)
/// y luego las opciones dentro de cada categoría.
class AppInfo {
  final String id;              // identificador interno -> "instagram", "whatsapp", etc.
  final String name;            // nombre visible
  final IconData iconData;      // icono a mostrar
  final List<String> topics;    // listado de actividades/temas

  AppInfo({
    required this.id,
    required this.name,
    required this.iconData,
    required this.topics,
  });

  /// Lista por defecto con las apps de tu proyecto
  static List<AppInfo> defaultList() {
    return [
      AppInfo(
        id: 'instagram',
        name: 'Instagram',
        iconData: Icons.camera_alt_outlined,
        topics: [
          '¿Como crear una cuenta?',
          '¿Quieres publicar una historia?',
          '¿Quieres seguir a tu conocidos?',
          '¿Quieres subir una publicación?',
          '¿Cuenta privada o publica?',
        ],
      ),
      AppInfo(
        id: 'whatsapp',
        name: 'Whatsapp',
        iconData: FontAwesomeIcons.whatsapp,
        topics: [
          '¿Como crear una cuenta?',
          'Enviar mensajes y fotos',
          'Crear y salir de grupos',
          'Hacer videollamadas',
          'Enviar ubicación',
        ],
      ),
      AppInfo(
        id: 'facebook',
        name: 'Facebook',
        iconData: Icons.facebook,
        topics: [
          'Crear perfil',
          'Publicar estado',
          'Agregar amigos',
          'Configurar privacidad',
          'Uso de Marketplace',
        ],
      ),
      AppInfo(
        id: 'tiktok',
        name: 'Tik Tok',
        iconData: Icons.music_note,
        topics: [
          'Crear cuenta y perfil',
          'Subir videos',
          'Explorar tendencias',
          'Usar efectos y sonidos',
          'Configurar privacidad',
        ],
      ),
    ];
  }
}
