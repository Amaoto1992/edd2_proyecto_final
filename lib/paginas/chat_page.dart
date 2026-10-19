import 'package:flutter/material.dart';

import '../estado.dart';
import '../modelos.dart';
import '../widgets/comunes.dart';

/// Chat con un amigo conectado. En esta versión las respuestas son
/// simuladas; con el backend se reemplaza por sockets.
class ChatPage extends StatelessWidget {
  final Usuario amigo;

  const ChatPage({super.key, required this.amigo});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final colores = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: estado,
      builder: (context, child) {
        final mensajes = estado.mensajesCon(amigo.id);
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                AvatarUsuario(amigo, radio: 16),
                const SizedBox(width: 8),
                Text(amigo.nombre),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: mensajes.isEmpty
                    ? Center(child: Text('Escríbele a ${amigo.nombre}'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: mensajes.length,
                        itemBuilder: (context, i) {
                          final mensaje = mensajes[i];
                          final mio = mensaje.deId == estado.actual?.id;
                          return Align(
                            alignment: mio
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              constraints: const BoxConstraints(maxWidth: 320),
                              decoration: BoxDecoration(
                                color: mio
                                    ? colores.primaryContainer
                                    : colores.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(mensaje.texto),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CampoEnviar(
                    hint: 'Mensaje',
                    autofocus: true,
                    onEnviar: (texto) => estado.enviarMensaje(amigo.id, texto),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
