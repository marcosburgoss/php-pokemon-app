# Pokemon DB

Aplicacion PHP para gestionar una base de datos de Pokemon. El proyecto se ejecuta con Docker Compose y no necesita XAMPP ni una instalacion local de PHP o MySQL. Este proyecto lo realicé como parte de un proyecto de la asignatura de bases de datos de 1º GS de DAM en 2022 para aprender a conectar una aplicación PHP a una base de datos MySQL y poder interactuar con ella: insertar nuevos datos, actualizar los existentes y borrar de la base de datos.

## Requisitos

- Docker Desktop instalado y ejecutandose.
- Docker Compose incluido en Docker Desktop.

Antes del primer arranque, crea el archivo local de variables de entorno:

```powershell
Copy-Item .env.example .env
```

Edita `.env` y establece las contrasenas que quieras utilizar. El archivo `.env` no se sube a GitHub.

Comprueba la instalacion con:

```powershell
docker --version
docker compose version
```

## Primer arranque

Abre PowerShell en la carpeta del proyecto:

Construye y arranca los contenedores:

```powershell
docker compose up -d --build
```

La primera ejecucion puede tardar porque descarga las imagenes y crea la base de datos.

Abre la aplicacion en:

```text
http://localhost:8080
```

## Arranques posteriores

Cuando la imagen y el volumen ya existen, basta con ejecutar:

```powershell
docker compose up -d
```

Comprueba el estado de los servicios con:

```powershell
docker compose ps
```

Deberias ver estos servicios activos:

- `pokemon-db`: MySQL 5.7, accesible desde el equipo en el puerto `3307`.
- `pokemon-php`: PHP con Apache, accesible en el puerto `8080`.

## Detener el proyecto

Para detener los contenedores sin borrar los datos:

```powershell
docker compose down
```

Para volver a iniciarlos:

```powershell
docker compose up -d
```

## Base de datos

Los archivos `database/pokemonPlus.sql` y `database/pokemon_script_init.sql` se ejecutan automaticamente, en ese orden, la primera vez que se crea el volumen de MySQL.

La base de datos usa estas credenciales dentro de Docker:

```text
Servidor: db
Puerto interno: 3306
Base de datos: pokemonPlus
Usuario de la aplicacion: pokemon_app
Contrasena: la definida en `.env` como `DB_APP_PASSWORD`
```

El usuario administrador `root` utiliza la contrasena definida en `.env` como `DB_ROOT_PASSWORD`.

Desde Windows, el puerto publicado es `3307`:

```text
Servidor: 127.0.0.1
Puerto: 3307
```

Los datos se conservan en el volumen Docker `php-ddbb-master_pokemon-db-data-57`. El codigo PHP se monta directamente desde esta carpeta, por lo que los cambios en los archivos se reflejan en la aplicacion sin reconstruir la imagen.

## Reiniciar la base de datos desde cero

Esto elimina todos los datos guardados en el volumen y vuelve a importar ambos scripts SQL:

```powershell
docker compose down -v
docker compose up -d --build
```

No ejecutes `down -v` si quieres conservar los datos actuales.

## Scripts SQL adicionales

El archivo original `database/pokemon_script.sql` se conserva como referencia. Para la inicializacion automatica se usa `database/pokemon_script_init.sql`, una version adaptada con un unico delimitador y compatible con MySQL 5.7. Crea las columnas, funciones, procedimientos y triggers adicionales despues de importar `pokemonPlus.sql`.

## Comandos utiles

Ver los logs de PHP:

```powershell
docker compose logs -f php-apache
```

Ver los logs de MySQL:

```powershell
docker compose logs -f db
```

Entrar al contenedor PHP:

```powershell
docker exec -it pokemon-php bash
```

Entrar a MySQL:

```powershell
docker exec -it pokemon-db mysql -uroot -p pokemonPlus
```
