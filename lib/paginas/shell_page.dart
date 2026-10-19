import 'package:flutter/material.dart';

import '../estado.dart';
import 'amigos_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'perfil_page.dart';

/// Contenedor con las tres páginas internas: Home, Amigos y Perfil.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int indice = 0;

  static const titulos = ['Home', 'Amigos', 'Perfil'];

  void salir() {
    EstadoApp.instancia.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget pagina() {
    switch (indice) {
      case 1:
        return const AmigosPage();
      case 2:
        return const PerfilPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EstadoApp.instancia,
      builder: (context, child) {
        if (EstadoApp.instancia.actual == null) return const SizedBox.shrink();
        return Scaffold(
          appBar: AppBar(
            title: Text(titulos[indice]),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: salir,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: pagina(),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: indice,
            onDestinationSelected: (i) => setState(() => indice = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.people), label: 'Amigos'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      },
    );
  }
}
