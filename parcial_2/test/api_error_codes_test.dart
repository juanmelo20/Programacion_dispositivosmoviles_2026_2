// Errores con código de la API y tipos de evento: se muestran en el idioma de
// la app, no en el español del servidor.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';

ApiException apiError(int status, Map<String, dynamic> body) =>
    ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/containers'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/containers'),
          statusCode: status,
          data: body,
        ),
      ),
    );

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  final duplicated = apiError(400, {
    'detail': 'Ya existe un contenedor con el código C-04.',
    'code': 'CONTAINER_CODE_TAKEN',
    'params': {'code': 'C-04'},
  });

  test('lee code y params de la respuesta', () {
    expect(duplicated.type, ApiErrorType.validation);
    expect(duplicated.errorCode, 'CONTAINER_CODE_TAKEN');
    expect(duplicated.errorParams, {'code': 'C-04'});
  });

  test('el mensaje sale en el idioma de la app con sus datos', () {
    expect(
      en.actionErrorMessage(duplicated),
      'A container with code C-04 already exists.',
    );
    expect(
      es.actionErrorMessage(duplicated),
      'Ya existe un contenedor con el código C-04.',
    );
    final lastAdmin = apiError(400, {
      'detail': 'Debe quedar al menos un administrador activo.',
      'code': 'USER_LAST_ADMIN',
    });
    expect(
      en.actionErrorMessage(lastAdmin),
      'At least one active administrator must remain.',
    );
  });

  test('sin código (o con uno desconocido) usa el mensaje del servidor', () {
    final unknown = apiError(400, {
      'detail': 'Mensaje nuevo del servidor.',
      'code': 'ALGO_NUEVO',
    });
    expect(en.actionErrorMessage(unknown), 'Mensaje nuevo del servidor.');
    final plain = apiError(409, {'detail': 'Otro mensaje.'});
    expect(plain.errorCode, isNull);
    expect(en.actionErrorMessage(plain), 'Otro mensaje.');
  });

  test('tipos de evento traducidos por código', () {
    expect(en.eventTypeName('ALERTA_LLENADO'), 'Container over its threshold');
    expect(es.eventTypeName('ALERTA_LLENADO'), 'Contenedor superó el umbral');
    expect(
      en.eventTypeName('NUEVO_TIPO', fallback: 'Tipo nuevo'),
      'Tipo nuevo',
    );
  });
}
