// lib/features/client/profile/screen/client_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _direccionCtrl;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _apellidoCtrl = TextEditingController();
    _telefonoCtrl = TextEditingController();
    _direccionCtrl = TextEditingController();

    Future.microtask(() async {
      await context.read<ProfileProvider>().cargar();
      _poblarCampos();
    });
  }

  void _poblarCampos() {
    final user = context.read<ProfileProvider>().user;
    if (user == null) return;
    _nombreCtrl.text = user.nombre;
    _apellidoCtrl.text = user.apellido;
    _telefonoCtrl.text = user.telefono ?? '';
    _direccionCtrl.text = user.direccion ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<ProfileProvider>().actualizar(
          nombre: _nombreCtrl.text,
          apellido: _apellidoCtrl.text,
          telefono: _telefonoCtrl.text,
          direccion: _direccionCtrl.text,
        );

    if (!mounted) return;
    if (ok) {
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Perfil actualizado correctamente'),
          backgroundColor: Color(0xFFD81B60),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '❌ Error: ${context.read<ProfileProvider>().error ?? "desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFFD81B60),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD81B60)),
        actions: [
          if (!_editando)
            TextButton.icon(
              onPressed: () => setState(() => _editando = true),
              icon: const Icon(Icons.edit, size: 18, color: Color(0xFFD81B60)),
              label: const Text(
                'Editar',
                style: TextStyle(color: Color(0xFFD81B60)),
              ),
            ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF69B4)),
            );
          }

          if (provider.user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No se pudo cargar el perfil'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.cargar,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD81B60)),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final user = provider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── AVATAR ──
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFFFB6C1),
                  child: Text(
                    user.nombre.isNotEmpty
                        ? user.nombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD81B60),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.rol.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD81B60),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── FORMULARIO ──
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información personal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD81B60),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _campo(
                            controller: _nombreCtrl,
                            label: 'Nombre',
                            icon: Icons.person_outline,
                            enabled: _editando,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'El nombre es requerido'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _apellidoCtrl,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            enabled: _editando,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'El apellido es requerido'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // Email — solo lectura siempre
                          _campoReadOnly(
                            value: user.email,
                            label: 'Correo electrónico',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _telefonoCtrl,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            enabled: _editando,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _campo(
                            controller: _direccionCtrl,
                            label: 'Dirección',
                            icon: Icons.location_on_outlined,
                            enabled: _editando,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── BOTONES ──
                if (_editando) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _editando = false);
                            _poblarCampos();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD81B60)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Color(0xFFD81B60)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isSaving ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD81B60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: provider.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Guardar',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF69B4), size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD81B60), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _campoReadOnly({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF69B4), size: 20),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(
        value,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
    );
  }
}