import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/custom_request.dart';

class CommunityService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Stream all custom requests
  Stream<List<CustomRequest>> getRequests() {
    return _db
        .collection('requests')
        .snapshots()
        .map((snap) {
          final requests = snap.docs
              .map((doc) => CustomRequest.fromFirestore(doc))
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  // Stream custom requests posted by the current user
  Stream<List<CustomRequest>> getUserRequests() {
    if (_userId == null) return Stream.value([]);
    return _db
        .collection('requests')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snap) {
          final requests = snap.docs
              .map((doc) => CustomRequest.fromFirestore(doc))
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  // Delete a custom request
  Future<void> deleteRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).delete();
  }

  // Post a new custom request
  Future<void> postRequest({
    required String title,
    required String description,
    required String category,
    required List<String> tags,
    String? imageUrl,
    String? budget,
  }) async {
    if (_userId == null) throw Exception('Not signed in');
    final user = _auth.currentUser;
    await _db.collection('requests').add({
      'userId': _userId,
      'posterName': user?.displayName ?? user?.email?.split('@').first ?? 'User',
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'imageUrl': imageUrl,
      'budget': budget,
      'responseCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream reviews for a product
  Stream<List<Review>> getProductReviews(String productId) {
    return _db
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snap) {
          final reviews = snap.docs.map((doc) => Review.fromFirestore(doc)).toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  // Post a review
  Future<void> postReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    if (_userId == null) throw Exception('Not signed in');
    final user = _auth.currentUser;
    await _db.collection('reviews').add({
      'productId': productId,
      'userId': _userId,
      'reviewerName': user?.displayName ?? user?.email?.split('@').first ?? 'User',
      'rating': rating,
      'comment': comment,
      'isVerifiedBuyer': true,
      'helpfulCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark review as helpful
  Future<void> markHelpful(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).update({
      'helpfulCount': FieldValue.increment(1),
    });
  }
}