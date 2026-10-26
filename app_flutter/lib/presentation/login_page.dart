import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/app_controller.dart';
import '../application/session_controller.dart';
import 'app_shell.dart';
import 'errores.dart';
import 'theme.dart';
import 'validadores.dart';
import 'widgets/court_button.dart';

/// Con sesión muestra la app; sin sesión, el ingreso. Cada cuenta tiene su
/// propio progreso: si entra otra cuenta, se crea otro AppController, que
/// lee el archivo de esa cuenta.
class AuthGate extends StatefulWidget {
  final AppController Function(String userId) controllerFor;
  const AuthGate({super.key, required this.controllerFor});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppController? app; // el progreso de la cuenta conectada
  String? userId;

  /// El controlador de esta cuenta. Si cambió la cuenta, crea uno nuevo y
  /// carga su progreso; el anterior se libera cuando ya no se dibuja.
  AppController controllerFor(String id) {
    if (id != userId) {
      final old = app;
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
      userId = id;
      app = widget.controllerFor(id)..load();
    }
    return app!;
  }

  @override
  void dispose() {
    app?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    if (user == null) {
      return MaterialApp(
        title: kBrand,
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      );
    }
    final app = controllerFor(user.id);
    // La key hace que la app se arme de nuevo (pestaña Inicio) al cambiar
    // de cuenta. Provider comparte el AppController de ESTA cuenta.
    return ChangeNotifierProvider.value(
      value: app,
      child: CourtApp(key: ValueKey(user.id), app: app),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool registering = false;
  bool hidden = true;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    final session = context.read<SessionController>();
    setState(() => error = null);
    try {
      if (!registering) {
        await session.signIn(email.text, password.text);
        return;
      }
      final mustConfirm = await session.signUp(email.text, password.text);
      if (mustConfirm && mounted) {
        setState(() => registering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te enviamos un correo: confírmalo y luego entra'),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = mensajeDeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<SessionController>().busy;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo(size: 64)),
                    const SizedBox(height: 20),
                    Text(
                      registering ? 'Crear cuenta' : 'Entrar a $kBrand',
                      textAlign: TextAlign.center,
                      style: display(28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus equipos guardados quedan en tu cuenta.',
                      textAlign: TextAlign.center,
                      style: body(14, color: Court.muted),
                    ),
                    const SizedBox(height: 28),
                    ..._fields(),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: body(13, color: Court.loss),
                      ),
                    ],
                    const SizedBox(height: 20),
                    CourtButton(
                      registering ? 'Crear cuenta' : 'Entrar',
                      icon: registering ? Icons.person_add_alt : Icons.login,
                      size: ButtonSize.lg,
                      full: true,
                      onPressed: busy ? null : submit,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                              registering = !registering;
                              error = null;
                            }),
                      child: Text(
                        registering
                            ? '¿Ya tienes cuenta? Entra'
                            : '¿No tienes cuenta? Crea una',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _fields() => [
    TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      decoration: _decoration('Correo', Icons.mail_outline),
      validator: validarCorreo,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: password,
      obscureText: hidden,
      autofillHints: const [AutofillHints.password],
      textInputAction: registering
          ? TextInputAction.next
          : TextInputAction.done,
      onFieldSubmitted: registering ? null : (_) => submit(),
      decoration: _decoration('Contraseña', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          tooltip: hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
          onPressed: () => setState(() => hidden = !hidden),
          icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: validarClave,
    ),
    if (registering) ...[
      const SizedBox(height: 12),
      TextFormField(
        obscureText: hidden,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => submit(),
        decoration: _decoration('Repite la contraseña', Icons.lock_outline),
        // Un validador también puede comparar con otro campo.
        validator: (value) =>
            value == password.text ? null : 'Las contraseñas no coinciden',
      ),
    ],
  ];

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  );
}
