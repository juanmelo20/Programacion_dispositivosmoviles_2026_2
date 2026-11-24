// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'EcoTrack AI';

  @override
  String get appSubtitle => 'Gestión inteligente de residuos';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginTitle => 'Bienvenido';

  @override
  String get loginSubtitle => 'Ingresa con tu usuario o correo institucional.';

  @override
  String get userLabel => 'Usuario o correo';

  @override
  String get userHint => 'ej. jperez o jperez@ufpso.edu.co';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidUser =>
      'Usa de 3 a 50 caracteres (letras, números, . _ -) o un correo válido';

  @override
  String get invalidPassword =>
      'La contraseña debe tener entre 6 y 72 caracteres, sin espacios';

  @override
  String get completeAllFields => 'Por favor completa todos los campos';

  @override
  String get checkFields => 'Revisa los campos marcados en rojo';

  @override
  String get invalidCredentials => 'Credenciales inválidas';

  @override
  String tooManyAttempts(int seconds) {
    return 'Demasiados intentos fallidos. Intenta de nuevo en $seconds s.';
  }

  @override
  String get errorNoConnection =>
      'No hay conexión con el servidor. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout => 'La conexión está muy lenta. Inténtalo de nuevo.';

  @override
  String get errorServer => 'Ocurrió un error inesperado. Inténtalo más tarde.';

  @override
  String get pressBackAgainToExit =>
      'Presiona atrás otra vez para salir de la app.';

  @override
  String get errorForbidden => 'No tienes permiso para ver esta información.';

  @override
  String get errorNotFound => 'No encontramos lo que buscabas.';

  @override
  String get sessionExpired => 'Tu sesión expiró. Inicia sesión de nuevo.';

  @override
  String get checkingSession => 'Verificando tu sesión…';

  @override
  String get sessionCheckFailed => 'No pudimos verificar tu sesión.';

  @override
  String get retry => 'Reintentar';

  @override
  String get goToLogin => 'Ir al inicio de sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get logoutConfirmMessage =>
      'Tendrás que ingresar de nuevo tus credenciales.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get close => 'Cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get notFoundTitle => 'Página no encontrada';

  @override
  String get backHome => 'Volver al inicio';

  @override
  String apiServer(String url) {
    return 'Servidor: $url';
  }

  @override
  String get slowConnection => 'La conexión está lenta. Seguimos cargando…';

  @override
  String get emptyList => 'Todavía no hay datos para mostrar.';

  @override
  String get actionError =>
      'No fue posible completar la acción. Inténtalo de nuevo.';

  @override
  String get savedOk => 'Cambios guardados';

  @override
  String get selectOption => 'Selecciona una opción';

  @override
  String get optional => 'Opcional';

  @override
  String get allLabel => 'Todos';

  @override
  String get never => 'Nunca';

  @override
  String get roleAdministrador => 'Administrador';

  @override
  String get roleRecolector => 'Recolector';

  @override
  String get roleInteresado => 'Interesado';

  @override
  String get roleDesconocido => 'Sin perfil';

  @override
  String get menuHome => 'Inicio';

  @override
  String get moduleContainers => 'Contenedores';

  @override
  String get moduleAlerts => 'Alertas de llenado';

  @override
  String get moduleRoute => 'Ruta de recolección';

  @override
  String get moduleCollections => 'Recolecciones';

  @override
  String get moduleEcoPoints => 'Puntos ecológicos';

  @override
  String get moduleUsers => 'Usuarios';

  @override
  String get moduleReports => 'Informes';

  @override
  String get moduleEvents => 'Bitácora';

  @override
  String get moduleProfile => 'Mi perfil';

  @override
  String get titleContainerDetail => 'Detalle del contenedor';

  @override
  String get titleFillHistory => 'Historial de llenado';

  @override
  String get titleNewContainer => 'Nuevo contenedor';

  @override
  String get titleEditContainer => 'Editar contenedor';

  @override
  String get titleNewUser => 'Nuevo usuario';

  @override
  String get titleEditUser => 'Editar usuario';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeAdminDescription =>
      'Supervisa contenedores, puntos ecológicos, usuarios e informes del campus.';

  @override
  String get homeCollectorDescription =>
      'Consulta los contenedores que necesitan recolección y registra tus rutas.';

  @override
  String get homeInterestedDescription =>
      'Consulta los informes y el impacto del reciclaje en el campus.';

  @override
  String get homeUnknownDescription =>
      'Tu perfil todavía no tiene módulos asignados.';

  @override
  String sessionValidUntil(String time) {
    return 'Sesión válida hasta $time';
  }

  @override
  String get modulesTitle => 'Tus módulos';

  @override
  String get homeTodaySummary => 'Resumen de hoy';

  @override
  String get homeEcoPoints => 'Puntos ecológicos activos';

  @override
  String get homeEcoPointsEmpty => 'No hay puntos ecológicos activos.';

  @override
  String pointActiveContainers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores activos',
      one: '1 contenedor activo',
    );
    return '$_temp0';
  }

  @override
  String homeRouteCard(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores en tu ruta',
      one: '1 contenedor en tu ruta',
      zero: 'Tu ruta está vacía',
    );
    return '$_temp0';
  }

  @override
  String homeAlertsCard(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores necesitan recolección',
      one: '1 contenedor necesita recolección',
      zero: 'Ningún contenedor necesita recolección',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get kpiToday => 'Clasificados hoy';

  @override
  String get kpiActiveContainers => 'Contenedores activos';

  @override
  String get kpiAttention => 'Requieren atención';

  @override
  String get kpiFull => 'Llenos';

  @override
  String get kpiAverageFill => 'Llenado promedio';

  @override
  String get kpiCollectionsToday => 'Recolecciones hoy';

  @override
  String get categoryRecyclable => 'Aprovechable';

  @override
  String get categoryOrganic => 'Orgánico aprovechable';

  @override
  String get categoryOrganicShort => 'Orgánico';

  @override
  String get categoryNonRecyclable => 'No aprovechable';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusAttention => 'Requiere atención';

  @override
  String get statusFull => 'Lleno';

  @override
  String get allStatuses => 'Todos los estados';

  @override
  String get searchEcoPoints => 'Buscar por nombre, zona o descripción';

  @override
  String get searchContainers => 'Buscar por nombre o código';

  @override
  String get showRetired => 'Ver retirados';

  @override
  String containerUnits(int count, int capacity) {
    return '$count de $capacity residuos';
  }

  @override
  String ecoPointFilter(String name) {
    return 'Punto: $name';
  }

  @override
  String get containersEmpty => 'No hay contenedores con estos filtros.';

  @override
  String get menuViewDetail => 'Ver detalle';

  @override
  String get menuFillHistory => 'Historial de llenado';

  @override
  String get menuAddToRoute => 'Agregar a mi ruta';

  @override
  String get menuRemoveFromRoute => 'Quitar de mi ruta';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuRetire => 'Retirar';

  @override
  String get menuReactivate => 'Reactivar';

  @override
  String get retireTitle => '¿Retirar el contenedor?';

  @override
  String get retireMessage =>
      'Dejará de recibir residuos. Su historial se conserva.';

  @override
  String get retiredBadge => 'Retirado';

  @override
  String addedToRoute(String name) {
    return '$name se agregó a tu ruta';
  }

  @override
  String removedFromRoute(String name) {
    return '$name se quitó de tu ruta';
  }

  @override
  String get inRouteBadge => 'En la ruta';

  @override
  String get detailCapacity => 'Capacidad';

  @override
  String get detailThreshold => 'Umbral de alerta';

  @override
  String detailThresholdGlobal(String value) {
    return '$value (global)';
  }

  @override
  String get detailCurrentCount => 'Residuos actuales';

  @override
  String get detailLastCollection => 'Última recolección';

  @override
  String get detailSinceCollection => 'Desde la última recolección';

  @override
  String get detailLowConfidence => 'Baja confianza';

  @override
  String get detailTotalClassifications => 'Clasificados en total';

  @override
  String get detailRecentClassifications => 'Últimas clasificaciones';

  @override
  String get detailRecentCollections => 'Recolecciones recientes';

  @override
  String get detailNoCollections => 'Aún no hay recolecciones.';

  @override
  String confidenceValue(String value) {
    return 'Confianza $value';
  }

  @override
  String get registerCollection => 'Registrar recolección';

  @override
  String registerCollectionTitle(String code) {
    return 'Registrar recolección de $code';
  }

  @override
  String get registerCollectionMessage =>
      'El conteo del contenedor volverá a cero.';

  @override
  String get notesLabel => 'Observaciones (opcional)';

  @override
  String get notesTooLong => 'Máximo 500 caracteres';

  @override
  String collectionRegistered(int units) {
    return 'Recolección registrada: $units residuos. El conteo volvió a cero.';
  }

  @override
  String get fillHistoryPeriod => 'Últimos 14 días';

  @override
  String get fillHistoryEmpty => 'Sin movimientos en este periodo.';

  @override
  String thresholdLine(String value) {
    return 'Umbral $value';
  }

  @override
  String get eventStart => 'Inicio';

  @override
  String get eventClassification => 'Residuo clasificado';

  @override
  String get eventCollection => 'Recolección';

  @override
  String get eventCurrent => 'Ahora';

  @override
  String get fillHistoryMovements => 'Movimientos';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldCode => 'Código (opcional)';

  @override
  String get fieldCodeHint => 'Si lo dejas vacío se genera solo';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldEcoPoint => 'Punto ecológico';

  @override
  String get fieldCapacity => 'Capacidad (residuos)';

  @override
  String get fieldThreshold => 'Umbral propio % (opcional)';

  @override
  String get fieldThresholdHint => 'Vacío = usa el umbral global';

  @override
  String get fieldActive => 'Activo';

  @override
  String get invalidName => 'Usa entre 2 y 100 caracteres';

  @override
  String get invalidCode => 'Hasta 20 caracteres: letras, números, - _ .';

  @override
  String get invalidCapacity => 'Ingresa un número entero entre 1 y 100000';

  @override
  String get invalidThreshold => 'Ingresa un valor entre 1 y 100';

  @override
  String get containerCreated => 'Contenedor creado';

  @override
  String get containerUpdated => 'Contenedor actualizado';

  @override
  String alertsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores requieren atención',
      one: '1 contenedor requiere atención',
    );
    return '$_temp0';
  }

  @override
  String get alertsEmpty =>
      'Todo en orden: ningún contenedor supera el umbral.';

  @override
  String get addAllToRoute => 'Agregar todos a mi ruta';

  @override
  String addedAllToRoute(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores agregados a tu ruta',
      one: '1 contenedor agregado a tu ruta',
      zero: 'Ya estaban en tu ruta',
    );
    return '$_temp0';
  }

  @override
  String get routeEmptyTitle => 'Tu ruta está vacía';

  @override
  String get routeEmptyMessage =>
      'Agrega contenedores desde Alertas de llenado o Contenedores.';

  @override
  String get goToAlerts => 'Ver alertas';

  @override
  String routeSummary(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores',
      one: '1 contenedor',
    );
    return '$_temp0 · $units residuos';
  }

  @override
  String get routeHint =>
      'Mantén presionado y arrastra para reordenar. Desliza para quitar.';

  @override
  String routeRegisterAll(int count) {
    return 'Registrar recolección ($count)';
  }

  @override
  String get routeConfirmTitle => '¿Registrar la recolección?';

  @override
  String routeConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se registrará la recolección de $count contenedores y su conteo volverá a cero.',
      one: 'Se registrará la recolección de 1 contenedor y su conteo volverá a cero.',
    );
    return '$_temp0';
  }

  @override
  String routeProgress(int current, int total) {
    return 'Registrando $current de $total…';
  }

  @override
  String routeDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ruta completada: $count recolecciones registradas.',
      one: 'Ruta completada: 1 recolección registrada.',
    );
    return '$_temp0';
  }

  @override
  String routePartial(int ok, int failed) {
    return '$ok registradas, $failed no se pudieron registrar. Quedan en tu ruta.';
  }

  @override
  String routeOffline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sin conexión con el servidor: se registraron $count recolecciones. Los demás contenedores siguen en tu ruta, guardada en el celular.',
      one: 'Sin conexión con el servidor: se registró 1 recolección. Los demás contenedores siguen en tu ruta, guardada en el celular.',
      zero: 'Sin conexión con el servidor: no se registró ninguna recolección. Tu ruta sigue guardada en el celular; regístrala cuando vuelva la conexión.',
    );
    return '$_temp0';
  }

  @override
  String get routeClear => 'Vaciar ruta';

  @override
  String get routeRemove => 'Quitar';

  @override
  String get periodToday => 'Hoy';

  @override
  String periodDays(int days) {
    return '$days días';
  }

  @override
  String get collectionsEmpty => 'No hay recolecciones en este periodo.';

  @override
  String collectedBy(String name) {
    return 'Por $name';
  }

  @override
  String unitsCollected(int units) {
    return '$units residuos';
  }

  @override
  String fillAtCollection(String value) {
    return 'Llenado $value';
  }

  @override
  String collectionsTotal(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recolecciones',
      one: '1 recolección',
    );
    return '$_temp0 · $units residuos';
  }

  @override
  String get ecoPointsEmpty => 'Todavía no hay puntos ecológicos.';

  @override
  String pointContainers(int active, int total) {
    return '$active de $total contenedores activos';
  }

  @override
  String get activeBadge => 'Activo';

  @override
  String get inactiveBadge => 'Inactivo';

  @override
  String get newEcoPoint => 'Nuevo punto';

  @override
  String get editEcoPoint => 'Editar punto';

  @override
  String get fieldZone => 'Bloque o zona (opcional)';

  @override
  String get fieldDescription => 'Descripción (opcional)';

  @override
  String get invalidZone => 'Máximo 100 caracteres';

  @override
  String get invalidDescription => 'Máximo 255 caracteres';

  @override
  String get menuViewContainers => 'Ver contenedores';

  @override
  String get menuActivate => 'Activar';

  @override
  String get menuDeactivate => 'Desactivar';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get deletePointTitle => '¿Eliminar el punto ecológico?';

  @override
  String get deletePointMessage => 'Esta acción no se puede deshacer.';

  @override
  String get ecoPointSaved => 'Punto ecológico guardado';

  @override
  String get ecoPointDeleted => 'Punto ecológico eliminado';

  @override
  String get searchUsers => 'Buscar por nombre, usuario o correo';

  @override
  String get usersEmpty => 'No hay usuarios con esa búsqueda.';

  @override
  String get fieldUsername => 'Usuario';

  @override
  String get fieldEmail => 'Correo';

  @override
  String get fieldFullName => 'Nombre completo (opcional)';

  @override
  String get fieldRole => 'Perfil';

  @override
  String get fieldNewPassword => 'Contraseña';

  @override
  String get fieldPasswordConfirm => 'Confirmar contraseña';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get invalidEmail => 'Ingresa un correo válido';

  @override
  String get invalidUsername => 'De 3 a 50 caracteres: letras, números, . _ -';

  @override
  String get invalidFullName => 'Usa letras y espacios (2 a 100)';

  @override
  String get userCreated => 'Usuario creado';

  @override
  String get userUpdated => 'Usuario actualizado';

  @override
  String get menuResetPassword => 'Restablecer contraseña';

  @override
  String resetPasswordTitle(String username) {
    return 'Nueva contraseña para $username';
  }

  @override
  String get passwordUpdated => 'Contraseña actualizada';

  @override
  String deactivateUserTitle(String username) {
    return '¿Desactivar a $username?';
  }

  @override
  String get deactivateUserMessage =>
      'No podrá iniciar sesión hasta que se active de nuevo.';

  @override
  String get youBadge => 'Tú';

  @override
  String lastLoginLabel(String date) {
    return 'Último ingreso: $date';
  }

  @override
  String get neverSignedIn => 'Nunca ha ingresado';

  @override
  String get cantEditOwnRole =>
      'No puedes cambiar tu propio perfil ni desactivarte.';

  @override
  String get allEcoPoints => 'Todos los puntos';

  @override
  String reportRange(String start, String end) {
    return 'Del $start al $end';
  }

  @override
  String get kpiClassifications => 'Clasificados';

  @override
  String get kpiValid => 'Válidos';

  @override
  String get kpiLowConfidence => 'Baja confianza';

  @override
  String get kpiRejected => 'Rechazados';

  @override
  String get kpiAvgConfidence => 'Confianza promedio';

  @override
  String get kpiCollections => 'Recolecciones';

  @override
  String get kpiUnitsCollected => 'Residuos recolectados';

  @override
  String get kpiDailyAverage => 'Promedio diario';

  @override
  String get chartByCategory => 'Por categoría';

  @override
  String get chartDaily => 'Clasificados por día';

  @override
  String get chartByLocation => 'Por punto ecológico';

  @override
  String get chartByHour => 'Horas de mayor uso';

  @override
  String get chartTopContainers => 'Contenedores con más residuos';

  @override
  String get reportEmptySection => 'Sin datos en este periodo.';

  @override
  String get searchEvents => 'Buscar en la bitácora';

  @override
  String get eventsEmpty => 'No hay eventos con estos filtros.';

  @override
  String eventsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String get levelInfo => 'Información';

  @override
  String get levelWarning => 'Advertencia';

  @override
  String get levelError => 'Error';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileUsername => 'Usuario';

  @override
  String get profileEmail => 'Correo';

  @override
  String get profileRole => 'Perfil';

  @override
  String get profileCreated => 'Cuenta creada';

  @override
  String get profileLastLogin => 'Último ingreso';

  @override
  String get profileSecurity => 'Seguridad';

  @override
  String get profileSessionUntil => 'Sesión válida hasta';

  @override
  String get profileTokenStored =>
      'Tu token se guarda cifrado en este dispositivo y viaja en la cabecera Authorization.';

  @override
  String get profilePreferences => 'Preferencias';

  @override
  String get homeLast7Days => 'Últimos 7 días';

  @override
  String get fieldCapacityHint => 'Vacío = capacidad por defecto (50)';

  @override
  String get undo => 'Deshacer';

  @override
  String get routeClearConfirm =>
      'Se quitarán todos los contenedores de tu ruta.';

  @override
  String get usernameLocked => 'El usuario no se puede cambiar';

  @override
  String get clearFilter => 'Quitar filtro';

  @override
  String get containerRetired => 'Contenedor retirado';

  @override
  String get containerReactivated => 'Contenedor reactivado';

  @override
  String get userActivated => 'Usuario activado';

  @override
  String get userDeactivated => 'Usuario desactivado';

  @override
  String get ecoPointActivated => 'Punto ecológico activado';

  @override
  String get ecoPointDeactivated => 'Punto ecológico desactivado';

  @override
  String ofLabel(int shown, int total) {
    return '$shown de $total';
  }

  @override
  String chartMax(String value) {
    return 'máx. $value';
  }

  @override
  String get apiErrorLocationNotFound => 'El punto ecológico ya no existe.';

  @override
  String apiErrorLocationNameTaken(String name) {
    return 'Ya existe un punto ecológico con el nombre $name.';
  }

  @override
  String apiErrorLocationHasTerminals(String terminals) {
    return 'Este punto tiene terminales asignadas ($terminals). Cámbialas a otro punto o quítalas y vuelve a intentarlo.';
  }

  @override
  String get apiErrorLocationHasHistory =>
      'Este punto tiene contenedores o clasificaciones. Desactívalo en lugar de eliminarlo para conservar el histórico.';

  @override
  String apiErrorContainerNotFound(String id) {
    return 'El contenedor #$id ya no existe.';
  }

  @override
  String apiErrorContainerCodeTaken(String code) {
    return 'Ya existe un contenedor con el código $code.';
  }

  @override
  String get apiErrorContainerLocationNotFound =>
      'El punto ecológico elegido no existe.';

  @override
  String get apiErrorContainerInactive => 'El contenedor está desactivado.';

  @override
  String apiErrorUserNotFound(String id) {
    return 'El usuario #$id ya no existe.';
  }

  @override
  String get apiErrorUserAlreadyExists =>
      'El nombre de usuario o el correo ya están registrados.';

  @override
  String get apiErrorUserOwnRole => 'No puedes cambiar tu propio perfil.';

  @override
  String get apiErrorUserOwnDeactivation =>
      'No puedes desactivar tu propia cuenta.';

  @override
  String get apiErrorUserLastAdmin =>
      'Debe quedar al menos un administrador activo.';

  @override
  String get eventTypeInicioSistema => 'Inicio del sistema';

  @override
  String get eventTypeInicioSesion => 'Inicio de sesión';

  @override
  String get eventTypeSesionFallida => 'Intento de sesión fallido';

  @override
  String get eventTypeBajaConfianza => 'Clasificación con baja confianza';

  @override
  String get eventTypeClasificacionRechazada => 'Clasificación rechazada';

  @override
  String get eventTypeSinDeteccion => 'Imagen sin residuo detectado';

  @override
  String get eventTypeAlertaLlenado => 'Contenedor superó el umbral';

  @override
  String get eventTypeCapacidadAlcanzada => 'Contenedor alcanzó su capacidad';

  @override
  String get eventTypeRecoleccion => 'Recolección registrada';

  @override
  String get eventTypeRevision => 'Revisión de clasificación';

  @override
  String get eventTypeConfiguracion => 'Cambio de parámetros';

  @override
  String get eventTypeContenedor => 'Gestión de contenedores';

  @override
  String get eventTypeUbicacion => 'Gestión de ubicaciones';

  @override
  String get eventTypeUsuario => 'Gestión de usuarios';

  @override
  String get eventTypeExportacion => 'Exportación de datos';

  @override
  String get eventTypeRendimiento => 'Tiempo de procesamiento alto';

  @override
  String get eventTypeErrorImagen => 'Imagen no válida';

  @override
  String get eventTypeErrorDeteccion => 'Error en el motor de detección';

  @override
  String get eventTypeSinContenedor => 'Sin contenedor disponible';

  @override
  String get eventTypeResiduoEspecial => 'Residuo peligroso presentado';

  @override
  String get eventTypePuntoEcologico => 'Punto ecológico en vivo';

  @override
  String get eventTypeTerminal => 'Gestión de terminales';

  @override
  String get offlineBanner =>
      'Sin conexión: mostrando los datos guardados en el celular.';

  @override
  String lastDownloadAt(String date) {
    return 'Última actualización: $date';
  }

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes de sincronizar',
      one: '1 cambio pendiente de sincronizar',
    );
    return '$_temp0';
  }

  @override
  String failedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios no se pudieron sincronizar',
      one: '1 cambio no se pudo sincronizar',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar';

  @override
  String get syncing => 'Sincronizando…';

  @override
  String syncDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se guardaron $count cambios en el sistema',
      one: 'Se guardó 1 cambio en el sistema',
    );
    return '$_temp0';
  }

  @override
  String get savedOffline =>
      'Guardado sin conexión. Se guardará en el sistema automáticamente cuando vuelva la conexión.';

  @override
  String get deletedOffline =>
      'Eliminado sin conexión. Se eliminará del sistema automáticamente cuando vuelva la conexión.';

  @override
  String get pendingCreate => 'Pendiente: crear';

  @override
  String get pendingUpdate => 'Pendiente: editar';

  @override
  String get pendingDelete => 'Pendiente: eliminar';

  @override
  String get syncErrorBadge => 'No se pudo sincronizar';

  @override
  String get menuDiscardChange => 'Descartar cambio';

  @override
  String get menuViewSyncError => 'Ver el error';

  @override
  String get changeDiscarded => 'Cambio descartado.';

  @override
  String get localOnlyHint =>
      'Punto creado sin conexión: se guardará en el sistema automáticamente cuando haya conexión.';

  @override
  String get moduleTerminals => 'Terminales';

  @override
  String get titleAssignTerminal => 'Agregar terminal';

  @override
  String get terminalsEmpty =>
      'Aún no hay terminales. Abre la pantalla del punto ecológico y agrégala con el código que muestra.';

  @override
  String get terminalStatusUnassigned => 'Sin asignar';

  @override
  String get terminalStatusAssigned => 'Asignada';

  @override
  String get terminalStatusChange => 'Pidió cambio de punto';

  @override
  String get terminalOnline => 'En línea';

  @override
  String get terminalOffline => 'Sin señal';

  @override
  String get terminalNoPoint => 'Sin punto asignado';

  @override
  String terminalLastSeen(String date) {
    return 'Última señal: $date';
  }

  @override
  String get fieldTerminalCode => 'Código de la terminal';

  @override
  String get terminalCodeHelp =>
      'Escribe el código de 6 dígitos que muestra la pantalla de la terminal.';

  @override
  String get terminalCodeInvalid => 'El código debe tener 6 números.';

  @override
  String get terminalFind => 'Buscar terminal';

  @override
  String get terminalFound => 'Terminal encontrada';

  @override
  String terminalAlreadyAt(String point) {
    return 'Ya está en «$point» y pidió cambiarse de punto.';
  }

  @override
  String get terminalWhere => '¿A qué punto ecológico va?';

  @override
  String get terminalExistingPoint => 'Punto existente';

  @override
  String get terminalNewPoint => 'Punto nuevo';

  @override
  String get terminalPickPoint => 'Elige un punto ecológico.';

  @override
  String get terminalNoPoints =>
      'Todavía no hay puntos ecológicos. Crea uno nuevo para esta terminal.';

  @override
  String get terminalNewPointHint =>
      'Se crea el punto con sus tres contenedores: aprovechables, orgánicos y no aprovechables.';

  @override
  String get terminalExistingHint =>
      'Si al punto le falta algún contenedor, se crea al asignar la terminal.';

  @override
  String get terminalAssign => 'Asignar terminal';

  @override
  String terminalAssigned(String terminal, String point) {
    return '$terminal asignada a «$point».';
  }

  @override
  String terminalAssignedWithContainers(
    String terminal,
    String point,
    String codes,
  ) {
    return '$terminal asignada a «$point». Contenedores creados: $codes.';
  }

  @override
  String get menuRemoveTerminal => 'Quitar terminal';

  @override
  String get removeTerminalTitle => '¿Quitar la terminal?';

  @override
  String get removeTerminalMessage =>
      'Si esa pantalla vuelve a abrirse, aparecerá como terminal nueva con un código. Los contenedores del punto no se borran.';

  @override
  String get terminalRemoved => 'Terminal quitada.';

  @override
  String get emptyContainer => 'Vaciar contenedor';

  @override
  String emptyContainerTitle(String code) {
    return 'Vaciar $code';
  }

  @override
  String get emptyContainerMessage =>
      'Se registra la recolección y el conteo del contenedor vuelve a cero.';

  @override
  String containerEmptied(int units) {
    return 'Contenedor vaciado: $units residuos. El conteo volvió a cero.';
  }

  @override
  String get terminalCodeNotFound =>
      'El código no es válido o ya venció. Revisa el que muestra la terminal.';
}
