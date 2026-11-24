/// Perfiles que maneja EcoTrack (campo `role` del backend).
enum UserRole {
  administrador,
  recolector,
  interesado,

  /// Cualquier valor que la app no reconozca. No tiene acceso a ningún módulo.
  desconocido;

  /// Perfiles válidos dentro de la app.
  static const Set<UserRole> registered = {
    administrador,
    recolector,
    interesado,
  };

  static UserRole fromValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.desconocido,
    );
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.roleLabel,
    required this.isActive,
    this.fullName,
    this.createdAt,
    this.lastLoginAt,
  });

  final int id;
  final String username;
  final String email;
  final String? fullName;
  final UserRole role;
  final String roleLabel;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  /// Nombre para mostrar: el nombre completo o, si no tiene, el usuario.
  String get displayName {
    final name = fullName?.trim() ?? '';
    return name.isNotEmpty ? name : username;
  }

  // Iniciales avatar 
  String get initials {
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final first = words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return (first + last).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      role: UserRole.fromValue(json['role']?.toString()),
      roleLabel: json['role_label']?.toString() ?? '',
      isActive: json['is_active'] == true,
      createdAt: _parseDate(json['created_at']),
      lastLoginAt: _parseDate(json['last_login_at']),
    );
  }

  /// Usuario de ejemplo que se dibuja como esqueleto mientras carga.
  factory UserModel.placeholder([int index = 0]) {
    return UserModel(
      id: -1 - index,
      username: 'usuario',
      email: 'usuario@ufpso.edu.co',
      fullName: 'Nombre del usuario',
      role: UserRole.registered.elementAt(index % 3),
      roleLabel: 'Perfil',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'role_label': roleLabel,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
