class Producto {
  final String id;              // uuid
  final String categoriaId;     // uuid - FK a categoria
  final String marcaId;         // uuid - FK a marca
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String? imagenUrl;
  final bool destacado;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Producto({
    required this.id,
    required this.categoriaId,
    required this.marcaId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.imagenUrl,
    required this.destacado,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  // Para INSERT (no incluye id porque Supabase lo genera)
  Map<String, dynamic> toInsertMap() {
    return {
      'categoria_id': categoriaId,
      'marca_id': marcaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'destacado': destacado,
      'activo': activo,
    };
  }

  // Para UPDATE
  Map<String, dynamic> toUpdateMap() {
    return {
      'categoria_id': categoriaId,
      'marca_id': marcaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen_url': imagenUrl,
      'destacado': destacado,
      'activo': activo,
    };
  }

  // Desde Supabase (incluye id y timestamps)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] ?? '',
      categoriaId: map['categoria_id'] ?? '',
      marcaId: map['marca_id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      precio: (map['precio'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      imagenUrl: map['imagen_url'],
      destacado: map['destacado'] ?? false,
      activo: map['activo'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Copiar con cambios
  Producto copyWith({
    String? id,
    String? categoriaId,
    String? marcaId,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? imagenUrl,
    bool? destacado,
    bool? activo,
  }) {
    return Producto(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      marcaId: marcaId ?? this.marcaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      destacado: destacado ?? this.destacado,
      activo: activo ?? this.activo,
    );
  }
}