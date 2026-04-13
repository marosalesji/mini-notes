# mini-notes

Una aplicación demo muy básica para almacenar notas, tiene dos endpoints uno
para recibir notas y otro para regresar las notas guardadas.

Esta apliación corre en un contenedor de Docker en una instancia EC2 en el
puerto 8000.

El repositorio sigue una estrategia de CI/CD de la siguiente forma:
- por cada commit en un PR se corren las pruebas unitarias
- cuando se etiqueta un commit con 'v*', es decir, con una actualización de
  version se inicia el flujo de delivery que crea una imagen de docker en Docker
  Hub.
- después de que termina la etapa de delivery un worflow de deployment inicia
  esa imagen en EC2.

