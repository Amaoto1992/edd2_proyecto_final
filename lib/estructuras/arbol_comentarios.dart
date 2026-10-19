/// Nodo del árbol de comentarios: un comentario y sus respuestas (hijos).
/// Cada respuesta es otro nodo, así que se pueden anidar sin límite.
class NodoComentario {
  final String id;
  final String autorId;
  final String texto;
  final DateTime fecha;
  final Set<String> likes;
  final List<NodoComentario> respuestas = [];

  NodoComentario({
    required this.id,
    required this.autorId,
    required this.texto,
    required this.fecha,
    Set<String>? likes,
  }) : likes = likes ?? <String>{};

  /// Agrega [respuesta] como hijo de este comentario.
  NodoComentario responder(NodoComentario respuesta) {
    respuestas.add(respuesta);
    return respuesta;
  }

  bool isLeaf() => respuestas.isEmpty;
}

/// Árbol N-ario de comentarios de una publicación. La publicación hace de
/// raíz: sus hijos directos son los comentarios y cada comentario puede tener
/// respuestas en cualquier nivel.
class ArbolComentarios {
  final List<NodoComentario> hijos = [];

  /// Agrega un comentario a la publicación, o como respuesta del comentario
  /// [padreId] si se indica. Devuelve false si no encontró al padre.
  bool agregar(NodoComentario comentario, {String? padreId}) {
    if (padreId == null) {
      hijos.add(comentario);
      return true;
    }
    final padre = buscar(padreId);
    if (padre == null) return false;
    padre.responder(comentario);
    return true;
  }

  /// DFS: busca un comentario por id bajando por cada rama.
  NodoComentario? buscar(String id) {
    NodoComentario? visitar(NodoComentario nodo) {
      if (nodo.id == id) return nodo;
      for (final hijo in nodo.respuestas) {
        final encontrado = visitar(hijo);
        if (encontrado != null) return encontrado;
      }
      return null;
    }

    for (final hijo in hijos) {
      final encontrado = visitar(hijo);
      if (encontrado != null) return encontrado;
    }
    return null;
  }

  /// Cantidad de comentarios en todos los niveles.
  int total() {
    int contar(NodoComentario nodo) {
      var suma = 1;
      for (final hijo in nodo.respuestas) {
        suma += contar(hijo);
      }
      return suma;
    }

    var suma = 0;
    for (final hijo in hijos) {
      suma += contar(hijo);
    }
    return suma;
  }
}
