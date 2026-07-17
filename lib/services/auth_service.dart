import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth.
///
/// Keeps every credential concern in one file: the rest of the app only ever
/// sees [authStateChanges] and the three actions below. Error codes are
/// translated here so screens can show human-readable messages.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Maps Firebase error codes to messages a student user can act on.
  static String readableError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists for that email. Try logging in.';
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'weak-password':
          return 'Password is too weak — use at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'too-many-requests':
          return 'Too many attempts. Wait a moment and try again.';
        case 'network-request-failed':
          return 'No internet connection. Check your network and retry.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
