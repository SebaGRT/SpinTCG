import 'package:supabase_flutter/supabase_flutter.dart';

String mensajeDeError(Object error) => switch (error) {
  StateError(:final message) => message,
  ArgumentError(:final message) => '$message',
  FormatException(:final message) => message,
  AuthRetryableFetchException() => 'Sin conexión. Revisa tu internet.',
  AuthException(code: 'invalid_credentials') =>
    'Correo o contraseña incorrectos',
  AuthException(code: 'user_already_exists') =>
    'Ese correo ya tiene una cuenta',
  AuthException(code: 'email_not_confirmed') =>
    'Confirma tu correo para entrar',
  AuthException(code: 'weak_password') => 'Esa contraseña es muy débil',
  AuthException(:final message) => message,
  PostgrestException() =>
    'No se pudo guardar en tu cuenta. Inténtalo de nuevo.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
