import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'Cashier';

    final doc = await _firestore.users.doc(user.uid).get();
    final email = user.email?.toLowerCase() ?? '';
    if (!doc.exists) {
      final role = email.contains('admin') ? 'Admin' : 'Cashier';
      await _firestore.users.doc(user.uid).set({
        'email': user.email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return role;
    }

    final data = doc.data();
    final role = data?['role'] as String?;
    return role == 'Admin' ? 'Admin' : 'Cashier';
  }

  Future<String> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'Unable to login user');
    }

    final doc = await _firestore.users.doc(user.uid).get();
    final userEmailLower = user.email?.toLowerCase() ?? '';
    if (!doc.exists) {
      final role = userEmailLower.contains('admin') ? 'Admin' : 'Cashier';
      await _firestore.users.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return role;
    }

    final role = doc.data()?['role'] as String?;
    return role == 'Admin' ? 'Admin' : 'Cashier';
  }
}
