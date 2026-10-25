import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionController extends ChangeNotifier {
  final GoTrueClient auth;
  late final StreamSubscription<AuthState> _changes;
  bool busy = false;

  SessionController(this.auth) {
    _changes = auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  User? get user => auth.currentUser;
  String get email => user?.email ?? '';

  Future<bool> signUp(String email, String password) async {
    final response = await _run(
      () => auth.signUp(email: email.trim(), password: password),
    );
    return response.session == null;
  }

  Future<void> signIn(String email, String password) => _run(
    () => auth.signInWithPassword(email: email.trim(), password: password),
  );

  Future<void> signOut() => _run(auth.signOut);

  Future<T> _run<T>(Future<T> Function() action) async {
    if (busy) throw StateError('Espera a que termine la operación');
    busy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }
}
