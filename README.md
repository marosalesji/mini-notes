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

```
git tag v0.1.0
git push origin v0.1.0
```

## Configuración

Primero es necesario tener las credenciales de AWS configuradas en
`~/.aws/credentials`

Despues debes levantar la infraestructura de EC2 utilizando el script
`cd scripts; ./setup-ec2.sh`. Este script va a generar un archivo `.env` con las
variables relevantes para la infraestructura como la IP de la instancia de EC2 y
va a descargar la llave privada para poder entrar por ssh.

Después es necesario crear un token de Docker Hub.

Finalmente, para utilizar el CICD es necesario que en Github Secrets estén
configurados los siguientes secretos:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKERHUB_TOKEN
DOCKERHUB_USERNAME
EC2_IP
EC2_SSH_KEY
```

## Preguntas

Analiza este repositorio y responde las siguientes preguntas:

### CI/CD
- ¿Este repositorio cuenta con CI/CD? Continuous Integration, Continuous
  Delivery and Continuous Deployment.
- ¿Qué workflow se ejecuta cuando abres un PR?
- ¿Cómo se hace trigger al pipeline de deploy?
- ¿En cuál ambiente de la nube se hace el deployment de esta aplicación?
- ¿Qué pasa en Docker Hub cuando haces git push origin v0.2.0?
- ¿Cuántos tags se crean en Docker Hub con cada release y por qué?

### The twelve factor app
- ¿Cuáles de los 12 factores utiliza este proyecto? ¿Cuáles no utiliza?
- Elige 1 de los 12 factores que no está en esta aplicación, ¿cómo lo
  implementarías?
- ¿Qué pasa con las notas si el contenedor se reinicia? ¿Cumple el factor VI?
  ¿Cómo lo resolverías sin cambiar el código de la app? [Factor VI Processes]
- `requirements.txt` tiene versiones fijas (`fastapi==0.135.3`). ¿Por qué es
  importante fijarlas? ¿Qué pasaría si no lo hicieras en el contexto del CI?
  [Factor II Dependencies]
- Identifica en qué workflow ocurre el *build*, en cuál el *release* y en cuál
  el *run*. ¿Puedes hacer un *run* sin haber pasado por *build*? [Factor V
  Build/Release/Run]
- La app no tiene logs. Si el contenedor falla en EC2, ¿cómo debuggeas?
  ¿Cómo lo implementarías? [Factor XI Logs]
