String mensajeDeError(Object error) => switch (error) {
  StateError(:final message) => message,
  ArgumentError(:final message) => '$message',
  FormatException(:final message) => message,
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
