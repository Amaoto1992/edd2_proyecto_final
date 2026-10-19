import 'estructuras/arbol_comentarios.dart';

class Usuario {
  final String id;
  String nombre;
  String usuario;
  String email;
  String password;
  String bio;
  int avatar;
  bool conectado;

  /// Cómo se registró: 'correo', 'Google' u 'Outlook'.
  final String proveedor;

  Usuario({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.email,
    required this.password,
    this.bio = '',
    this.avatar = 0,
    this.conectado = false,
    this.proveedor = 'correo',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      usuario: json['usuario'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      bio: json['bio'] as String? ?? '',
      avatar: json['avatar'] as int? ?? 0,
      conectado: json['conectado'] as bool? ?? false,
    );
  }
}

class Publicacion {
  final String id;
  final String autorId;
  final String texto;
  final DateTime fecha;
  final Set<String> likes;

  /// Los comentarios de la publicación se guardan en un árbol N-ario.
  final ArbolComentarios comentarios = ArbolComentarios();

  Publicacion({
    required this.id,
    required this.autorId,
    required this.texto,
    required this.fecha,
    Set<String>? likes,
  }) : likes = likes ?? <String>{};
}

class Mensaje {
  final String deId;
  final String texto;
  final DateTime fecha;

  Mensaje(this.deId, this.texto, this.fecha);
}
