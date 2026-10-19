import 'package:flutter/material.dart';

import '../estado.dart';
import '../widgets/comunes.dart';

/// Editar la información básica de registro y la foto de perfil.
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nombreCtrl;
  late final TextEditingController usuarioCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController bioCtrl;
  late int avatar;

  @override
  void initState() {
    super.initState();
    final yo = EstadoApp.instancia.actual!;
    nombreCtrl = TextEditingController(text: yo.nombre);
    usuarioCtrl = TextEditingController(text: yo.usuario);
    emailCtrl = TextEditingController(text: yo.email);
    bioCtrl = TextEditingController(text: yo.bio);
    avatar = yo.avatar;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    usuarioCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  void guardar() {
    if (!formKey.currentState!.validate()) return;
    final error = EstadoApp.instancia.actualizarPerfil(
      nombre: nombreCtrl.text,
      usuario: usuarioCtrl.text,
      email: emailCtrl.text,
      bio: bioCtrl.text,
      avatar: avatar,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Perfil actualizado')),
    );
  }

  String? requerido(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final yo = EstadoApp.instancia.actual!;
    final colores = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: AvatarIcono(avatar, radio: 48)),
        const SizedBox(height: 8),
        Center(child: Text('@${yo.usuario} · cuenta de ${yo.proveedor}')),
        const SizedBox(height: 16),
        Text(
          'Foto de perfil',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < coloresAvatar.length; i++)
              InkWell(
                onTap: () => setState(() => avatar = i),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i == avatar ? colores.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: AvatarIcono(i, radio: 22),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreCtrl,
                validator: requerido,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: usuarioCtrl,
                validator: (v) {
                  if (requerido(v) != null) return 'Campo obligatorio';
                  if (v!.contains(' ')) return 'Sin espacios';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Escribe un correo válido'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bioCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: guardar,
          icon: const Icon(Icons.save),
          label: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}
