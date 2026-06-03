import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseMethods _db = DatabaseMethods();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address. Please check and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials.';
        case 'email-already-in-use':
          return 'An account already exists with this email. Please sign in instead.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters with letters and numbers.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Contact support.';
        case 'missing-email':
          return 'Please enter your email address.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email using a different sign-in method.';
        case 'invalid-verification-code':
        case 'invalid-verification-id':
          return 'Authentication failed. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'timeout':
          return 'Request timed out. Please try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  // ==================== FIXED: Added isAdmin and phone fields ====================
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await _db.addUser(result.user!.uid, {
          'name': name,
          'email': email,
          'uid': result.user!.uid,
          'phone': '',
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': '',
          'isAdmin': false,  // <-- FIXED: Added isAdmin field
        });
      }
      return result.user;
    } catch (e) {
      throw _getErrorMessage(e);
    }
  }
  // ================================================================================

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _getErrorMessage(e);
    }
  }

  // ==================== FIXED: Added isAdmin and phone fields ====================
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign in was cancelled.';
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await _db.addUser(result.user!.uid, {
          'name': result.user!.displayName ?? '',
          'email': result.user!.email ?? '',
          'uid': result.user!.uid,
          'phone': '',
          'photoUrl': result.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': false,  // <-- FIXED: Added isAdmin field
        });
      }
      return result.user;
    } catch (e) {
      throw _getErrorMessage(e);
    }
  }
  // ================================================================================

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _getErrorMessage(e);
    }
  }
}