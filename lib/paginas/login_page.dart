import 'package:flutter/material.dart';

import '../estado.dart';
import 'shell_page.dart';

/// Registro e ingreso por correo, más dos servicios externos (simulados).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final usuarioCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool registro = false;
  String? error;

  @override
  void dispose() {
    nombreCtrl.dispose();
    usuarioCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void enviar() {
    if (!formKey.currentState!.validate()) return;
    final estado = EstadoApp.instancia;
    final resultado = registro
        ? estado.registrar(
            nombre: nombreCtrl.text,
            usuario: usuarioCtrl.text,
            email: emailCtrl.text,
            password: passwordCtrl.text,
          )
        : estado.login(emailCtrl.text, passwordCtrl.text);
    if (resultado != null) {
      setState(() => error = resultado);
      return;
    }
    irAlInicio();
  }

  void entrarCon(String proveedor) {
    EstadoApp.instancia.loginExterno(proveedor);
    irAlInicio();
  }

  void irAlInicio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ShellPage()),
    );
  }

  String? requerido(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

  Widget campo(
    TextEditingController ctrl,
    String etiqueta,
    String? Function(String?) validador, {
    bool oculto = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: oculto,
        validator: validador,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto final · Mini Twitter')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(
                registro ? 'Crear cuenta' : 'Ingresar',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    if (registro) campo(nombreCtrl, 'Nombre', requerido),
                    if (registro) campo(usuarioCtrl, 'Usuario', requerido),
                    campo(
                      emailCtrl,
                      'Correo electrónico',
                      (v) => (v == null || !v.contains('@'))
                          ? 'Escribe un correo válido'
                          : null,
                    ),
                    campo(
                      passwordCtrl,
                      'Contraseña',
                      (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                      oculto: true,
                    ),
                  ],
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: enviar,
                child: Text(registro ? 'Registrarme' : 'Ingresar'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  registro = !registro;
                  error = null;
                }),
                child: Text(
                  registro
                      ? '¿Ya tienes cuenta? Ingresa'
                      : '¿No tienes cuenta? Regístrate',
                ),
              ),
              const Divider(height: 32),
              OutlinedButton.icon(
                onPressed: () => entrarCon('Google'),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continuar con Google'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => entrarCon('Outlook'),
                icon: const Icon(Icons.mail_outline),
                label: const Text('Continuar con Outlook'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cuenta de prueba: danny@correo.com / 123456\n'
                'El ingreso con Google y Outlook es simulado en esta versión.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
