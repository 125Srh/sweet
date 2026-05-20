import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/admin_provider.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class AdminForm extends StatefulWidget {
  final Map<String, dynamic>? producto;
  const AdminForm({super.key, this.producto});

  @override
  State<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio = TextEditingController();
  final _imagen = TextEditingController();
  final _precioAdquisicion = TextEditingController();

  String? categoriaId;
  String? marcaId;
  int _stockValue = 0;

  File? _imagenFile;
  String? _imagenUrl;
  final picker = ImagePicker();

  static const _pink = Color(0xFFFF69B4);
  static const _darkPink = Color(0xFFD81B60);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminsProvider>().cargarCategoriasYMarcas();
    });
    if (widget.producto != null) {
      final p = widget.producto!;
      _nombre.text = p['nombre'] ?? '';
      _descripcion.text = p['descripcion'] ?? '';
      _precio.text = p['precio'].toString();
      _precioAdquisicion.text = p['precio_venta']?.toString() ?? '';
      _imagen.text = p['imagen_url'] ?? '';
      categoriaId = p['categoria_id'];
      marcaId = p['marca_id'];
      _stockValue = (p['stock'] as int?) ?? 0;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _precioAdquisicion.dispose();
    _imagen.dispose();
    super.dispose();
  }

  void _incrementar() => setState(() => _stockValue++);
  void _decrementar() {
    if (_stockValue > 0) setState(() => _stockValue--);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (categoriaId == null || marcaId == null) {
      _showSnack("Selecciona categoría y marca", isError: true);
      return;
    }

    final provider = context.read<AdminsProvider>();
    String? error;

    if (widget.producto == null) {
      error = await provider.crearProducto(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        precio: double.parse(_precio.text),
        precioAdquisicion: double.parse(_precioAdquisicion.text),
        stock: _stockValue,
        imagen: _imagen.text.trim(),
        categoriaId: categoriaId!,
        marcaId: marcaId!,
      );
    } else {
      error = await provider.actualizarProducto(
        id: widget.producto!['id'].toString(),
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        precio: double.parse(_precio.text),
        precioAdquisicion: double.parse(_precioAdquisicion.text),
        stock: _stockValue,
        imagen: _imagen.text.trim(),
        categoriaId: categoriaId!,
        marcaId: marcaId!,
      );
    }

    if (!mounted) return;

    if (error == null) {
      // ✅ Diálogo de confirmación elegante
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.producto == null
                    ? '¡Producto creado!'
                    : '¡Producto actualizado!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD81B60),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.producto == null
                    ? 'El producto fue agregado correctamente.'
                    : 'Los cambios fueron guardados correctamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      _showSnack(error, isError: true);
    }
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenFile = File(pickedFile.path);
      });

      await _subirImagenSupabase();
    }
  }

  Future<void> _subirImagenSupabase() async {
    if (_imagenFile == null) return;

    try {
      final supabase = Supabase.instance.client;

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage.from('productos').upload(fileName, _imagenFile!);

      final publicUrl = supabase.storage
          .from('productos')
          .getPublicUrl(fileName);

      setState(() {
        _imagenUrl = publicUrl;
        _imagen.text = publicUrl; // 🔥 se guarda en tu campo
      });

      _showSnack("Imagen subida correctamente", isError: false);
    } catch (e, stack) {
      print("❌ ERROR SUBIENDO IMAGEN: $e");
      print("📌 STACK TRACE: $stack");
      _showSnack("Error al subir imagen", isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null ? "Agregar producto" : "Editar producto",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F7), Color(0xFFFFE4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Ícono ──────────────────────────────────────
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: _pink.withOpacity(0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 50,
                      color: _pink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.producto == null
                        ? 'Nuevo Producto'
                        : 'Editar Producto',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _darkPink,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Card del formulario ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _input(_nombre, 'Nombre', Icons.label_outline),
                        _input(
                          _descripcion,
                          'Descripción',
                          Icons.description_outlined,
                          maxLines: 2,
                        ),
                        _input(
                          _precio,
                          'Precio Venta (Bs.)',
                          Icons.attach_money,
                          isNumber: true,
                        ),
                        _input(
                          _precioAdquisicion,
                          'Precio Adquisicion (Bs.)',
                          Icons.point_of_sale,
                          isNumber: true,
                        ),

                        // ── Control de stock ───────────────────
                        const SizedBox(height: 4),
                        _stockField(),
                        const SizedBox(height: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Imagen del producto",
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: _seleccionarImagen,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _imagenFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _imagenFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_imagenUrl != null
                                          ? Image.network(
                                              _imagenUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.image_outlined,
                                                  size: 40,
                                                ),
                                                SizedBox(height: 8),
                                                Text("Tocar para subir imagen"),
                                              ],
                                            )),
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _dropdownCategoria(provider),
                        const SizedBox(height: 12),
                        _dropdownMarca(provider),
                        const SizedBox(height: 24),

                        // ── Botón guardar ──────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pink,
                              disabledBackgroundColor: _pink.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    widget.producto == null
                                        ? 'Guardar Producto'
                                        : 'Actualizar Producto',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Control de stock rediseñado ────────────────────────────────
  Widget _stockField() {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (_stockValue <= 0) {
      statusColor = const Color(0xFFE74C3C);
      statusLabel = 'Agotado';
      statusIcon = Icons.remove_shopping_cart_outlined;
    } else if (_stockValue <= 3) {
      statusColor = const Color(0xFFE67E22);
      statusLabel = 'Stock bajo';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = const Color(0xFF27AE60);
      statusLabel = 'Stock disponible';
      statusIcon = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label igual que los otros campos
        Text(
          'Stock',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        // Control - número +  con el mismo estilo que los inputs
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Botón -
              InkWell(
                onTap: _decrementar,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(
                  width: 48,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _stockValue > 0
                        ? _pink.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    color: _stockValue > 0 ? _pink : Colors.grey[400],
                    size: 22,
                  ),
                ),
              ),

              // Número
              Expanded(
                child: Center(
                  child: Text(
                    '$_stockValue',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),

              // Botón +
              InkWell(
                onTap: _incrementar,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Container(
                  width: 48,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _pink.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.add_rounded, color: _pink, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Badge de estado debajo, pequeño y discreto
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(statusIcon, size: 13, color: statusColor),
            const SizedBox(width: 4),
            Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Input estándar ─────────────────────────────────────────────
  Widget _input(
    TextEditingController c,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _pink, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _pink, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _dropdownCategoria(AdminsProvider provider) {
    return DropdownButtonFormField<String>(
      value: categoriaId,
      hint: const Text("Seleccionar categoría"),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined, color: _pink, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _pink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      items: provider.categorias.map((c) {
        return DropdownMenuItem(
          value: c['id'].toString(),
          child: Text(c['nombre']),
        );
      }).toList(),
      onChanged: (value) => setState(() => categoriaId = value),
    );
  }

  Widget _dropdownMarca(AdminsProvider provider) {
    return DropdownButtonFormField<String>(
      value: marcaId,
      hint: const Text("Seleccionar marca"),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.business_outlined, color: _pink, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _pink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      items: provider.marcas.map((m) {
        return DropdownMenuItem(
          value: m['id'].toString(),
          child: Text(m['nombre']),
        );
      }).toList(),
      onChanged: (value) => setState(() => marcaId = value),
    );
  }
}
