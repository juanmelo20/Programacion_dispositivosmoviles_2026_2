# EcoTrack AI — App móvil (Parcial 2)

Cliente en Flutter del sistema **EcoTrack AI** (gestión de residuos sólidos de la UFPSO).
Consume el backend propio en FastAPI (`/api/v1`, documentación Swagger en `http://127.0.0.1:8000/docs`).

Cada perfil entra con su usuario y ve solo sus módulos:

| Perfil | Usuario de prueba | Módulos |
|---|---|---|
| Administrador | `admin` / `admin123` | Inicio, Contenedores, Alertas de llenado, Puntos ecológicos, Terminales, Recolecciones, Usuarios, Informes, Bitácora, Mi perfil |
| Recolector | `recolector` / `recolector123` | Inicio, Ruta de recolección, Contenedores, Alertas, Recolecciones, Mi perfil |
| Interesado | `interesado` / `interesado123` | Inicio, Contenedores (historial de llenado), Puntos ecológicos, Informes, Mi perfil |

## Cómo ejecutar

1. Levanta el backend de EcoTrack en el PC (`python main.py` en la carpeta del backend, puerto 8000).
2. Instala las dependencias: `flutter pub get`
3. Ejecuta según el dispositivo:

| Dispositivo | Comando | URL que usa la app |
|---|---|---|
| Chrome (web) | `flutter run -d chrome` (en VS Code: dispositivo *Chrome*) | `http://localhost:5050` → proxy al backend |
| Windows | `flutter run -d windows` | `http://127.0.0.1:8000` |
| Emulador de Android | `flutter run` | `http://10.0.2.2:8000` |
| Celular por USB | `adb reverse tcp:8000 tcp:8000` y luego `flutter run --dart-define=API_URL=http://127.0.0.1:8000` | el backend del PC a través del cable |
| Celular por wifi | `flutter run --dart-define=API_URL=http://IP_DEL_PC:8000` | la que pases |

- **Después de cambiar dependencias o archivos de configuración** (`pubspec.yaml`, `web_dev_config.yaml`)
  hay que detener la app y volver a ejecutarla; el *hot restart* no los vuelve a leer.
- **Celular por USB** es lo más fácil: `adb reverse` conecta el puerto 8000 del celular con el del PC, así que
  no hay que cambiar el backend ni el firewall. Hay que repetirlo cada vez que se conecta el cable.
- **Celular por wifi:** el PC y el celular deben estar en la misma red; la IP del PC sale con `ipconfig`.
  El backend debe escuchar en la red (`uvicorn app.main:app --host 0.0.0.0 --port 8000`) y el firewall
  de Windows debe permitir Python en redes privadas.
- **Chrome:** el navegador bloquea (CORS) las respuestas de un servidor en otro origen, y el backend solo
  permite los puertos 4200 y 8000. Por eso `web_dev_config.yaml` levanta la app web en `localhost:5050`
  con un proxy: la app pide `/api/...` (datos) y `/media/...` (fotos de las clasificaciones) a su mismo
  origen y el servidor de desarrollo de Flutter lo reenvía a `http://127.0.0.1:8000`. No hay que tocar el
  backend. Si el puerto 5050 está ocupado, cámbialo en ese archivo.
- En modo debug, la pantalla de login muestra abajo a qué servidor se está conectando.

### Red lenta (4G → 3G) y esqueletos

- **Al abrir la app web:** `web/index.html` muestra un esqueleto hecho en HTML y CSS mientras el navegador
  descarga el código de Flutter, con aviso de conexión lenta a los 8 segundos.
- **Dentro de la app:** cada pantalla, mientras espera la API, dibuja un **esqueleto** con la forma de su
  contenido (paquete `skeletonizer`), distinto del indicador de carga. Si la respuesta tarda más de 5 segundos
  (por ejemplo en 3G) aparece arriba el aviso "La conexión está lenta. Seguimos cargando…". Las peticiones
  tienen tiempo máximo (`api_config.dart`) y, si se cortan, se muestra un mensaje con **Reintentar**.
- **Al cambiar de pestaña** (Contenedores, por categoría) o de filtro se consulta de nuevo y se ve el
  esqueleto. Al **actualizar** (deslizar hacia abajo, o después de guardar) los datos siguen visibles con una
  barra de carga fina arriba.
- **Para probarlo:** con la app ya abierta, activa *3G* en las herramientas de Chrome (pestaña Red) y cambia
  de pestaña o de módulo.

### Duración del token

El backend firma un JWT con `exp`: dura **12 horas** (`ACCESS_TOKEN_EXPIRE_MINUTES = 720` en
`app/core/config.py`). La app lee esa fecha y cierra la sesión sola cuando vence; además, si cualquier
petición responde 401, cierra la sesión y avisa en el login.
Para mostrar el vencimiento en la exposición, en el `.env` del backend quita el `#` de
`ACCESS_TOKEN_EXPIRE_MINUTES` y ponle `2`; reinicia el backend, inicia sesión y a los 2 minutos la app vuelve
al login con el aviso "Tu sesión expiró". Después vuelve a comentarlo.

## ¿Qué es Swagger?

Swagger (OpenAPI) es un estándar para describir una API REST: sus endpoints, parámetros, respuestas y
seguridad. FastAPI lo genera solo a partir del código del backend y publica una página interactiva
(Swagger UI, en `/docs`) donde se puede probar cada endpoint con un token.

## Estructura (misma organización del ejemplo del profesor)

```
lib/
├── main.dart                        App, tema, idioma, router y configuración del esqueleto
├── config/
│   ├── api/api_config.dart          URL base, endpoints y tiempos de espera
│   ├── router/
│   │   ├── router_config.dart       GoRouter + guard (redirect)
│   │   ├── router_admin.dart        Módulos y páginas de detalle con sus perfiles
│   │   └── router_model.dart        RouterModel y rutas (AppRoutes)
│   └── theme/app_theme.dart         Tema claro y oscuro
├── helpers/
│   ├── dio_client.dart              Cliente Dio con timeouts
│   ├── interceptor.dart             Cabeceras (Bearer), errores y 401
│   ├── session_events.dart          Aviso de 401 para cerrar la sesión
│   ├── api_exception.dart           Errores controlados
│   ├── api_request.dart             try/catch común de las peticiones
│   ├── json_parse.dart, formatters.dart
│   ├── token.dart                   Token cifrado con flutter_secure_storage
│   └── validators.dart              Regex de los formularios
├── l10n/                            Español e inglés (.arb)
├── model/                           auth/ (sesión) y admin/ (contenedores, puntos, informes…)
├── presentation/
│   ├── public/                      Splash y login
│   ├── admin/                       Un folder por módulo (home, containers, alerts, route,
│   │                                collections, eco_points, users, reports, events, profile, about)
│   │                                y layout/ (AppBar, menú lateral, botón flotante)
│   └── shared/                      Alertas, esqueleto/errores, gráficas, carrusel, widgets comunes
├── providers/                       Sesión, datos de la API, ruta (carrito), bitácora, tema e idioma
└── services/                        auth/ y admin/ (un servicio por módulo)
```

## Requisitos cubiertos

| Requisito | Dónde |
|---|---|
| Login: petición, estatus, mapeo de la respuesta y verificación del token | `services/auth/auth_service.dart` |
| Token cifrado con flutter_secure_storage, `await` con key y value, guardar String | `helpers/token.dart` |
| try/catch y errores enviados a una excepción propia | `helpers/api_request.dart`, `helpers/api_exception.dart` |
| Formularios con controladores, campos obligatorios, regex y alerta "completa todos los campos" | login, contenedor, punto ecológico, usuario, contraseña (`helpers/validators.dart`, `shared/widgets/form_helpers.dart`) |
| "Credenciales inválidas" sin decir qué dato falló | `providers/auth_provider.dart` |
| Back y front controlan lo que ve cada perfil | menú, botones y guard por perfil; el backend responde 403 si se fuerza |
| Navegación con go_router, rutas protegidas y guard con `redirect` | `config/router/` |
| Endpoint de introspección (caducidad del token) | `/auth/me` en la Splash, al volver a la app, en Mi perfil y con el `exp` del JWT |
| Dark / light mode y español / inglés | `providers/theme_provider.dart`, `providers/language_provider.dart`, `l10n/` |
| Consumir la API y guardar/consultar los "productos" | Contenedores: lista, detalle y vaciar (registrar recolección). Los contenedores no se crean a mano: el servidor crea los tres de cada punto al asignarle una terminal (Terminales: agregar con el código de 6 dígitos) |
| Pestañas con esqueleto al cambiar de pestaña (distinto al loader) | `admin/containers/containers_screen.dart`, `shared/widgets/async_view.dart` |
| Abrir el detalle de cada producto | `admin/containers/container_detail_screen.dart` y `fill_history_screen.dart` |
| Carrusel / PageView | Puntos ecológicos activos en el inicio; fotos de las últimas clasificaciones en el detalle |
| Carrito con estado global | Ruta de recolección (`providers/route_provider.dart`), con contador en el AppBar |
| Perfil cargado de una ruta protegida con el token en los headers | `admin/profile/profile_screen.dart` (GET `/auth/me`) |
| Card menu | Menú de cada tarjeta en Contenedores, Puntos ecológicos y Usuarios |
| Headers en Dio y manejo de peticiones y errores | `helpers/interceptor.dart`, `presentation/shared/alerts/app_messages.dart` |
| Cambio de red 4G → 3G (esqueleto y aviso de conexión lenta) | `shared/widgets/async_view.dart`, `web/index.html` |
| Qué es Swagger | `admin/about/about_screen.dart` |
