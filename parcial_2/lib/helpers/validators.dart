/// Expresiones regulares (regex) para validar los formularios.
class Validators {
  Validators._();

  /// Nombre de usuario: `^[A-Za-z0-9_.-]{3,50}$`
  static final RegExp username = RegExp(r'^[A-Za-z0-9_.\-]{3,50}$');

  /// Correo electrónico (ej. jperez@ufpso.edu.co).
  static final RegExp email = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  /// Contraseña: 6 a 72 caracteres, sin espacios.
  static final RegExp password = RegExp(r'^\S{6,72}$');

  /// Nombre de un contenedor o de un punto ecológico
  static final RegExp name = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} .,'#()°ºª/_\-]{1,99}$",
    unicode: true,
  );

  /// Nombre completo de una persona
  static final RegExp fullName = RegExp(
    r"^[\p{L}][\p{L} .'\-]{1,99}$",
    unicode: true,
  );

  /// Código de contenedor
  static final RegExp code = RegExp(r'^[A-Za-z0-9_.\-]{1,20}$');

  /// Número entero positivo (capacidad).
  static final RegExp integer = RegExp(r'^\d{1,6}$');

  /// Porcentaje con hasta 2 decimales (umbral), acepta punto o coma.
  static final RegExp decimal = RegExp(r'^\d{1,3}([.,]\d{1,2})?$');

  
  static bool isValidUserOrEmail(String value) {
    final text = value.trim();
    return username.hasMatch(text) || email.hasMatch(text);
  }

  static bool isValidPassword(String value) => password.hasMatch(value);

  static bool isValidEmail(String value) => email.hasMatch(value.trim());

  static bool isValidName(String value) => name.hasMatch(value.trim());

  static bool isValidFullName(String value) => fullName.hasMatch(value.trim());

  /// Capacidad entre 1 y 100000 (regla del backend).
  static bool isValidCapacity(String value) {
    final text = value.trim();
    if (!integer.hasMatch(text)) return false;
    final number = int.parse(text);
    return number >= 1 && number <= 100000;
  }

  /// Umbral entre 1 y 100 (regla del backend).
  static bool isValidThreshold(String value) {
    final text = value.trim();
    if (!decimal.hasMatch(text)) return false;
    final number = double.parse(text.replaceAll(',', '.'));
    return number >= 1 && number <= 100;
  }

  static double? parseDecimal(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }
}
