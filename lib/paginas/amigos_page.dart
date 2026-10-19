import 'package:flutter/material.dart';

import '../estado.dart';
import '../modelos.dart';
import '../widgets/comunes.dart';

/// Listar, agregar y eliminar amigos.
class AmigosPage extends StatelessWidget {
  const AmigosPage({super.key});

  void confirmarEliminar(BuildContext context, Usuario amigo) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Quieres eliminar a ${amigo.nombre} de tus amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              EstadoApp.instancia.eliminarAmigo(amigo.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.instancia;
    final yo = estado.actual!;
    final amigos = estado.amigosDe(yo.id);
    final sugerencias = estado.sugerencias();
    final titulo = Theme.of(context).textTheme.titleMedium;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Mis amigos (${amigos.length})', style: titulo),
        const SizedBox(height: 8),
        if (amigos.isEmpty) const Text('Todavía no tienes amigos'),
        for (final amigo in amigos)
          Card(
            child: ListTile(
              leading: AvatarUsuario(amigo),
              title: Text(amigo.nombre),
              subtitle: Text(
                '@${amigo.usuario} · '
                '${amigo.conectado ? 'conectado' : 'desconectado'}',
              ),
              trailing: IconButton(
                tooltip: 'Eliminar',
                onPressed: () => confirmarEliminar(context, amigo),
                icon: const Icon(Icons.person_remove),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text('Personas que quizá conozcas', style: titulo),
        const SizedBox(height: 8),
        if (sugerencias.isEmpty) const Text('No hay más personas para agregar'),
        for (final persona in sugerencias)
          Card(
            child: ListTile(
              leading: AvatarUsuario(persona),
              title: Text(persona.nombre),
              subtitle: Text('@${persona.usuario}'),
              trailing: FilledButton.tonalIcon(
                onPressed: () => estado.agregarAmigo(persona.id),
                icon: const Icon(Icons.person_add),
                label: const Text('Agregar'),
              ),
            ),
          ),
      ],
    );
  }
}
