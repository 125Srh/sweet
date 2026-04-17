import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  // Valores seleccionables
  String _unidadMedida = 'UNIDAD';
  String _categoriaId = '';
  String _marcaId = '';
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _marcas = [];
  List<XFile> _imagenes = [];
  bool _isLoading = false;
  bool _destacado = false;
  
  // Opciones
  final List<String> _unidadesMedida = [
    'UNIDAD', 'KILO', 'LITRO', 'CAJA', 'DOCENA', 'PAQUETE', 'METRO', 'GRAMO'
  ];

  @override
  void initState() {
    super.initState();
    _cargarCategoriasYMarcas();
  }

  Future<void> _cargarCategoriasYMarcas() async {
    try {
      final categorias = await _supabase.from('categoria').select('id, nombre').eq('activo', true);
      final marcas = await _supabase.from('marca').select('id, nombre').eq('activo', true);
      setState(() {
        _categorias = List<Map<String, dynamic>>.from(categorias);
        _marcas = List<Map<String, dynamic>>.from(marcas);
        if (_categorias.isNotEmpty) _categoriaId = _categorias.first['id'];
        if (_marcas.isNotEmpty) _marcaId = _marcas.first['id'];
      });
    } catch (e) {
      print('Error cargando datos: $e');
    }
  }

  Future<void> _seleccionarImagenes() async {
    if (_imagenes.length >= 5) {
      _mostrarMensaje('Máximo 5 imágenes permitidas');
      return;
    }
    
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _imagenes.addAll(images);
        if (_imagenes.length > 5) _imagenes = _imagenes.sublist(0, 5);
      });
    }
  }

  Future<void> _subirImagenesYGuardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      List<String> imagenesUrls = [];
      
      // Subir imágenes a Supabase Storage
      for (int i = 0; i < _imagenes.length; i++) {
        final file = _imagenes[i];
        final bytes = await File(file.path).readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        final response = await _supabase.storage
            .from('productos')
            .uploadBinary(fileName, bytes);
        
        final url = _supabase.storage.from('productos').getPublicUrl(fileName);
        imagenesUrls.add(url);
      }
      
      // Guardar producto en la tabla
      final nuevoProducto = {
        'nombre': _nombreController.text,
        'codigo': _codigoController.text,
        'descripcion': _descripcionController.text,
        'unidad_medida': _unidadMedida,
        'categoria_id': _categoriaId,
        'marca_id': _marcaId,
        'costo': double.tryParse(_costoController.text) ?? 0,
        'precio': double.tryParse(_precioController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'imagen_url': imagenesUrls.isNotEmpty ? imagenesUrls.first : null,
        'destacado': _destacado,
        'activo': true,
      };
      
      await _supabase.from('producto').insert(nuevoProducto);
      
      _mostrarMensaje('Producto registrado exitosamente', error: false);
      Navigator.pop(context, true);
      
    } catch (e) {
      _mostrarMensaje('Error: $e', error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Producto'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta de máximo productos
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Máximo 123 Productos permitidos'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Nombre y código
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nombre de producto',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                hintText: 'Ingrese el nombre del producto',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Código de producto',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _codigoController,
                              decoration: const InputDecoration(
                                hintText: 'Ingrese el código del producto',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Unidad de Medida y Categorías
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unidad de Medida',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _unidadMedida,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _unidadesMedida.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v) => setState(() => _unidadMedida = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categorías',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _categoriaId.isEmpty ? null : _categoriaId,
                              hint: const Text('Seleccionar categorías'),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _categorias.map((c) {
                                return DropdownMenuItem(value: c['id'], child: Text(c['nombre']));
                              }).toList(),
                              onChanged: (v) => setState(() => _categoriaId = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descripción del producto',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          hintText: 'Ingrese la descripción del producto',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Costo y Precio
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('COSTO (BS)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _costoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onChanged: (v) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PRECIO (BS)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _precioController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stock
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STOCK INICIAL',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Destacado
                  Row(
                    children: [
                      Checkbox(
                        value: _destacado,
                        onChanged: (v) => setState(() => _destacado = v ?? false),
                      ),
                      const Text('Marcar como producto destacado'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Subida de imágenes
                  const Text('Imágenes del producto',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imagenes.isEmpty
                        ? InkWell(
                            onTap: _seleccionarImagenes,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Arrastra y suelta imágenes aquí, o haz clic para seleccionarlas',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('(Máximo 5 imágenes)',
                                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagenes.length,
                            itemBuilder: (_, i) => Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_imagenes[i].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                    onPressed: () => setState(() => _imagenes.removeAt(i)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (_imagenes.isNotEmpty)
                    TextButton.icon(
                      onPressed: _seleccionarImagenes,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Agregar más imágenes'),
                    ),
                  const SizedBox(height: 32),
                  
                  // Botones Cerrar y Registrar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _subirImagenesYGuardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Registrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}