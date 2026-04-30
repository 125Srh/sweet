import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

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
  final _stock = TextEditingController();
  final _imagen = TextEditingController();

  String? categoriaId;
  String? marcaId;

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
      _stock.text = p['stock'].toString();
      _imagen.text = p['imagen_url'] ?? '';

      categoriaId = p['categoria_id'];
      marcaId = p['marca_id'];
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (categoriaId == null || marcaId == null) {
      _showSnack("Selecciona categoría y marca", true);
      return;
    }

    final provider = context.read<AdminsProvider>();

    String? error;

    if (widget.producto == null) {
      // 🔥 CREAR
      error = await provider.crearProducto(
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        precio: double.parse(_precio.text),
        stock: int.parse(_stock.text),
        imagen: _imagen.text,
        categoriaId: categoriaId!,
        marcaId: marcaId!,
      );
    } else {
      // ✏️ EDITAR
      error = await provider.actualizarProducto(
        id: widget.producto!['id'].toString(),
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        precio: double.parse(_precio.text),
        stock: int.parse(_stock.text),
        imagen: _imagen.text,
        categoriaId: categoriaId!,
        marcaId: marcaId!,
      );
    }

    if (error == null) {
      _showSnack("✅ Guardado", false);
      Navigator.pop(context);
    } else {
      _showSnack(error, true);
    }
  }

  void _showSnack(String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
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
        ),
        backgroundColor: const Color(0xFFFF69B4),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ICONO
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 60,
                        color: Color(0xFFFF69B4),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      widget.producto == null
                          ? 'Nuevo Producto'
                          : 'Editar Producto',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          _input(_nombre, 'Nombre'),
                          _input(_descripcion, 'Descripción'),
                          _input(_precio, 'Precio', isNumber: true),
                          _input(_stock, 'Stock', isNumber: true),
                          _input(_imagen, 'URL Imagen'),

                          const SizedBox(height: 10),

                          _dropdownCategoria(provider),
                          const SizedBox(height: 10),
                          _dropdownMarca(provider),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : _guardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF69B4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      widget.producto == null
                                          ? 'Guardar Producto'
                                          : 'Actualizar Producto',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _dropdownCategoria(AdminsProvider provider) {
    return DropdownButtonFormField<String>(
      value: categoriaId,
      hint: const Text("Seleccionar categoría"),
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
