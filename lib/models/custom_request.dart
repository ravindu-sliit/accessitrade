import 'package:cloud_firestore/cloud_firestore.dart';

class CustomRequest {
  final String id;
  final String userId;
  final String posterName;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String? imageUrl;
  final String? budget;
  final int responseCount;
  final DateTime createdAt;

  CustomRequest({
    required this.id,
    required this.userId,
    required this.posterName,
    required this.title,
    required this.description,
    this.category = 'General',
    required this.tags,
    this.imageUrl,
    this.budget,
    this.responseCount = 0,
    required this.createdAt,
  });

  factory CustomRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final parsedTags = List<String>.from(data['tags'] ?? []);
    final defaultCat = parsedTags.isNotEmpty ? parsedTags.first : 'General';
    return CustomRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      posterName: data['posterName'] ?? 'Anonymous',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? defaultCat,
      tags: parsedTags,
      imageUrl: data['imageUrl'],
      budget: data['budget'],
      responseCount: data['responseCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'posterName': posterName,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'imageUrl': imageUrl,
      'budget': budget,
      'responseCount': responseCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class Review {
  final String id;
  final String productId;
  final String userId;
  final String reviewerName;
  final double rating;
  final String comment;
  final bool isVerifiedBuyer;
  final int helpfulCount;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.isVerifiedBuyer = false,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      reviewerName: data['reviewerName'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      isVerifiedBuyer: data['isVerifiedBuyer'] ?? false,
      helpfulCount: data['helpfulCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'isVerifiedBuyer': isVerifiedBuyer,
      'helpfulCount': helpfulCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}