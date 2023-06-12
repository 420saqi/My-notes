// import 'package:firebase_auth/firebase_auth.dart'
//     show FirebaseAuth ,FirebaseAuthException ;
import 'auth_user.dart';

abstract class AuthProvider {

AuthUser? get currentUser;

Future<AuthUser> login({required String email, required String password,});

Future<void> logout() ;

Future<AuthUser> createUser({required String email, required String password,});

Future<void> initializeFirebase();

Future<void> sendEmailVerification();
}