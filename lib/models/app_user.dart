import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String userType; // buyer, seller, caregiver
  final String? photoUrl;
  final Map<String, bool> accessibilityPreferences;
  final List<Map<String, String>> addresses;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.photoUrl,
    this.accessibilityPreferences = const {},
    this.addresses = const [],
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? 'buyer',
      photoUrl: data['photoUrl'],
      accessibilityPreferences:
          Map<String, bool>.from(data['accessibilityPreferences'] ?? {}),
      addresses: List<Map<String, String>>.from(
        (data['addresses'] ?? []).map((a) => Map<String, String>.from(a)),
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'photoUrl': photoUrl,
      'accessibilityPreferences': accessibilityPreferences,
      'addresses': addresses,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}