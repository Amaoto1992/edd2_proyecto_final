import '../modelos.dart';

class NodoPublicacion {
  final Publicacion value;
  NodoPublicacion? next;

  NodoPublicacion(this.value);
}

/// Lista enlazada de publicaciones (el feed). Las publicaciones nuevas entran
/// por head para que la más reciente quede de primera.
class ListaPublicaciones {
  NodoPublicacion? head;
  NodoPublicacion? tail;
  int length = 0;

  /// Inserta al inicio (publicación nueva).
  void prepend(Publicacion publicacion) {
    final nuevo = NodoPublicacion(publicacion);
    nuevo.next = head;
    head = nuevo;
    tail ??= nuevo;
    length++;
  }

  /// Inserta al final (al cargar los datos, que ya vienen del más reciente
  /// al más antiguo).
  void append(Publicacion publicacion) {
    final nuevo = NodoPublicacion(publicacion);
    if (head == null) {
      head = nuevo;
      tail = nuevo;
    } else {
      tail!.next = nuevo;
      tail = nuevo;
    }
    length++;
  }

  /// Busca una publicación por id.
  Publicacion? peek(String id) {
    var actual = head;
    while (actual != null) {
      if (actual.value.id == id) return actual.value;
      actual = actual.next;
    }
    return null;
  }

  /// Quita la publicación con [id] y une el nodo anterior con el siguiente.
  bool remove(String id) {
    NodoPublicacion? anterior;
    var actual = head;
    while (actual != null) {
      if (actual.value.id == id) {
        if (anterior == null) {
          head = actual.next;
        } else {
          anterior.next = actual.next;
        }
        if (identical(actual, tail)) {
          tail = anterior;
        }
        length--;
        return true;
      }
      anterior = actual;
      actual = actual.next;
    }
    return false;
  }

  int size() => length;

  /// Recorre desde head y devuelve las publicaciones en orden.
  List<Publicacion> toList() {
    final resultado = <Publicacion>[];
    var actual = head;
    while (actual != null) {
      resultado.add(actual.value);
      actual = actual.next;
    }
    return resultado;
  }
}
