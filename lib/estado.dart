import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'datos/datos_simulados.dart';
import 'estructuras/arbol_comentarios.dart';
import 'estructuras/lista_publicaciones.dart';
import 'modelos.dart';

/// Estado de la plataforma en memoria. Se llena con los datos JSON simulados;
/// nada es persistente porque esta versión no tiene backend ni base de datos.
class EstadoApp extends ChangeNotifier {
  EstadoApp._() {
    _cargarDatos();
  }

  static final EstadoApp instancia = EstadoApp._();

  final List<Usuario> usuarios = [];
  final Map<String, Set<String>> _amigos = {};
  final ListaPublicaciones publicaciones = ListaPublicaciones();
  final Map<String, List<Mensaje>> _chats = {};
  final _random = Random();
  int _contador = 0;
  Usuario? actual;

  String _nuevoId(String prefijo) =>
      '$prefijo${DateTime.now().microsecondsSinceEpoch}_${_contador++}';

  // ---------------------------------------------------------------- Datos

  void _cargarDatos() {
    final datos = jsonDecode(datosJson) as Map<String, dynamic>;
    final ahora = DateTime.now();

    for (final json in datos['usuarios'] as List<dynamic>) {
      usuarios.add(Usuario.fromJson(json as Map<String, dynamic>));
    }
    for (final par in datos['amistades'] as List<dynamic>) {
      final ids = (par as List<dynamic>).cast<String>();
      _conectar(ids[0], ids[1]);
    }
    for (final json in datos['publicaciones'] as List<dynamic>) {
      final mapa = json as Map<String, dynamic>;
      final publicacion = Publicacion(
        id: mapa['id'] as String,
        autorId: mapa['autorId'] as String,
        texto: mapa['texto'] as String,
        fecha: ahora.subtract(Duration(minutes: mapa['hace'] as int)),
        likes: (mapa['likes'] as List<dynamic>).cast<String>().toSet(),
      );
      for (final comentario in mapa['comentarios'] as List<dynamic>) {
        publicacion.comentarios.agregar(
          _comentarioDesdeJson(comentario as Map<String, dynamic>, ahora),
        );
      }
      publicaciones.append(publicacion);
    }
  }

  /// Arma un nodo del árbol de comentarios y, de forma recursiva, sus
  /// respuestas.
  NodoComentario _comentarioDesdeJson(
    Map<String, dynamic> json,
    DateTime ahora,
  ) {
    final nodo = NodoComentario(
      id: json['id'] as String,
      autorId: json['autorId'] as String,
      texto: json['texto'] as String,
      fecha: ahora.subtract(Duration(minutes: json['hace'] as int)),
      likes: (json['likes'] as List<dynamic>).cast<String>().toSet(),
    );
    for (final respuesta in json['respuestas'] as List<dynamic>) {
      nodo.responder(
        _comentarioDesdeJson(respuesta as Map<String, dynamic>, ahora),
      );
    }
    return nodo;
  }

  Usuario? usuarioPorId(String id) {
    for (final usuario in usuarios) {
      if (usuario.id == id) return usuario;
    }
    return null;
  }

  Usuario? _usuarioPorEmail(String email) {
    final buscado = email.trim().toLowerCase();
    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == buscado) return usuario;
    }
    return null;
  }

  // ------------------------------------------------------- Autenticación

  /// Devuelve null si entra, o el mensaje de error.
  String? login(String email, String password) {
    final usuario = _usuarioPorEmail(email);
    if (usuario == null) return 'No existe una cuenta con ese correo';
    if (usuario.password != password) return 'Contraseña incorrecta';
    _entrar(usuario);
    return null;
  }

  /// Devuelve null si se registró, o el mensaje de error.
  String? registrar({
    required String nombre,
    required String usuario,
    required String email,
    required String password,
  }) {
    if (_usuarioPorEmail(email) != null) return 'Ese correo ya está registrado';
    final nuevo = Usuario(
      id: _nuevoId('u'),
      nombre: nombre.trim(),
      usuario: usuario.trim(),
      email: email.trim(),
      password: password,
    );
    usuarios.add(nuevo);
    _entrar(nuevo);
    return null;
  }

  /// Simula el login con un servicio externo (Google u Outlook). En la
  /// versión con backend aquí iría el flujo OAuth del proveedor.
  void loginExterno(String proveedor) {
    final email = proveedor == 'Google'
        ? 'usuario.demo@gmail.com'
        : 'usuario.demo@outlook.com';
    var usuario = _usuarioPorEmail(email);
    if (usuario == null) {
      usuario = Usuario(
        id: _nuevoId('u'),
        nombre: 'Usuario de $proveedor',
        usuario: 'demo_${proveedor.toLowerCase()}',
        email: email,
        password: '',
        avatar: proveedor == 'Google' ? 2 : 5,
        proveedor: proveedor,
      );
      usuarios.add(usuario);
    }
    _entrar(usuario);
  }

  void _entrar(Usuario usuario) {
    usuario.conectado = true;
    actual = usuario;
    notifyListeners();
  }

  void logout() {
    actual?.conectado = false;
    actual = null;
    notifyListeners();
  }

  // ------------------------------------------------------------- Perfil

  /// Devuelve null si guardó, o el mensaje de error.
  String? actualizarPerfil({
    required String nombre,
    required String usuario,
    required String email,
    required String bio,
    required int avatar,
  }) {
    final yo = actual!;
    final otro = _usuarioPorEmail(email);
    if (otro != null && otro.id != yo.id) return 'Ese correo ya está en uso';
    yo
      ..nombre = nombre.trim()
      ..usuario = usuario.trim()
      ..email = email.trim()
      ..bio = bio.trim()
      ..avatar = avatar;
    notifyListeners();
    return null;
  }

  // ------------------------------------------------------------- Amigos

  void _conectar(String a, String b) {
    _amigos.putIfAbsent(a, () => <String>{}).add(b);
    _amigos.putIfAbsent(b, () => <String>{}).add(a);
  }

  List<Usuario> amigosDe(String id) => (_amigos[id] ?? <String>{})
      .map(usuarioPorId)
      .whereType<Usuario>()
      .toList();

  /// Usuarios que todavía no son amigos del usuario actual.
  List<Usuario> sugerencias() {
    final yo = actual!;
    final mios = _amigos[yo.id] ?? <String>{};
    return usuarios
        .where((u) => u.id != yo.id && !mios.contains(u.id))
        .toList();
  }

  void agregarAmigo(String id) {
    _conectar(actual!.id, id);
    notifyListeners();
  }

  void eliminarAmigo(String id) {
    final yo = actual!.id;
    _amigos[yo]?.remove(id);
    _amigos[id]?.remove(yo);
    notifyListeners();
  }

  // ------------------------------------------------------ Publicaciones

  void publicar(String texto) {
    publicaciones.prepend(
      Publicacion(
        id: _nuevoId('p'),
        autorId: actual!.id,
        texto: texto.trim(),
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void eliminarPublicacion(String id) {
    publicaciones.remove(id);
    notifyListeners();
  }

  /// Da o quita el like del usuario actual (sirve para publicaciones y
  /// comentarios).
  void alternarLike(Set<String> likes) {
    final yo = actual!.id;
    if (!likes.remove(yo)) likes.add(yo);
    notifyListeners();
  }

  /// Comenta la publicación o responde al comentario [padreId].
  void comentar(Publicacion publicacion, String texto, {String? padreId}) {
    publicacion.comentarios.agregar(
      NodoComentario(
        id: _nuevoId('c'),
        autorId: actual!.id,
        texto: texto.trim(),
        fecha: DateTime.now(),
      ),
      padreId: padreId,
    );
    notifyListeners();
  }

  // --------------------------------------------------------------- Chat

  String _claveChat(String amigoId) => '${actual?.id}|$amigoId';

  List<Mensaje> mensajesCon(String amigoId) =>
      _chats.putIfAbsent(_claveChat(amigoId), () => []);

  static const _respuestas = [
    '¡Hola! ¿Cómo vas?',
    'Jaja, totalmente',
    'Te leo en un rato',
    '👍',
    '¿Ya hiciste el reto de grafos?',
  ];

  /// Envía un mensaje. Como no hay sockets en esta versión, el amigo
  /// responde automáticamente un segundo después.
  void enviarMensaje(String amigoId, String texto) {
    final mensajes = mensajesCon(amigoId);
    mensajes.add(Mensaje(actual!.id, texto.trim(), DateTime.now()));
    notifyListeners();
    Timer(const Duration(seconds: 1), () {
      final respuesta = _respuestas[_random.nextInt(_respuestas.length)];
      mensajes.add(Mensaje(amigoId, respuesta, DateTime.now()));
      notifyListeners();
    });
  }
}
