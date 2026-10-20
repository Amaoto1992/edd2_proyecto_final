# Proyecto final · Mini Twitter

**Demo en línea:** https://amaoto1992.github.io/edd2_proyecto_final/

Estructuras de Datos II · Universidad Autónoma de Occidente · Danny Castrillón

Plataforma tipo Twitter hecha en Flutter (versión reducida, sin backend).

## Ejecutar

    flutter pub get
    flutter run

Cuenta de prueba: `danny@correo.com` / `123456`.

## Qué incluye

- **Login y registro** por correo, y botones de Google y Outlook (simulados, sin OAuth).
- **Home**: crear publicaciones, comentar, responder comentarios en cualquier nivel,
  likes a publicaciones y comentarios, y chat con amigos conectados.
- **Amigos**: listar, agregar y eliminar.
- **Perfil**: editar nombre, usuario, correo, biografía y foto de perfil.
- **Datos**: JSON simulado en `lib/datos/datos_simulados.dart`. Nada es persistente
  porque esta versión no tiene backend ni base de datos.

## Estructuras de datos

1. **Lista enlazada de publicaciones** (`lib/estructuras/lista_publicaciones.dart`):
   el feed. Las publicaciones nuevas entran por `head` (`prepend`) y se recorre con `next`.
2. **Árbol N-ario de comentarios** (`lib/estructuras/arbol_comentarios.dart`):
   cada publicación es la raíz, sus hijos son los comentarios y cada comentario puede
   tener respuestas. Para encontrar el comentario al que se responde se usa DFS.

## Despliegue

El sitio se publica en GitHub Pages desde la rama `gh-pages`.

**Pasos para regenerar el despliegue:**

1. Construir la versión web con la ruta base correcta:

       flutter build web --release --base-href /edd2_proyecto_final/

2. Publicar `build/web` en la rama `gh-pages`:

       cd build/web
       touch .nojekyll
       git init -b gh-pages
       git add .
       git commit -m "despliegue web"
       git remote add origin https://github.com/Amaoto1992/edd2_proyecto_final.git
       git push -f origin gh-pages

3. Activar (o actualizar) GitHub Pages apuntando a `gh-pages` en raíz `/`:

       gh api -X PUT repos/Amaoto1992/edd2_proyecto_final/pages \
         -f "source[branch]=gh-pages" -f "source[path]=/"

## Pendiente para la versión completa

Backend (modelos, rutas, controladores, middlewares), sockets para el chat y base de datos MongoDB.
