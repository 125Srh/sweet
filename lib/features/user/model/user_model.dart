class UserModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? direccion;
  final String rol;
  final bool activo;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
    required this.rol,
    required this.activo,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'].toString(),
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'],
      direccion: map['direccion'],
      rol: map['rol'] ?? 'cliente',
      activo: map['activo'] ?? true,
    );
  }

  String get nombreCompleto => "$nombre $apellido";
}
