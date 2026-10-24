# Guía de integración del equipo

## Un solo proyecto compartido

Copiar `codigo-emergencia/` a una carpeta de trabajo y crear el repositorio compartido allí. Las carpetas semanales contienen tareas y parches, no doce aplicaciones que haya que fusionar. Mantener `app_flutter/` y `servidor_api/` bajo la misma raíz.

Cada cambio debe cubrir un objetivo pequeño y tener una prueba o recorrido comprobable. Usar una rama como `codex/semana-02-emma-coleccion` dentro de ese repositorio y pedir revisión al compañero correspondiente. Evitar editar AppController a la vez; Sebastián coordina el contrato. No se ha creado ni publicado ningún repositorio remoto desde esta entrega.

## Qué debe entregar cada integrante

Código, instrucciones de uso y evidencia de su criterio de cierre. La evidencia debe identificar dispositivo, fecha, pasos y resultado. Sebastián verifica integración técnica; Emma comprueba navegación y legibilidad; Miguel ejecuta escenarios de sobres, perfil y reinicio.

Los datos de prueba deben identificar estadísticas ficticias. Las respuestas reales guardadas como evidencia no contienen claves. Conservar `pubspec.lock` para reproducir las dependencias del respaldo.

## Revisión semanal

1. Ejecutar `flutter analyze` y `flutter test` desde app_flutter.
2. Si cambió el servicio, ejecutar `node adapter.test.mjs` desde servidor_api.
3. Recorrer obtener cartas → colección → equipo → partida → resultado.
4. Cerrar y reabrir: colección, equipo y apodo siguen presentes.
5. Registrar cualquier límite pendiente; no marcar consumo real de API sin una consulta real de su cuenta.

## Aplicar un módulo preparado

Desde la raíz del plan: `python3 scripts/integrar_modulo.py semana-02_19-25-octubre/emma /ruta/a/copia-compartida`.

El script comprueba hashes y crea un respaldo fechado de los archivos que sustituye. No modifica archivos fuera de los listados en el manifiesto y no genera las plataformas Flutter. Si el proyecto compartido tiene otro nombre de paquete o estructura, adaptar manualmente el código. Los parches dependen de los contratos del respaldo común y no constituyen versiones históricas de cada semana.
