// lib/registro_videos_page.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

/// Página completa para:
/// - seleccionar video (file_picker)
/// - subir video a Firebase Storage con progreso
/// - guardar documento en Firestore colección "videos" con downloadUrl y storagePath
///
/// Requisitos:
/// - Firebase inicializado en main.dart
/// - Dependencias en pubspec.yaml: firebase_core, firebase_auth, cloud_firestore, firebase_storage, file_picker, uuid
class RegistroVideosPage extends StatefulWidget {
  const RegistroVideosPage({super.key});

  @override
  State<RegistroVideosPage> createState() => _RegistroVideosPageState();
}

class _RegistroVideosPageState extends State<RegistroVideosPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _videoNameCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _fechaSubidaCtrl = TextEditingController();
  final TextEditingController _usuarioCtrl = TextEditingController();

  bool _loading = false;

  // File picker result
  PlatformFile? _pickedFile;
  Uint8List? _pickedBytes;
  double _uploadProgress = 0.0;

  // Apps / topics
  final List<AppInfo> appsList = [
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

  AppInfo? _selectedApp;
  final Set<String> _selectedTopics = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedApp = appsList.first;
    _fechaSubidaCtrl.text = _formatDate(_selectedDate);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final label = (user.displayName != null && user.displayName!.isNotEmpty)
          ? '${user.displayName}'
          : (user.email ?? user.uid);
      _usuarioCtrl.text = label;
    } else {
      _usuarioCtrl.text = 'Usuario no autenticado';
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFefae78),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFefae78)),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaSubidaCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickVideo() async {
    // withData: true -> get bytes (works on web & mobile)
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() {
        _pickedFile = file;
        _pickedBytes = file.bytes;
        _uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo seleccionado: ${file.name}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error seleccionando archivo: $e')));
    }
  }

  Future<void> _uploadAndSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedApp == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }
    if (_selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un topic relacionado')));
      return;
    }
    if (_pickedFile == null || _pickedBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un archivo de video antes de subir')));
      return;
    }

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uploaderId = user?.uid ?? 'anonymous';
      final uploaderName = user?.displayName ?? user?.email ?? 'unknown';

      // Generar nombre y path
      final ext = _pickedFile!.extension ?? 'mp4';
      final id = const Uuid().v4();
      final storagePath = 'videos/${_selectedApp!.id}/${_selectedTopics.first.replaceAll(' ', '_')}/$id.$ext';

      final ref = FirebaseStorage.instance.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'video/${_pickedFile!.extension ?? 'mp4'}',
        customMetadata: {
          'uploaded_by': uploaderId,
          'original_name': _pickedFile!.name,
        },
      );

      // Subida con progreso
      final uploadTask = ref.putData(_pickedBytes!, metadata);
      uploadTask.snapshotEvents.listen((event) {
        final transferred = event.bytesTransferred;
        final total = event.totalBytes ?? 1;
        setState(() {
          _uploadProgress = transferred / total;
        });
      });

      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Preparar documento
      final videoDoc = {
        'nombre': _videoNameCtrl.text.trim(),
        'categoria': _selectedApp!.id,
        'categoriaName': _selectedApp!.name,
        'topics': _selectedTopics.toList(),
        'descripcion': _descripcionCtrl.text.trim(),
        'fechaSubida': _selectedDate.toIso8601String(),
        'fechaSubidaReadable': _fechaSubidaCtrl.text,
        'usuarioId': uploaderId,
        'usuario': uploaderName,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'sizeBytes': _pickedFile!.size,
        'contentType': (_pickedFile!.extension == null || _pickedFile!.extension == 'mp4') ? 'video/mp4' : 'video/${_pickedFile!.extension}',
        'originalFileName': _pickedFile!.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('videos').add(videoDoc);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video subido y metadatos guardados')));

      // Reset form
      setState(() {
        _videoNameCtrl.clear();
        _descripcionCtrl.clear();
        _selectedTopics.clear();
        _selectedDate = DateTime.now();
        _fechaSubidaCtrl.text = _formatDate(_selectedDate);
        _pickedFile = null;
        _pickedBytes = null;
        _uploadProgress = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _videoNameCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaSubidaCtrl.dispose();
    _usuarioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFefae78);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Registro de videos', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accent.withOpacity(0.95), accent.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: accent.withOpacity(0.24), blurRadius: 30, offset: const Offset(0, 14)),
                        const BoxShadow(color: Colors.white70, blurRadius: 8, offset: Offset(-8, -8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Icon(Icons.play_circle_outline, size: 38, color: Colors.black87),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Registrar y subir video', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                              SizedBox(height: 6),
                              Text('Selecciona el archivo, asócialo a la categoría y topics correspondientes.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Card con form y upload
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 28, offset: const Offset(0, 18)),
                        BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 6, offset: const Offset(-8, -8)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nombre
                          _buildTextField(
                            controller: _videoNameCtrl,
                            label: 'Nombre del video',
                            hint: 'Ej: Cómo crear cuenta en Instagram',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre del video' : null,
                            prefix: const Icon(Icons.video_collection_outlined),
                          ),
                          const SizedBox(height: 12),

                          // Categoria
                          _buildCategoryDropdown(),

                          const SizedBox(height: 12),

                          // Topics
                          _buildTopicsSelector(),

                          const SizedBox(height: 12),

                          // Descripcion
                          _buildTextField(
                            controller: _descripcionCtrl,
                            label: 'Descripción (opcional)',
                            hint: 'Detalles extra sobre el video / recursos explicados...',
                            maxLines: 3,
                            prefix: const Icon(Icons.description_outlined),
                          ),

                          const SizedBox(height: 12),

                          // Fecha y usuario
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _fechaSubidaCtrl,
                                  label: 'Fecha de subida',
                                  readOnly: true,
                                  onTap: () => _pickDate(context),
                                  prefix: const Icon(Icons.calendar_today_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _usuarioCtrl,
                                  label: 'Usuario',
                                  readOnly: true,
                                  prefix: const Icon(Icons.person_outline),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Selector de archivo y progreso
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickVideo,
                                  icon: const Icon(Icons.attach_file_rounded),
                                  label: Text(_pickedFile == null ? 'Seleccionar video' : _pickedFile!.name),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    backgroundColor: const Color(0xFFF7F6F4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tamaño y estado
                              _pickedFile == null
                                  ? const SizedBox(width: 48)
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${(_pickedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 120,
                                          child: LinearProgressIndicator(value: _uploadProgress),
                                        ),
                                      ],
                                    ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Botón subir
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _loading
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                    label: const Text('Subiendo...'),
                                  )
                                : ElevatedButton(
                                    onPressed: _uploadAndSave,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(accent),
                                      elevation: const MaterialStatePropertyAll(10),
                                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 12)),
                                      shadowColor: MaterialStatePropertyAll(accent.withOpacity(0.35)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.cloud_upload_outlined, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text('Subir video y guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        filled: true,
        fillColor: const Color(0xFFF7F6F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppInfo>(
          value: _selectedApp,
          isExpanded: true,
          icon: const Icon(Icons.expand_more),
          items: appsList.map((app) {
            return DropdownMenuItem(
              value: app,
              child: Row(
                children: [
                  Icon(app.iconData, color: Colors.black87),
                  const SizedBox(width: 10),
                  Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              _selectedApp = v;
              _selectedTopics.clear();
              // if desired, clear video name/description as well or set defaults
            });
          },
        ),
      ),
    );
  }

  Widget _buildTopicsSelector() {
    final topics = _selectedApp?.topics ?? [];
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text('Selecciona topic(s) relacionados', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((t) {
            final selected = _selectedTopics.contains(t);
            return FilterChip(
              label: Text(t, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
              selected: selected,
              onSelected: (on) {
                setState(() {
                  if (on) {
                    _selectedTopics.add(t);
                  } else {
                    _selectedTopics.remove(t);
                  }
                });
              },
              selectedColor: const Color(0xFFefae78),
              backgroundColor: const Color(0xFFF2F0EE),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Modelo simple para cada app/categoría
class AppInfo {
  final String id;
  final String name;
  final IconData iconData;
  final List<String> topics;

  AppInfo({
    required this.id,
    required this.name,
    required this.iconData,
    required this.topics,
  });
}
