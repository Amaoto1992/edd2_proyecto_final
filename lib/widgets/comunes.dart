import 'package:flutter/material.dart';

import '../estado.dart';
import '../modelos.dart';

/// "Fotos de perfil" disponibles: cada una es un color con un ícono.
const coloresAvatar = [
  Colors.indigo,
  Colors.teal,
  Colors.orange,
  Colors.pink,
  Colors.green,
  Colors.purple,
  Colors.brown,
  Colors.blueGrey,
];

const iconosAvatar = [
  Icons.person,
  Icons.face,
  Icons.pets,
  Icons.rocket_launch,
  Icons.sports_soccer,
  Icons.music_note,
  Icons.local_florist,
  Icons.code,
];

class AvatarIcono extends StatelessWidget {
  final int indice;
  final double radio;

  const AvatarIcono(this.indice, {super.key, this.radio = 20});

  @override
  Widget build(BuildContext context) {
    final i = indice % coloresAvatar.length;
    return CircleAvatar(
      radius: radio,
      backgroundColor: coloresAvatar[i],
      foregroundColor: Colors.white,
      child: Icon(iconosAvatar[i], size: radio),
    );
  }
}

class AvatarUsuario extends StatelessWidget {
  final Usuario? usuario;
  final double radio;

  const AvatarUsuario(this.usuario, {super.key, this.radio = 20});

  @override
  Widget build(BuildContext context) =>
      AvatarIcono(usuario?.avatar ?? 0, radio: radio);
}

String haceCuanto(DateTime fecha) {
  final diferencia = DateTime.now().difference(fecha);
  if (diferencia.inMinutes < 1) return 'ahora';
  if (diferencia.inHours < 1) return 'hace ${diferencia.inMinutes} min';
  if (diferencia.inDays < 1) return 'hace ${diferencia.inHours} h';
  return 'hace ${diferencia.inDays} d';
}

/// Botón de like para publicaciones y comentarios.
class BotonLike extends StatelessWidget {
  final Set<String> likes;

  const BotonLike({super.key, required this.likes});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final meGusta = likes.contains(estado.actual?.id);
    return TextButton.icon(
      onPressed: () => estado.alternarLike(likes),
      icon: Icon(
        meGusta ? Icons.favorite : Icons.favorite_border,
        color: meGusta ? Colors.red : null,
      ),
      label: Text('${likes.length}'),
    );
  }
}

/// Campo de texto con botón de enviar (comentarios, respuestas y chat).
class CampoEnviar extends StatefulWidget {
  final String hint;
  final bool autofocus;
  final void Function(String texto) onEnviar;

  const CampoEnviar({
    super.key,
    required this.hint,
    required this.onEnviar,
    this.autofocus = false,
  });

  @override
  State<CampoEnviar> createState() => _CampoEnviarState();
}

class _CampoEnviarState extends State<CampoEnviar> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void enviar() {
    final texto = ctrl.text.trim();
    if (texto.isEmpty) return;
    widget.onEnviar(texto);
    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            autofocus: widget.autofocus,
            onSubmitted: (_) => enviar(),
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Enviar',
          onPressed: enviar,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
