library;

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validarCorreo(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Escribe tu correo';
  if (!_email.hasMatch(text)) return 'Ese correo no es válido';
  return null;
}

String? validarClave(String? value) {
  if ((value ?? '').length < 6) return 'Usa al menos 6 caracteres';
  return null;
}

String? validarNombreEquipo(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Ponle un nombre al equipo';
  if (text.length > 24) return 'Usa hasta 24 caracteres';
  return null;
}
