import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'auth_user.dart';
import 'auth_exceptions.dart';
import 'auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser; // from getter
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailALreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else {
        throw GenericException();
      }
    } catch (e) {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // factory constructor to create an authUser form Firebase User
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else {
        throw GenericException();
      }
    } catch (_) {
      throw GenericException();
    }
  }

  @override
  Future<void> logout() async {
    final user = currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotFoundAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotFoundAuthException();
    }
  }
}