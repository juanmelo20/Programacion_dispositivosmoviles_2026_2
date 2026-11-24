import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/admin/event_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/providers/auth_provider.dart';

/// Extensiones de AppLocalizations para mostrar mensajes de la app en el
/// idioma del usuario. Se usan en los widgets de alerta y en los de estado de la app.
extension AppMessages on AppLocalizations {
  String roleName(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return roleAdministrador;
      case UserRole.recolector:
        return roleRecolector;
      case UserRole.interesado:
        return roleInteresado;
      case UserRole.desconocido:
        return roleDesconocido;
    }
  }

  /// Mensaje para una consulta que falló.
  String errorMessage(ApiErrorType? type) {
    switch (type) {
      case ApiErrorType.noConnection:
        return errorNoConnection;
      case ApiErrorType.timeout:
        return errorTimeout;
      case ApiErrorType.unauthorized:
        return sessionExpired;
      case ApiErrorType.forbidden:
        return errorForbidden;
      case ApiErrorType.notFound:
        return errorNotFound;
      default:
        return errorServer;
    }
  }

  // Mensaje para una acción de guardar, editar o eliminar que falló.
  String actionErrorMessage(Object error) {
    if (error is! ApiException) return actionError;
    final translated = apiErrorMessage(error.errorCode, error.errorParams);
    if (translated != null) return translated;
    if (error.type == ApiErrorType.validation && error.serverMessage != null) {
      return error.serverMessage!;
    }
    switch (error.type) {
      case ApiErrorType.noConnection:
        return errorNoConnection;
      case ApiErrorType.timeout:
        return errorTimeout;
      case ApiErrorType.forbidden:
        return errorForbidden;
      default:
        return actionError;
    }
  }

  String loginMessage(LoginResult result, {int lockSeconds = 0}) {
    switch (result) {
      case LoginResult.success:
        return '';
      case LoginResult.invalidCredentials:
        return invalidCredentials;
      case LoginResult.tooManyAttempts:
        return tooManyAttempts(lockSeconds);
      case LoginResult.noConnection:
        return errorNoConnection;
      case LoginResult.timeout:
        return errorTimeout;
      case LoginResult.serverError:
        return errorServer;
    }
  }

  /// Mensaje de un error de negocio a partir de su código (`code` en la
  /// respuesta de la API). Devuelve null si la app no conoce el código.
  String? apiErrorMessage(String? code, Map<String, dynamic> params) {
    switch (code) {
      case 'LOCATION_NOT_FOUND':
        return apiErrorLocationNotFound;
      case 'LOCATION_NAME_TAKEN':
        return apiErrorLocationNameTaken(_param(params, 'name'));
      case 'LOCATION_HAS_TERMINALS':
        return apiErrorLocationHasTerminals(_param(params, 'terminals'));
      case 'LOCATION_HAS_HISTORY':
        return apiErrorLocationHasHistory;
      case 'CONTAINER_NOT_FOUND':
        return apiErrorContainerNotFound(_param(params, 'id'));
      case 'CONTAINER_CODE_TAKEN':
        return apiErrorContainerCodeTaken(_param(params, 'code'));
      case 'CONTAINER_LOCATION_NOT_FOUND':
        return apiErrorContainerLocationNotFound;
      case 'CONTAINER_INACTIVE':
        return apiErrorContainerInactive;
      case 'USER_NOT_FOUND':
        return apiErrorUserNotFound(_param(params, 'id'));
      case 'USER_ALREADY_EXISTS':
        return apiErrorUserAlreadyExists;
      case 'USER_OWN_ROLE':
        return apiErrorUserOwnRole;
      case 'USER_OWN_DEACTIVATION':
        return apiErrorUserOwnDeactivation;
      case 'USER_LAST_ADMIN':
        return apiErrorUserLastAdmin;
      default:
        return null;
    }
  }

  /// Tipo de evento de la bitácora en el idioma de la app.
  String eventTypeName(String code, {String? fallback}) {
    switch (code) {
      case 'INICIO_SISTEMA':
        return eventTypeInicioSistema;
      case 'INICIO_SESION':
        return eventTypeInicioSesion;
      case 'SESION_FALLIDA':
        return eventTypeSesionFallida;
      case 'BAJA_CONFIANZA':
        return eventTypeBajaConfianza;
      case 'CLASIFICACION_RECHAZADA':
        return eventTypeClasificacionRechazada;
      case 'SIN_DETECCION':
        return eventTypeSinDeteccion;
      case 'ALERTA_LLENADO':
        return eventTypeAlertaLlenado;
      case 'CAPACIDAD_ALCANZADA':
        return eventTypeCapacidadAlcanzada;
      case 'RECOLECCION':
        return eventTypeRecoleccion;
      case 'REVISION':
        return eventTypeRevision;
      case 'CONFIGURACION':
        return eventTypeConfiguracion;
      case 'CONTENEDOR':
        return eventTypeContenedor;
      case 'UBICACION':
        return eventTypeUbicacion;
      case 'USUARIO':
        return eventTypeUsuario;
      case 'EXPORTACION':
        return eventTypeExportacion;
      case 'RENDIMIENTO':
        return eventTypeRendimiento;
      case 'ERROR_IMAGEN':
        return eventTypeErrorImagen;
      case 'ERROR_DETECCION':
        return eventTypeErrorDeteccion;
      case 'SIN_CONTENEDOR':
        return eventTypeSinContenedor;
      case 'RESIDUO_ESPECIAL':
        return eventTypeResiduoEspecial;
      case 'PUNTO_ECOLOGICO':
        return eventTypePuntoEcologico;
      case 'TERMINAL':
        return eventTypeTerminal;
      default:
        return fallback ?? code;
    }
  }

  /// Nombre de la categoría en el idioma de la app.
  String categoryName(String code, {String? fallback, bool short = false}) {
    switch (code) {
      case WasteCategory.recyclable:
        return categoryRecyclable;
      case WasteCategory.organic:
        return short ? categoryOrganicShort : categoryOrganic;
      case WasteCategory.nonRecyclable:
        return categoryNonRecyclable;
      default:
        return fallback ?? code;
    }
  }

  /// Estado de llenado en el idioma de la app.
  String fillStatusName(String code, {String? fallback}) {
    switch (code) {
      case FillStatus.normal:
        return statusNormal;
      case FillStatus.attention:
        return statusAttention;
      case FillStatus.full:
        return statusFull;
      default:
        return fallback ?? code;
    }
  }

  String eventLevelName(String level) {
    switch (level) {
      case EventLevel.info:
        return levelInfo;
      case EventLevel.warning:
        return levelWarning;
      case EventLevel.error:
        return levelError;
      default:
        return level;
    }
  }

  /// Tipo de punto en el historial de llenado.
  String fillEventName(String event) {
    switch (event) {
      case 'inicio':
        return eventStart;
      case 'clasificacion':
        return eventClassification;
      case 'recoleccion':
        return eventCollection;
      case 'actual':
        return eventCurrent;
      default:
        return event;
    }
  }
}

String _param(Map<String, dynamic> params, String name) =>
    params[name]?.toString() ?? '';
