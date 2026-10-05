import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Stream current user profile
  Stream<AppUser?> getCurrentUserStream() {
    if (_userId == null) return Stream.value(null);
    return _db.collection('users').doc(_userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  // Get current user once
  Future<AppUser?> getCurrentUser() async {
    if (_userId == null) return null;
    final doc = await _db.collection('users').doc(_userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (_userId == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    await _db.collection('users').doc(_userId).update(updates);
  }

  // Update accessibility preferences
  Future<void> updateAccessibilityPreferences(
    Map<String, bool> preferences,
  ) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).update({
      'accessibilityPreferences': preferences,
    });
  }
}
