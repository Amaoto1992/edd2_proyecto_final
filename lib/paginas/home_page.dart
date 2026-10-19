import 'package:flutter/material.dart';

import '../estado.dart';
import '../estructuras/arbol_comentarios.dart';
import '../modelos.dart';
import '../widgets/comunes.dart';
import 'chat_page.dart';

/// Home: amigos conectados (para chatear), crear publicaciones y el feed.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final publicarCtrl = TextEditingController();

  @override
  void dispose() {
    publicarCtrl.dispose();
    super.dispose();
  }

  void publicar() {
    final texto = publicarCtrl.text.trim();
    if (texto.isEmpty) return;
    EstadoApp.instancia.publicar(texto);
    publicarCtrl.clear();
  }

  void abrirChat(Usuario amigo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(amigo: amigo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final yo = estado.actual!;
    final conectados =
        estado.amigosDe(yo.id).where((amigo) => amigo.conectado).toList();
    // El feed sale de recorrer la lista enlazada de publicaciones.
    final feed = estado.publicaciones.toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Amigos conectados · toca uno para chatear',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: conectados.isEmpty
              ? const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ninguno de tus amigos está conectado'),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final amigo in conectados)
                      InkWell(
                        onTap: () => abrirChat(amigo),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              AvatarUsuario(amigo, radio: 24),
                              const SizedBox(height: 4),
                              Text(amigo.nombre.split(' ').first),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarUsuario(yo),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: publicarCtrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '¿Qué está pasando?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: publicar, child: const Text('Publicar')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final publicacion in feed)
          PublicacionCard(
            key: ValueKey(publicacion.id),
            publicacion: publicacion,
          ),
      ],
    );
  }
}

class PublicacionCard extends StatefulWidget {
  final Publicacion publicacion;

  const PublicacionCard({super.key, required this.publicacion});

  @override
  State<PublicacionCard> createState() => _PublicacionCardState();
}

class _PublicacionCardState extends State<PublicacionCard> {
  bool verComentarios = false;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final publicacion = widget.publicacion;
    final autor = estado.usuarioPorId(publicacion.autorId);
    final esMia = publicacion.autorId == estado.actual?.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarUsuario(autor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        autor?.nombre ?? 'Usuario',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${autor?.usuario ?? ''} · '
                        '${haceCuanto(publicacion.fecha)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (esMia)
                  IconButton(
                    tooltip: 'Eliminar publicación',
                    onPressed: () =>
                        estado.eliminarPublicacion(publicacion.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(publicacion.texto),
            Row(
              children: [
                BotonLike(likes: publicacion.likes),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => verComentarios = !verComentarios),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text('${publicacion.comentarios.total()}'),
                ),
              ],
            ),
            if (verComentarios) ...[
              for (final comentario in publicacion.comentarios.hijos)
                ComentarioWidget(
                  key: ValueKey(comentario.id),
                  publicacion: publicacion,
                  comentario: comentario,
                  nivel: 0,
                ),
              const SizedBox(height: 8),
              CampoEnviar(
                hint: 'Escribe un comentario',
                onEnviar: (texto) => estado.comentar(publicacion, texto),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Muestra un nodo del árbol de comentarios y, de forma recursiva, sus
/// respuestas con sangría.
class ComentarioWidget extends StatefulWidget {
  final Publicacion publicacion;
  final NodoComentario comentario;
  final int nivel;

  const ComentarioWidget({
    super.key,
    required this.publicacion,
    required this.comentario,
    required this.nivel,
  });

  @override
  State<ComentarioWidget> createState() => _ComentarioWidgetState();
}

class _ComentarioWidgetState extends State<ComentarioWidget> {
  bool respondiendo = false;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final comentario = widget.comentario;
    final autor = estado.usuarioPorId(comentario.autorId);

    return Padding(
      padding: EdgeInsets.only(left: widget.nivel == 0 ? 0 : 16, top: 8),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).dividerColor, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarUsuario(autor, radio: 12),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${autor?.nombre ?? 'Usuario'} · '
                    '${haceCuanto(comentario.fecha)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(comentario.texto),
            ),
            Row(
              children: [
                BotonLike(likes: comentario.likes),
                TextButton(
                  onPressed: () =>
                      setState(() => respondiendo = !respondiendo),
                  child: Text(respondiendo ? 'Cancelar' : 'Responder'),
                ),
              ],
            ),
            if (respondiendo)
              CampoEnviar(
                hint: 'Responder a ${autor?.nombre ?? 'Usuario'}',
                autofocus: true,
                onEnviar: (texto) {
                  estado.comentar(
                    widget.publicacion,
                    texto,
                    padreId: comentario.id,
                  );
                  setState(() => respondiendo = false);
                },
              ),
            for (final respuesta in comentario.respuestas)
              ComentarioWidget(
                key: ValueKey(respuesta.id),
                publicacion: widget.publicacion,
                comentario: respuesta,
                nivel: widget.nivel + 1,
              ),
          ],
        ),
      ),
    );
  }
}
