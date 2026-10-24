<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Sebastián · Día 1 (miércoles 21): el proyecto desde cero

**Meta del día:** crear SpinTCG desde un proyecto Flutter vacío y escribir a mano lo que todos necesitan.

← [Índice de guías](../README.md) · Siguiente: [Día 2](dia2.md)

## Mapa del día

| Paso | Qué haces | Archivo | Entrega |
|---|---|---|---|
| 0–1 | Limpiar la carpeta y crear el proyecto | (comandos) | |
| 2 | Dependencias, fuentes y un `main.dart` mínimo | `pubspec.yaml`, `lib/main.dart` ① | |
| 3 | Nombre «SpinTCG» y permisos de red | Android, Linux, Windows | **Esqueleto en `main` (~10:00)** |
| 4 | Colores, letras y tema | `lib/presentation/theme.dart` | |
| 5 | El botón del mockup | `lib/presentation/widgets/court_button.dart` | |
| 6 | La carta como dato | `lib/domain/tennis_card.dart` | |
| 7 | Pantalla de prueba del tema | `lib/main.dart` ② | **Base visual en `main` (13:00)** |
| 8 | Los 24 tenistas del mockup | `lib/data/demo_catalog.dart` | Súbelo apenas termines |
| 9 | Reglas de la partida | `lib/domain/game.dart` | |
| 10 | Guardar el progreso | `lib/data/local_store.dart` | |
| 11 | Traer el catálogo | `lib/data/catalog_repository.dart` | |
| 12 | El controlador | `lib/application/app_controller.dart` | |
| 13 | Pantalla de prueba del núcleo | `lib/main.dart` ③ | **Núcleo en PR (fin del día)** |

`main.dart` cambia **tres veces** hoy (①②③): cada versión es una pantalla de prueba distinta. El `main.dart` definitivo llega el jueves.

### Cómo leer los bloques de código

- 📄 **`app_flutter/…`** dice en qué archivo escribes. Todas las rutas parten de `app_flutter/`.
- **«Crea» / «Reemplaza todo»:** el archivo queda exactamente como el bloque.
- **«parte 2 de 4 · sigue debajo de la parte anterior»:** los archivos largos vienen en partes. Escríbelas **una debajo de la otra, en el mismo archivo**. Después de cada parte viene su explicación.
- Las líneas `// --- Título ---` también se escriben: separan las secciones del archivo.
- Después de cada archivo: `dart format lib && flutter analyze`. Si algo falla, el mensaje dice el archivo y la línea.

---

## Paso 0 · Limpiar la carpeta

Desde la raíz del repo (la carpeta que tiene `.git`):

```bash
ls        # ¿hay app_flutter/ o servidor_api/ copiadas del kit?
```

Si están, bórralas: son copias del kit, y `flutter create` no puede crear el proyecto encima.

```bash
# Si ya estaban en git:
git rm -r -q app_flutter servidor_api && git commit -m "Partimos de cero"
# Si no estaban en git:
rm -rf app_flutter servidor_api
```

Revisa que el `.gitignore` de la raíz tenga estas líneas (agrégalas si faltan):

```gitignore
# Claves y caché del servidor: nunca al repositorio
.env
**/.local/
node_modules/
*.apk
.idea/
*.iml
# Pantalla de prueba local, capturas generadas y código de referencia
app_flutter/lib/muestra.dart
app_flutter/capturas/png/
referencia/
```

## Paso 1 · Crear el proyecto Flutter

```bash
git switch -c sebastian/dia1-esqueleto
flutter create --org cl.udd --project-name spintcg --platforms android,linux,windows app_flutter
cd app_flutter
rm test/widget_test.dart
```

**Entiende**
- `--project-name spintcg` es el nombre del **paquete Dart**. Las pruebas importan el código como `package:spintcg/...`. ⚠️ Va siempre en minúsculas: **no lo cambies** en `pubspec.yaml`.
- `--org cl.udd` arma el identificador de Android: `cl.udd.spintcg`.
- `--platforms`: **Android** es la entrega. **Linux** y **Windows** sirven para desarrollar en el computador.
- `widget_test.dart` es la prueba del contador de ejemplo: la borramos. Hasta el jueves no habrá pruebas.

## Paso 2 · Dependencias, fuentes y `main.dart` mínimo

**Reemplaza todo** `pubspec.yaml`:

📄 **`app_flutter/pubspec.yaml`** · 44 líneas

```yaml
name: spintcg
description: SpinTCG, TCG de tenis con colección, sobre diario y partidas contra la computadora.
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter
  http: ^1.6.0
  path_provider: ^2.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-500.ttf
          weight: 500
        - asset: assets/fonts/Archivo-600.ttf
          weight: 600
        - asset: assets/fonts/Archivo-700.ttf
          weight: 700
        - asset: assets/fonts/Archivo-800.ttf
          weight: 800
        - asset: assets/fonts/Archivo-900.ttf
          weight: 900
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-400.ttf
          weight: 400
        - asset: assets/fonts/Inter-500.ttf
          weight: 500
        - asset: assets/fonts/Inter-600.ttf
          weight: 600
        - asset: assets/fonts/Inter-700.ttf
          weight: 700
```

Descarga las fuentes (crea `assets/fonts/` con 9 archivos `.ttf`) e instala las dependencias:

```bash
bash ../scripts/descargar_fuentes.sh
flutter pub get
```

**Reemplaza todo** `lib/main.dart` (versión ①). El contador de ejemplo usa una sintaxis de Dart 3.10 (`.fromSeed(...)`) que con `sdk: ^3.8.0` no compila:

📄 **`app_flutter/lib/main.dart`** · 10 líneas · **versión provisional**

```dart
import 'package:flutter/material.dart';

// PROVISIONAL (esqueleto): solo comprueba que el proyecto compila.
// En la mañana se reemplaza por la pantalla de prueba del tema.
void main() => runApp(
  const MaterialApp(
    title: 'SpinTCG',
    home: Scaffold(body: Center(child: Text('SpinTCG'))),
  ),
);
```

**Entiende**
- `http` hace las consultas al servidor y `path_provider` entrega la carpeta privada donde guardamos el progreso.
- `sdk: ^3.8.0`: el código usa *records*, *patterns* y elementos `?x` (Dart 3.8). Así compila aunque Emma o Miguel tengan un Flutter un poco más antiguo.
- **Fuentes:** el mockup usa **Archivo** (títulos y números) e **Inter** (texto). Cada `asset` declara su peso. Cuando un texto pide `FontWeight.w800`, Flutter usa `Archivo-800.ttf`.
- La indentación de YAML importa: `fonts:` va dentro de `flutter:`, con 2 espacios.

## Paso 3 · Nombre visible y permisos

Son cambios pequeños en archivos que creó `flutter create`.

**`android/app/src/main/AndroidManifest.xml`**: agrega la línea del permiso y cambia `android:label`. Las primeras líneas quedan así:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="SpinTCG"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
```

**`android/app/src/debug/AndroidManifest.xml`**: agrega la línea `<application … />`. El archivo completo queda así:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:usesCleartextTraffic="true" />
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

**`linux/runner/my_application.cc`**: hay **dos** líneas con `"spintcg"`. Cambia solo el texto:

```cpp
    gtk_header_bar_set_title(header_bar, "SpinTCG");
```

```cpp
    gtk_window_set_title(window, "SpinTCG");
```

**`windows/runner/main.cpp`**:

```cpp
  if (!window.Create(L"SpinTCG", origin, size)) {
```

**Entiende**
- Sin el permiso `INTERNET`, la APK de entrega no puede conectarse al servidor.
- El servidor local usa `http://` (sin `s`). Android lo bloquea por defecto; lo permitimos **solo en debug**, por eso va en el manifest de `debug/`.

### ✅ Sube el esqueleto (~10:00)

```bash
flutter analyze            # No issues found!
flutter run -d linux       # una ventana «SpinTCG» con el texto SpinTCG
git add -A && git commit -m "Proyecto Flutter SpinTCG: dependencias, fuentes y plataformas"
git push -u origin sebastian/dia1-esqueleto
gh pr create --fill && gh pr merge --squash --delete-branch
```

📣 **Avisa en el chat: «Proyecto en main, ya pueden clonar».**

---

## Paso 4 · Colores, letras y tema

```bash
git switch main && git pull && git switch -c sebastian/dia1-base
```

**Crea** `lib/presentation/theme.dart`. Va en 3 partes.

📄 **`app_flutter/lib/presentation/theme.dart`** · parte 1 de 3 (líneas 1–38) · empieza el archivo

```dart
import 'package:flutter/material.dart';

// --- Marca y colores ---

/// Nombre que aparece en el logo, el reverso de las cartas y el sobre.
const kBrand = 'SpinTCG';

/// Paleta del mockup (Mockup móvil Court Cards/src/index.css).
/// Se usa así: `Court.c800`, `Court.ball`.
abstract final class Court {
  // Verdes de la cancha, del más oscuro al más claro.
  static const c950 = Color(0xff072519);
  static const c900 = Color(0xff0a3324);
  static const c800 = Color(0xff0f4630);
  static const c700 = Color(0xff155c3f);
  static const c600 = Color(0xff1d7550);
  static const c200 = Color(0xffc9ddd0);
  static const c100 = Color(0xffe3eee7);
  static const c50 = Color(0xfff1f6f2);

  // Verde limón de la pelota.
  static const ball = Color(0xffdcf04a);
  static const ballDark = Color(0xffb7cc1c);

  // Fondo, texto, bordes y derrota.
  static const paper = Color(0xfff6f7f2);
  static const ink = Color(0xff11201a);
  static const muted = Color(0xff5e6b64);
  static const line = Color(0xffdfe5df);
  static const loss = Color(0xffb4442f);

  // Grises de botones deshabilitados y cartas bloqueadas.
  static const disabled = Color(0xffe4e8e3);
  static const disabledText = Color(0xff8b958f);
  static const locked = Color(0xffeceee9);
  static const lockedInner = Color(0xffe1e5e0);
  static const segment = Color(0xffe9ece6);
}
```

- `kBrand` es el nombre de la app. Si el curso pide otro, se cambia solo aquí.
- `Court` reúne los colores del mockup. `abstract final class` no se puede instanciar: es solo un lugar con nombre para las constantes (`Court.c800`).
- `Color(0xff0a3324)`: `ff` es la opacidad (100 %) y `0a3324` el color en hexadecimal, igual que `#0a3324` en CSS.

📄 **`app_flutter/lib/presentation/theme.dart`** · parte 2 de 3 (líneas 40–74) · sigue debajo de la parte anterior

```dart
// --- Estilos de texto ---

/// Títulos, números y botones (fuente Archivo).
/// Ejemplo: `display(28)` o `display(16, weight: FontWeight.w700)`.
TextStyle display(
  double size, {
  FontWeight weight = FontWeight.w800,
  Color? color,
  double height = 1.1,
}) {
  return TextStyle(
    fontFamily: 'Archivo',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: -0.02 * size, // letras un poco más juntas
  );
}

/// Texto corriente (fuente Inter). Ejemplo: `body(14, color: Court.muted)`.
TextStyle body(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
```

- `display()` y `body()` son atajos que crean un `TextStyle`. El mockup usa tamaños exactos (`text-[15px]`), así que es más simple escribir `body(15)`.
- Los parámetros entre `{ }` son **con nombre** y opcionales: `display(16, weight: FontWeight.w700)`. Los que tienen `=` traen un valor por defecto.
- `letterSpacing: -0.02 * size`: los títulos van un poco más juntos, como en el mockup.

📄 **`app_flutter/lib/presentation/theme.dart`** · parte 3 de 3 (líneas 76–109) · sigue debajo de la parte anterior

```dart
// --- Tema de Material ---

/// Colores y estilos que Material usa por su cuenta
/// (fondo, SnackBar, hoja inferior y fuente por defecto).
ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Court.c800,
      primary: Court.c800,
      secondary: Court.ball,
      surface: Court.paper,
      error: Court.loss,
    ),
    scaffoldBackgroundColor: Court.paper,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Court.ink,
      displayColor: Court.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Court.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Court.paper,
      showDragHandle: true,
      dragHandleColor: Court.line,
    ),
  );
}
```

- `buildTheme()` fija lo que Material dibuja por su cuenta: el fondo, la fuente por defecto, el SnackBar y la hoja inferior.
- Ojo: es **`ColorScheme.fromSeed`**, con mayúscula. `ColorScheme` es la clase.
- `copyWith` crea una copia del tema cambiando solo lo que se indica.

```bash
dart format lib && flutter analyze
```

## Paso 5 · El botón del mockup

**Crea** `lib/presentation/widgets/court_button.dart`. Va en 4 partes.

📄 **`app_flutter/lib/presentation/widgets/court_button.dart`** · parte 1 de 4 (líneas 1–30) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../theme.dart';

// --- Variantes y tamaños ---

/// Las cinco variantes de botón del mockup (componente Button de ui.tsx).
enum ButtonVariant { primary, accent, secondary, ghost, onDark }

/// lg = 56 px de alto, md = 48 px, sm = 40 px.
enum ButtonSize { lg, md, sm }

class CourtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null = deshabilitado
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon; // ícono a la izquierda (opcional)
  final IconData? iconRight; // ícono a la derecha (opcional)
  final bool full; // ocupa todo el ancho

  const CourtButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.iconRight,
    this.full = false,
  });
```

- Dos `enum` con las opciones: 5 variantes (`primary` verde oscuro, `accent` verde limón, `secondary` blanco con borde, `ghost` sin fondo y `onDark` para fondos oscuros) y 3 tamaños.
- `this.label` va **sin llaves**: es obligatorio y sin nombre (`CourtButton('Guardar')`). Lo demás va entre `{ }`: con nombre y opcional.
- **Deshabilitado = `onPressed: null`**, la misma convención de los botones de Flutter.

📄 **`app_flutter/lib/presentation/widgets/court_button.dart`** · parte 2 de 4 (líneas 32–54) · sigue debajo de la parte anterior

```dart
  // --- Medidas según el tamaño ---

  double get _height => switch (size) {
    ButtonSize.lg => 56,
    ButtonSize.md => 48,
    ButtonSize.sm => 40,
  };

  double get _fontSize => switch (size) {
    ButtonSize.lg => 16,
    ButtonSize.md => 15,
    ButtonSize.sm => 14,
  };

  double get _padding => switch (size) {
    ButtonSize.lg => 24,
    ButtonSize.md => 20,
    ButtonSize.sm => 14,
  };

  double get _radius => size == ButtonSize.lg ? 16 : 12;

  double get _iconSize => size == ButtonSize.sm ? 17 : 20;
```

- Cada medida es un *getter* (`get`): se calcula cuando se pide.
- `switch (size) { ButtonSize.lg => 56, … }` es un `switch` que **devuelve un valor**. Dart obliga a cubrir todos los casos: si mañana se agrega un tamaño, el analizador avisa.

📄 **`app_flutter/lib/presentation/widgets/court_button.dart`** · parte 3 de 4 (líneas 56–92) · sigue debajo de la parte anterior

```dart
  // --- Colores según la variante ---

  /// Fondo. Gris si el botón está deshabilitado.
  Color get _background {
    if (onPressed == null) return Court.disabled;
    return switch (variant) {
      ButtonVariant.primary => Court.c800,
      ButtonVariant.accent => Court.ball,
      ButtonVariant.secondary => Colors.white,
      ButtonVariant.ghost => Colors.transparent,
      ButtonVariant.onDark => Colors.white.withValues(alpha: 0.1),
    };
  }

  /// Color del texto y de los íconos.
  Color get _foreground {
    if (onPressed == null) return Court.disabledText;
    return switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.accent => Court.c900,
      ButtonVariant.secondary => Court.c900,
      ButtonVariant.ghost => Court.c800,
      ButtonVariant.onDark => Colors.white,
    };
  }

  /// Borde: solo lo tienen «secondary» y «onDark».
  BorderSide get _border {
    if (onPressed == null) return BorderSide.none;
    return switch (variant) {
      ButtonVariant.secondary => const BorderSide(color: Court.line),
      ButtonVariant.onDark => BorderSide(
        color: Colors.white.withValues(alpha: 0.2),
      ),
      _ => BorderSide.none,
    };
  }
```

- Los colores dependen de la variante y de si el botón está habilitado. Primero se revisa `onPressed == null` (gris) y después la variante.
- En `_border`, el caso `_` significa «cualquier otra variante».

📄 **`app_flutter/lib/presentation/widgets/court_button.dart`** · parte 4 de 4 (líneas 94–135) · sigue debajo de la parte anterior

```dart
  // --- Dibujo ---

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: full ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _background,
          foregroundColor: _foreground,
          // Sin estas dos líneas, Flutter usa sus grises al deshabilitar.
          disabledBackgroundColor: _background,
          disabledForegroundColor: _foreground,
          padding: EdgeInsets.symmetric(horizontal: _padding),
          textStyle: display(_fontSize, weight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: _border,
          ),
        ),
        child: Row(
          mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: _iconSize),
              const SizedBox(width: 8),
            ],
            // Si el texto no cabe, termina en «…» en vez de desbordar.
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (iconRight != null) ...[
              const SizedBox(width: 8),
              Icon(iconRight, size: _iconSize),
            ],
          ],
        ),
      ),
    );
  }
}
```

- `SizedBox` fija el alto. Con `full: true` el ancho es `double.infinity`: ocupa todo el espacio disponible.
- `TextButton.styleFrom` aplica los colores y medidas de arriba.
- `if (icon != null) ...[ … ]` agrega el ícono y su separación **solo si existe**.
- `Flexible` + `TextOverflow.ellipsis`: si el texto no cabe, termina en «…».

```bash
dart format lib && flutter analyze
```

## Paso 6 · La carta como dato

**Crea** `lib/domain/tennis_card.dart`. Va en 4 partes.

📄 **`app_flutter/lib/domain/tennis_card.dart`** · parte 1 de 4 (líneas 1–21) · empieza el archivo

```dart
// --- Atributos que se comparan en una partida ---

enum Challenge { ranking, titles, winRate }

/// Textos de cada atributo. Una *extension* agrega getters al enum.
extension ChallengeLabel on Challenge {
  String get label => switch (this) {
    Challenge.ranking => 'Ranking',
    Challenge.titles => 'Títulos',
    Challenge.winRate => '% de victorias',
  };

  String get rule => switch (this) {
    Challenge.ranking => 'Gana el número menor',
    Challenge.titles => 'Gana el número mayor',
    Challenge.winRate => 'Gana el porcentaje mayor',
  };

  /// En Ranking gana el número menor (el #1 es el mejor).
  bool get lowerWins => this == Challenge.ranking;
}
```

- `Challenge` son los 3 atributos que se comparan en una partida, uno por ronda.
- Una *extension* le agrega getters al `enum` sin modificarlo: `Challenge.titles.label` devuelve `'Títulos'`.

📄 **`app_flutter/lib/domain/tennis_card.dart`** · parte 2 de 4 (líneas 23–41) · sigue debajo de la parte anterior

```dart
// --- La carta ---

/// Un tenista con sus tres estadísticas. Es inmutable: todo es `final`.
class TennisCard {
  final String id;
  final String name;
  final String country; // código de 3 letras: ITA, ESP…
  final int ranking;
  final int titles;
  final double winRate; // porcentaje de 0 a 100

  const TennisCard({
    required this.id,
    required this.name,
    required this.country,
    required this.ranking,
    required this.titles,
    required this.winRate,
  });
```

- Todo es `final` y el constructor es `const`: una carta no cambia nunca.
- `required` obliga a entregar cada dato al crear la carta.

📄 **`app_flutter/lib/domain/tennis_card.dart`** · parte 3 de 4 (líneas 43–80) · sigue debajo de la parte anterior

```dart
  // --- Leer y escribir JSON ---

  /// Crea la carta desde el JSON del servidor (o del archivo guardado)
  /// y la rechaza si los datos no tienen sentido.
  factory TennisCard.fromJson(Map<String, dynamic> json) {
    final card = TennisCard(
      id: json['id'].toString(),
      name: json['name'] as String,
      country: json['country'] as String,
      // `num` acepta 5 y 5.0; después se convierte al tipo correcto.
      ranking: (json['ranking'] as num).toInt(),
      titles: (json['titles'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
    );
    if (!card._isValid) {
      throw const FormatException('Carta con datos inválidos');
    }
    return card;
  }

  /// Nada vacío, ranking desde 1, títulos desde 0 y porcentaje entre 0 y 100.
  bool get _isValid =>
      id.isNotEmpty &&
      name.trim().isNotEmpty &&
      ranking >= 1 &&
      titles >= 0 &&
      winRate.isFinite &&
      winRate >= 0 &&
      winRate <= 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'ranking': ranking,
    'titles': titles,
    'winRate': winRate,
  };
```

- `factory TennisCard.fromJson(...)` es un constructor que puede **rechazar** datos: si `_isValid` es falso, lanza `FormatException`. Así, datos rotos de la API nunca llegan a la pantalla.
- `(json['ranking'] as num).toInt()`: el JSON puede traer `5` o `5.0`, y `num` acepta los dos.
- `_isValid` empieza con `_`: es **privado**, solo se usa dentro de este archivo.
- `toJson()` es lo contrario de `fromJson`: así se guarda la carta en el teléfono.

📄 **`app_flutter/lib/domain/tennis_card.dart`** · parte 4 de 4 (líneas 82–102) · sigue debajo de la parte anterior

```dart
  // --- Nombre y valores ---

  /// "Alex de Minaur" → nombre "Alex" (se corta en el primer espacio).
  String get firstName {
    final space = name.indexOf(' ');
    return space == -1 ? '' : name.substring(0, space);
  }

  /// "Alex de Minaur" → apellido "de Minaur".
  String get lastName {
    final space = name.indexOf(' ');
    return space == -1 ? name : name.substring(space + 1);
  }

  /// El valor de un atributo como número, para poder compararlos.
  double value(Challenge challenge) => switch (challenge) {
    Challenge.ranking => ranking.toDouble(),
    Challenge.titles => titles.toDouble(),
    Challenge.winRate => winRate,
  };
}
```

- La carta muestra el apellido grande y el nombre arriba. Se corta en el **primer** espacio.
- `value()` convierte cualquier atributo a número, para compararlos con una sola función.

```bash
dart format lib && flutter analyze
```

## Paso 7 · Pantalla de prueba del tema

**Reemplaza todo** `lib/main.dart` (versión ②):

📄 **`app_flutter/lib/main.dart`** · 40 líneas · **versión provisional**

```dart
import 'package:flutter/material.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/court_button.dart';

// PROVISIONAL (miércoles en la mañana): solo para ver el tema, las fuentes
// y los botones. En la tarde se reemplaza.
void main() => runApp(
  MaterialApp(
    title: kBrand,
    theme: buildTheme(),
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kBrand, style: display(40)),
            Text('Tema, fuentes y botones', style: body(15, color: Court.muted)),
            const SizedBox(height: 24),
            CourtButton('Primario', onPressed: () {}),
            const SizedBox(height: 8),
            CourtButton(
              'Acento',
              variant: ButtonVariant.accent,
              icon: Icons.sports_baseball_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            CourtButton(
              'Secundario',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            const CourtButton('Deshabilitado'),
          ],
        ),
      ),
    ),
  ),
);
```

### ✅ Entrega la base visual (13:00)

```bash
dart format lib && flutter analyze
flutter run -d linux       # «SpinTCG» en letra Archivo y los cuatro botones del mockup
git add -A && git commit -m "Base visual: tema, botón y modelo TennisCard"
git push -u origin sebastian/dia1-base
gh pr create --fill && gh pr merge --squash --delete-branch
```

📣 **Avisa en el chat: «Base en main».** Emma (la carta) y Miguel (los widgets comunes) siguen con eso.

---

## Paso 8 · Los 24 tenistas del mockup

```bash
git switch main && git pull && git switch -c sebastian/dia1-nucleo
```

**Crea** `lib/data/demo_catalog.dart`:

📄 **`app_flutter/lib/data/demo_catalog.dart`** · 44 líneas

```dart
import '../domain/tennis_card.dart';

// Mismos 24 tenistas del mockup Court Cards.
// Nombres reales; TODOS los valores deportivos son ficticios.
List<TennisCard> demoCatalog() {
  const rows = [
    // (nombre, país, ranking, títulos, % victorias)
    ('Jannik Sinner', 'ITA', 1, 19, 82.0),
    ('Carlos Alcaraz', 'ESP', 2, 21, 81.0),
    ('Alexander Zverev', 'GER', 3, 23, 70.0),
    ('Novak Djokovic', 'SRB', 4, 30, 84.0),
    ('Taylor Fritz', 'USA', 5, 9, 66.0),
    ('Jack Draper', 'GBR', 6, 4, 64.0),
    ('Alex de Miñaur', 'AUS', 7, 9, 65.0),
    ('Lorenzo Musetti', 'ITA', 8, 3, 61.0),
    ('Holger Rune', 'DEN', 9, 4, 62.0),
    ('Casper Ruud', 'NOR', 10, 12, 64.0),
    ('Ben Shelton', 'USA', 11, 3, 60.0),
    ('Tommy Paul', 'USA', 12, 4, 61.0),
    ('Stefanos Tsitsipas', 'GRE', 13, 12, 68.0),
    ('Frances Tiafoe', 'USA', 14, 3, 57.0),
    ('Félix Auger-Aliassime', 'CAN', 15, 7, 60.0),
    ('Grigor Dimitrov', 'BUL', 16, 9, 63.0),
    ('Hubert Hurkacz', 'POL', 17, 8, 61.0),
    ('Ugo Humbert', 'FRA', 18, 7, 58.0),
    ('Arthur Fils', 'FRA', 19, 3, 59.0),
    ('Francisco Cerúndolo', 'ARG', 20, 4, 57.0),
    ('Alejandro Davidovich Fokina', 'ESP', 21, 2, 55.0),
    ('Jakub Menšík', 'CZE', 22, 2, 58.0),
    ('João Fonseca', 'BRA', 23, 1, 60.0),
    ('Sebastian Korda', 'USA', 24, 3, 56.0),
  ];
  return [
    for (var i = 0; i < rows.length; i++)
      TennisCard(
        id: 'demo-${i + 1}',
        name: rows[i].$1,
        country: rows[i].$2,
        ranking: rows[i].$3,
        titles: rows[i].$4,
        winRate: rows[i].$5,
      ),
  ];
}
```

- Cada fila es un *record*: varios valores juntos entre paréntesis. `rows[i].$1` es el primer valor (el nombre), `$2` el segundo, etc.
- **Los valores son ficticios** y la app lo dirá en pantalla (modo demo).
- Mismo orden que el mockup: así el N.º de cada carta coincide con el diseño.

```bash
dart format lib && flutter analyze
git add -A && git commit -m "Catálogo demo con los 24 tenistas del mockup"
git push -u origin sebastian/dia1-nucleo
```

📣 Emma usa `demoCatalog()` en su pantalla de muestra: avísale que ya está en tu rama.

## Paso 9 · Reglas de la partida

**Crea** `lib/domain/game.dart`. Va en 3 partes.

📄 **`app_flutter/lib/domain/game.dart`** · parte 1 de 3 (líneas 1–22) · empieza el archivo

```dart
import 'dart:math';
import 'tennis_card.dart';

// --- Resultado de una ronda ---

/// Lo que pasó en una ronda: las dos cartas, el atributo y quién ganó.
class RoundResult {
  final TennisCard player;
  final TennisCard opponent;
  final Challenge challenge;
  // 1 = gana el usuario, -1 = gana la computadora, 0 = empate.
  final int outcome;

  RoundResult(this.player, this.opponent, this.challenge, this.outcome);
}

/// Compara dos cartas en un atributo y devuelve 1, -1 o 0.
/// En Ranking gana el número MENOR, por eso se invierte el signo.
int compareCards(TennisCard a, TennisCard b, Challenge challenge) {
  final comparison = a.value(challenge).compareTo(b.value(challenge));
  return challenge.lowerWins ? -comparison : comparison;
}
```

- `outcome` es **1** si ganas, **-1** si gana la computadora y **0** si empatan.
- `compareTo` devuelve un número negativo, cero o positivo. En **Ranking** se invierte el signo, porque gana el número menor (el #1 es el mejor).

📄 **`app_flutter/lib/domain/game.dart`** · parte 2 de 3 (líneas 24–53) · sigue debajo de la parte anterior

```dart
// --- La partida ---

/// Partida de 3 rondas. La ronda 1 compara Ranking, la 2 Títulos y la 3
/// % de victorias. Cada carta se usa una sola vez.
class MatchSession {
  final List<TennisCard> remaining; // tus cartas que aún no juegas
  final List<TennisCard> opponents; // cartas del rival que aún no salen
  final Random random;
  final List<RoundResult> results = [];

  MatchSession(List<TennisCard> team, List<TennisCard> rival, {Random? random})
    : remaining = List.of(team),
      opponents = List.of(rival),
      random = random ?? Random() {
    if (!_threeDifferent(team) || !_threeDifferent(rival)) {
      throw ArgumentError('Cada equipo necesita tres tenistas diferentes');
    }
  }

  /// ¿Son exactamente 3 cartas, sin repetir ninguna?
  static bool _threeDifferent(List<TennisCard> cards) =>
      cards.length == 3 && cards.map((c) => c.id).toSet().length == 3;

  bool get finished => results.length == 3;

  /// Atributo de la ronda actual (0 → Ranking, 1 → Títulos, 2 → %).
  Challenge get challenge => Challenge.values[results.length];

  int get playerScore => results.where((r) => r.outcome == 1).length;
  int get opponentScore => results.where((r) => r.outcome == -1).length;
```

- El constructor copia las listas (`List.of`) para no modificar las del equipo.
- Lo que va después de `:` (la *lista de inicialización*) se ejecuta antes del cuerpo `{ }`.
- Si algún equipo no tiene 3 cartas distintas, lanza un error: así una partida inválida nunca empieza.
- `challenge` usa `results.length`: con 0 rondas jugadas toca Ranking, con 1 Títulos y con 2 % de victorias.

📄 **`app_flutter/lib/domain/game.dart`** · parte 3 de 3 (líneas 55–72) · sigue debajo de la parte anterior

```dart
  // --- Jugar una ronda ---

  /// Juega tu carta `id` contra una carta al azar del rival.
  RoundResult play(String id) {
    if (finished) throw StateError('La partida terminó');
    final index = remaining.indexWhere((c) => c.id == id);
    if (index == -1) throw ArgumentError('Carta no disponible');

    final roundChallenge = challenge; // se lee ANTES de guardar el resultado
    final card = remaining.removeAt(index);
    final opponent = opponents.removeAt(random.nextInt(opponents.length));
    final outcome = compareCards(card, opponent, roundChallenge);

    final result = RoundResult(card, opponent, roundChallenge, outcome);
    results.add(result);
    return result;
  }
}
```

- `play()` saca tu carta de `remaining`, saca una al azar del rival y las compara.
- El atributo se lee **antes** de guardar el resultado: después de `results.add`, `challenge` ya apunta a la ronda siguiente.
- `Random` viene desde afuera: en las pruebas se usa `Random(1)` y la partida siempre sale igual.

```bash
dart format lib && flutter analyze
```

## Paso 10 · Guardar el progreso

**Crea** `lib/data/local_store.dart`. Va en 3 partes.

📄 **`app_flutter/lib/data/local_store.dart`** · parte 1 de 3 (líneas 1–13) · empieza el archivo

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// --- La interfaz ---

/// Dónde se guarda el progreso. Hay dos implementaciones:
/// - `FileLocalStore`: un archivo JSON en el teléfono (la app real).
/// - `MemoryLocalStore`: solo en memoria (las pruebas).
abstract class LocalStore {
  Future<Map<String, dynamic>?> read(); // null = nunca se ha guardado nada
  Future<void> write(Map<String, dynamic> data);
}
```

- `LocalStore` es una **interfaz**: dice qué se puede hacer (`read` y `write`), pero no cómo.
- `Future<…>` significa que la respuesta llega después (leer el disco toma tiempo). Por eso se usa `await`.

📄 **`app_flutter/lib/data/local_store.dart`** · parte 2 de 3 (líneas 15–45) · sigue debajo de la parte anterior

```dart
// --- En un archivo ---

class FileLocalStore implements LocalStore {
  final String namespace; // 'demo' o 'rapidapi': un archivo para cada modo

  FileLocalStore(this.namespace);

  /// `spintcg_demo.json` dentro de la carpeta privada de la app.
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return File('${dir.path}/spintcg_$namespace.json');
  }

  @override
  Future<Map<String, dynamic>?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    return Map<String, dynamic>.from(jsonDecode(await file.readAsString()));
  }

  /// Escribe primero en `.tmp` y después renombra. Si la app se cierra a
  /// mitad de la escritura, el archivo anterior queda intacto.
  @override
  Future<void> write(Map<String, dynamic> data) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data), flush: true);
    await tmp.rename(file.path);
  }
}
```

- `implements LocalStore` promete tener `read` y `write`. `@override` marca que son los de la interfaz.
- **Escritura segura:** primero `….json.tmp` y después se renombra. Si la app se cierra a mitad de la escritura, el archivo anterior queda intacto.

📄 **`app_flutter/lib/data/local_store.dart`** · parte 3 de 3 (líneas 47–62) · sigue debajo de la parte anterior

```dart
// --- En memoria (pruebas) ---

class MemoryLocalStore implements LocalStore {
  Map<String, dynamic>? data;

  // Copia pasando por JSON, igual que el disco: así nadie puede cambiar
  // lo guardado por referencia.
  @override
  Future<Map<String, dynamic>?> read() async =>
      data == null ? null : jsonDecode(jsonEncode(data));

  @override
  Future<void> write(Map<String, dynamic> value) async {
    data = jsonDecode(jsonEncode(value));
  }
}
```

- La versión en memoria sirve para las pruebas: no toca el disco y se borra al terminar.

```bash
dart format lib && flutter analyze
```

## Paso 11 · Traer el catálogo

**Crea** `lib/data/catalog_repository.dart`:

📄 **`app_flutter/lib/data/catalog_repository.dart`** · 62 líneas

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/tennis_card.dart';
import 'demo_catalog.dart';

/// Trae el catálogo de tenistas: demo (sin red) o desde NUESTRO servidor.
/// La app nunca habla directo con RapidAPI: la clave vive en el servidor.
class CatalogRepository {
  final String baseUrl; // vacío = modo demo
  final http.Client client;

  // El `client` se puede cambiar en las pruebas por un servidor falso.
  CatalogRepository(this.baseUrl, {http.Client? client})
    : client = client ?? http.Client();

  bool get isDemo => baseUrl.isEmpty;

  Future<List<TennisCard>> load() async {
    if (isDemo) return demoCatalog();

    // 1. La URL tiene que ser http o https y tener servidor.
    final root = Uri.parse(baseUrl);
    final validUrl =
        root.hasScheme &&
        ['http', 'https'].contains(root.scheme) &&
        root.host.isNotEmpty;
    if (!validUrl) {
      throw const FormatException('API_BASE_URL debe ser una URL http o https');
    }

    // 2. GET /catalog, con un máximo de 60 segundos de espera.
    final response = await client
        .get(root.resolve('/catalog'))
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      throw StateError('Servicio de tenis: HTTP ${response.statusCode}');
    }

    // 3. Leer el JSON como UTF-8: los nombres traen tildes (Miñaur).
    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (payload['source'] != 'rapidapi') {
      throw const FormatException(
        'El servicio no identifica datos de RapidAPI',
      );
    }

    // 4. Convertir cada carta (fromJson valida) y revisar el conjunto.
    final cards = (payload['cards'] as List)
        .map((c) => TennisCard.fromJson(Map<String, dynamic>.from(c)))
        .toList();
    final uniqueIds = cards.map((c) => c.id).toSet().length;
    if (cards.length < 6 || uniqueIds != cards.length) {
      throw const FormatException(
        'Se requieren al menos seis cartas válidas y únicas',
      );
    }
    return cards;
  }

  void dispose() => client.close();
}
```

- **Sin `API_BASE_URL`, la app es demo** y no hace ninguna llamada de red.
- Con URL, pide `GET /catalog` a **nuestro** servidor, nunca a RapidAPI: la clave vive en el servidor.
- Los pasos 1 a 4 del código validan todo. Cualquier problema se muestra como **error**: nunca se reemplaza en silencio por datos demo.
- `utf8.decode(response.bodyBytes)` lee bien las tildes (Miñaur, Cerúndolo).

```bash
dart format lib && flutter analyze
```

## Paso 12 · El controlador

**Crea** `lib/application/app_controller.dart`. Es el archivo más importante del proyecto y el que más te van a preguntar. Va en 9 partes.

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 1 de 9 (líneas 1–31) · empieza el archivo

```dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/catalog_repository.dart';
import '../data/local_store.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';

/// Fecha como texto ordenable: 2026-10-21. Sirve para el sobre diario.
String dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Todo el estado de la app. Las pantallas lo escuchan y se redibujan
/// cada vez que llama a `notifyListeners()`.
class AppController extends ChangeNotifier {
  // --- Dependencias ---

  final CatalogRepository repository; // de dónde salen las cartas
  final LocalStore store; // dónde se guarda el progreso
  final Random random; // azar (fijo en las pruebas)
  final DateTime Function() now; // reloj (fijo en las pruebas)

  AppController(
    this.repository,
    this.store, {
    Random? random,
    DateTime Function()? now,
  }) : random = random ?? Random(),
       now = now ?? DateTime.now;
```

- `dayKey` convierte la fecha en texto ordenable (`2026-10-21`). Al comparar dos textos así, el más nuevo siempre es «mayor».
- `ChangeNotifier`: cuando el controlador llama a `notifyListeners()`, las pantallas que lo escuchan se redibujan.
- El azar (`random`) y el reloj (`now`) se reciben desde afuera: en las pruebas se fijan para que todo salga igual siempre.

📄 **`app_flutter/lib/application/app_controller.dart`** · partes 2 a 3 de 9 (líneas 33–48) · sigue debajo de la parte anterior

```dart
  // --- Estado guardado ---

  List<TennisCard> catalog = [];
  Map<String, int> copies = {}; // id de carta → copias obtenidas
  List<String> team = []; // ids del equipo (máximo 3)
  String nickname = 'Tenista';
  String? lastPackDay; // último día en que se abrió el sobre
  int played = 0;
  int wins = 0;

  // --- Estado de la pantalla (no se guarda) ---

  bool loading = true; // cargando al abrir la app
  bool busy = false; // guardando un cambio
  String? error; // error de carga
  final Set<MatchSession> _recordedMatches = {}; // partidas ya sumadas
```

- **Estado guardado:** lo que se escribe en el disco (cartas, copias, equipo, apodo, sobre y partidas).
- **Estado de la pantalla:** solo existe mientras la app está abierta (`loading`, `busy`, `error`).

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 4 de 9 (líneas 50–69) · sigue debajo de la parte anterior

```dart
  // --- Datos calculados ---

  bool get isDemo => repository.isDemo;

  int get uniqueCount => copies.values.where((n) => n > 0).length;

  /// El sobre se puede abrir si nunca se abrió o si hoy es otro día.
  bool get canOpenPack =>
      lastPackDay == null || dayKey(now()).compareTo(lastPackDay!) > 0;

  List<TennisCard> get owned =>
      catalog.where((c) => (copies[c.id] ?? 0) > 0).toList();

  /// Las cartas del equipo, en orden.
  List<TennisCard> get selected =>
      team.map((id) => catalog.firstWhere((c) => c.id == id)).toList();

  /// Número de la carta en el álbum (N.º 01 de 24), según su orden.
  int numberOf(TennisCard card) =>
      catalog.indexWhere((c) => c.id == card.id) + 1;
```

- Datos que **se calculan** a partir del estado, sin guardarse aparte. Así nunca quedan desactualizados.
- `copies[c.id] ?? 0`: si la carta no está en el mapa, cuenta como 0 copias.

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 5 de 9 (líneas 71–117) · sigue debajo de la parte anterior

```dart
  // --- Guardar y restaurar ---

  /// Foto de todo el estado guardado, lista para escribir como JSON.
  Map<String, dynamic> _snapshot() => {
    'version': 1,
    'catalog': catalog.map((c) => c.toJson()).toList(),
    'copies': Map<String, int>.of(copies),
    'team': List<String>.of(team),
    'nickname': nickname,
    'lastPackDay': lastPackDay,
    'played': played,
    'wins': wins,
  };

  /// Vuelve a un estado guardado y lo rechaza si fue manipulado.
  void _restore(Map<String, dynamic> data) {
    if (data['version'] != 1) {
      throw const FormatException('Versión local no compatible');
    }
    catalog = (data['catalog'] as List)
        .map((c) => TennisCard.fromJson(Map<String, dynamic>.from(c)))
        .toList();
    copies = Map<String, int>.from(data['copies']);
    team = List<String>.from(data['team']);
    nickname = data['nickname'] as String;
    lastPackDay = data['lastPackDay'] as String?;
    played = data['played'] as int;
    wins = data['wins'] as int;
    if (!_isConsistent()) {
      throw const FormatException('El progreso guardado no es válido');
    }
  }

  /// Reglas que un progreso guardado siempre cumple.
  bool _isConsistent() {
    final ids = catalog.map((c) => c.id).toSet();
    final catalogOk = catalog.length >= 6 && ids.length == catalog.length;
    final copiesOk = copies.entries.every(
      (e) => ids.contains(e.key) && e.value >= 0,
    );
    final teamOk =
        team.length <= 3 &&
        team.toSet().length == team.length &&
        team.every((id) => (copies[id] ?? 0) >= 1);
    final scoreOk = played >= 0 && wins >= 0 && wins <= played;
    return catalogOk && copiesOk && teamOk && scoreOk;
  }
```

- `_snapshot()` saca una «foto» del estado como `Map`, lista para guardar en JSON.
- `_restore()` hace lo contrario y después revisa `_isConsistent()`: un archivo manipulado (equipo con cartas no obtenidas, más victorias que partidas) se rechaza.

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 6 de 9 (líneas 119–147) · sigue debajo de la parte anterior

```dart
  // --- Cargar ---

  /// Restaura el progreso guardado o, la primera vez, carga el catálogo
  /// y regala 6 cartas al azar.
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final saved = await store.read();
      if (saved != null) {
        _restore(saved);
      } else {
        catalog = await repository.load();
        final shuffled = List<TennisCard>.of(catalog)..shuffle(random);
        copies = {for (final c in shuffled.take(6)) c.id: 1};
        team = [];
        nickname = 'Tenista';
        lastPackDay = null;
        played = 0;
        wins = 0;
        await store.write(_snapshot());
      }
    } catch (e) {
      error = 'No se pudo cargar el proyecto: $e';
    }
    loading = false;
    notifyListeners();
  }
```

- Si hay progreso guardado, lo restaura. Si no (primera vez), carga el catálogo, regala **6 cartas al azar** y guarda.
- `try/catch`: si algo falla, se guarda el mensaje en `error` y la pantalla lo muestra con «Reintentar».

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 7 de 9 (líneas 149–171) · sigue debajo de la parte anterior

```dart
  // --- Cambios transaccionales ---

  /// Aplica un cambio y lo guarda. Si algo falla, vuelve al estado anterior:
  /// la memoria y el disco nunca quedan distintos.
  Future<T> _change<T>(T Function() action) async {
    if (busy || loading || error != null) {
      throw StateError('Espera a que termine la operación');
    }
    busy = true;
    notifyListeners();
    final before = _snapshot();
    try {
      final value = action();
      await store.write(_snapshot());
      return value;
    } catch (_) {
      _restore(before);
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
```

- **`_change()` es la pieza clave.** Toma una foto del estado, aplica el cambio y lo guarda en el disco. Si algo falla, vuelve a la foto (`_restore(before)`) y relanza el error. La memoria y el disco **nunca** quedan distintos.
- `busy` impide dos cambios a la vez (por ejemplo, tocar «Abrir sobre» dos veces seguidas).
- `<T>` es un tipo genérico: `_change` devuelve lo mismo que devuelva la acción (`openPack` devuelve las 3 cartas).

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 8 de 9 (líneas 173–217) · sigue debajo de la parte anterior

```dart
  // --- Acciones ---

  /// Añade o quita una carta del equipo (desde el Detalle).
  Future<void> toggleTeam(String id) => _change(() {
    if ((copies[id] ?? 0) < 1) throw ArgumentError('Carta no obtenida');
    if (team.contains(id)) {
      team.remove(id);
    } else {
      if (team.length == 3) throw StateError('El equipo ya tiene tres cartas');
      team.add(id);
    }
  });

  /// Guarda de una vez el equipo armado en la pantalla Elegir equipo.
  Future<void> saveTeam(List<String> ids) => _change(() {
    if (ids.length > 3 || ids.toSet().length != ids.length) {
      throw ArgumentError('Elige hasta tres tenistas diferentes');
    }
    if (ids.any((id) => (copies[id] ?? 0) < 1)) {
      throw ArgumentError('Carta no obtenida');
    }
    team = List.of(ids);
  });

  /// Sobre diario: 3 cartas al azar (pueden repetirse). Una vez por día.
  Future<List<TennisCard>> openPack() => _change(() {
    if (!canOpenPack) throw StateError('El sobre estará disponible mañana');
    final cards = List.generate(
      3,
      (_) => catalog[random.nextInt(catalog.length)],
    );
    for (final card in cards) {
      copies[card.id] = (copies[card.id] ?? 0) + 1;
    }
    lastPackDay = dayKey(now());
    return cards;
  });

  Future<void> saveNickname(String value) => _change(() {
    final clean = value.trim();
    if (clean.isEmpty || clean.length > 16) {
      throw ArgumentError('Usa un apodo de 1 a 16 caracteres');
    }
    nickname = clean;
  });
```

- Cada acción va dentro de `_change(() { … })`: valida, cambia el estado y se guarda sola.
- `ArgumentError` = el dato está mal (carta no obtenida, apodo vacío). `StateError` = no se puede ahora (sobre ya abierto, equipo lleno).
- El sobre puede traer cartas repetidas: cada una suma una copia.

📄 **`app_flutter/lib/application/app_controller.dart`** · parte 9 de 9 (líneas 219–246) · sigue debajo de la parte anterior

```dart
  // --- Partidas ---

  /// Nueva partida: tu equipo contra 3 cartas al azar que NO están en él.
  MatchSession startMatch() {
    if (team.length != 3) throw StateError('Elige tres tenistas diferentes');
    final rival = catalog.where((c) => !team.contains(c.id)).toList()
      ..shuffle(random);
    return MatchSession(selected, rival.take(3).toList(), random: random);
  }

  /// Suma la partida terminada. La misma partida se cuenta una sola vez,
  /// aunque se reintente el guardado.
  Future<void> recordMatch(MatchSession match) async {
    if (_recordedMatches.contains(match)) return;
    await _change(() {
      if (!match.finished) throw StateError('La partida no ha terminado');
      played++;
      if (match.playerScore > match.opponentScore) wins++;
    });
    _recordedMatches.add(match);
  }

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}
```

- El rival se elige entre las cartas que **no** están en tu equipo.
- `recordMatch` suma la partida una sola vez, aunque se reintente el guardado.
- `dispose()` cierra la conexión HTTP cuando la app se cierra.

```bash
dart format lib && flutter analyze
```

## Paso 13 · Pantalla de prueba del núcleo

**Reemplaza todo** `lib/main.dart` (versión ③). Esta usa el controlador real y guarda en el disco:

📄 **`app_flutter/lib/main.dart`** · 36 líneas · **versión provisional**

```dart
import 'package:flutter/material.dart';
import 'application/app_controller.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'presentation/theme.dart';

// PROVISIONAL (miércoles en la tarde): carga el catálogo con el controlador
// real y lo guarda en el disco. El jueves se reemplaza por la app completa.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppController(CatalogRepository(''), FileLocalStore('demo'));
  await app.load();
  runApp(
    MaterialApp(
      title: kBrand,
      theme: buildTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${app.uniqueCount} de ${app.catalog.length} cartas'),
        ),
        body: ListView(
          children: [
            if (app.error != null) Text(app.error!),
            for (final card in app.owned)
              ListTile(
                title: Text(card.name, style: body(16, weight: FontWeight.w600)),
                subtitle: Text(
                  '#${card.ranking} · ${card.titles} títulos · ${card.winRate}%',
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

```bash
dart format lib && flutter analyze
flutter run -d linux
```

Deberías ver «6 de 24 cartas» y la lista de tus 6 tenistas. **Cierra la app y vuelve a abrirla: tienen que ser los mismos 6**, porque el progreso quedó guardado.

### ✅ Entrega el núcleo

```bash
git add -A && git commit -m "Núcleo: reglas, almacenamiento, repositorio y controlador"
git push && gh pr create --fill
```

## Cierre del día

- [ ] En `main`: proyecto, base visual y núcleo; `flutter analyze` sin problemas.
- [ ] Integrados los PR del día 1 de Emma (carta) y de Miguel (widgets comunes).
- [ ] Sabes explicar `_change()`, `fromJson` y por qué la app demo no llama a la red.
- [ ] Check-in de las 21:00. Las consultas reales a RapidAPI quedan para mañana ([día 2](dia2.md)).
