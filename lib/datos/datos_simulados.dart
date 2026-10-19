/// Colección de datos simulada en formato JSON (todavía no hay backend ni base
/// de datos). "hace" son los minutos que han pasado desde que se publicó.
const datosJson = r'''
{
  "usuarios": [
    {"id": "u1", "nombre": "Danny Castrillón", "usuario": "danny", "email": "danny@correo.com", "password": "123456", "bio": "Estudiante de Estructuras de Datos II", "avatar": 0, "conectado": true},
    {"id": "u2", "nombre": "Laura Gómez", "usuario": "laurag", "email": "laura@correo.com", "password": "123456", "bio": "Café, código y música", "avatar": 1, "conectado": true},
    {"id": "u3", "nombre": "Andrés Pérez", "usuario": "andresp", "email": "andres@correo.com", "password": "123456", "bio": "Hincha del Cali", "avatar": 4, "conectado": false},
    {"id": "u4", "nombre": "Camila Ríos", "usuario": "camirios", "email": "camila@correo.com", "password": "123456", "bio": "Diseño UX", "avatar": 3, "conectado": true},
    {"id": "u5", "nombre": "Julián Torres", "usuario": "jtorres", "email": "julian@correo.com", "password": "123456", "bio": "Backend con Node", "avatar": 7, "conectado": false},
    {"id": "u6", "nombre": "Sofía Martínez", "usuario": "sofim", "email": "sofia@correo.com", "password": "123456", "bio": "Fotografía", "avatar": 6, "conectado": true}
  ],
  "amistades": [
    ["u1", "u2"],
    ["u1", "u3"],
    ["u1", "u4"],
    ["u2", "u3"],
    ["u4", "u5"],
    ["u2", "u6"]
  ],
  "publicaciones": [
    {
      "id": "p1", "autorId": "u2", "hace": 12,
      "texto": "Por fin entendí la diferencia entre una pila y una cola 🙌",
      "likes": ["u1", "u3"],
      "comentarios": [
        {
          "id": "c1", "autorId": "u1", "hace": 10, "likes": ["u2"],
          "texto": "LIFO vs FIFO, ¡clave para el parcial!",
          "respuestas": [
            {"id": "c2", "autorId": "u2", "hace": 8, "likes": [], "texto": "Exacto, el plato de arriba sale primero", "respuestas": [
              {"id": "c3", "autorId": "u3", "hace": 5, "likes": ["u1", "u2"], "texto": "Y en la fila del banco el primero que llega", "respuestas": []}
            ]}
          ]
        },
        {"id": "c4", "autorId": "u4", "hace": 6, "likes": [], "texto": "¿Alguien tiene los apuntes de árboles?", "respuestas": []}
      ]
    },
    {
      "id": "p2", "autorId": "u4", "hace": 45,
      "texto": "Nuevo diseño del perfil listo en Figma 🎨",
      "likes": ["u2"],
      "comentarios": [
        {"id": "c5", "autorId": "u2", "hace": 40, "likes": ["u4"], "texto": "¡Quedó muy limpio!", "respuestas": []}
      ]
    },
    {
      "id": "p3", "autorId": "u3", "hace": 180,
      "texto": "¿Quién va al partido del domingo?",
      "likes": [],
      "comentarios": []
    },
    {
      "id": "p4", "autorId": "u1", "hace": 1440,
      "texto": "Primer post en la plataforma. ¡Hola a todos!",
      "likes": ["u2", "u3", "u4"],
      "comentarios": [
        {"id": "c6", "autorId": "u3", "hace": 1400, "likes": [], "texto": "¡Bienvenido!", "respuestas": []}
      ]
    }
  ]
}
''';
