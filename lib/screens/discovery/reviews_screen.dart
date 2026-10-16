import 'package:flutter/material.dart';
import 'package:accessitrade/models/custom_request.dart';
import 'package:accessitrade/services/community_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double averageRating;
  final int reviewCount;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _communityService = CommunityService();
  double _newRating = 5.0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;
  String _sortBy = 'Most Helpful';

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5C5A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Customer Reviews',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ),
      body: StreamBuilder<List<Review>>(
        stream: _communityService.getProductReviews(widget.productId),
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A5C5A)),
                          ),
                          const Text('out of 5 stars',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          Text('${reviews.isNotEmpty ? reviews.length : widget.reviewCount} reviews',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = reviews
                                .where((r) => r.rating.round() == star)
                                .length;
                            final pct = reviews.isEmpty
                                ? (star == 5 ? 0.6 : star == 4 ? 0.2 : star == 3 ? 0.1 : 0.05)
                                : count / reviews.length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$star',
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                Colors.amber),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${(pct * 100).toInt()}%',
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sort row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sort reviews by:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox(),
                      items: ['Most Helpful', 'Newest', 'Highest Rating']
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _sortBy = v!),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Reviews list
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A5C5A)))
                else if (reviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text('No reviews yet. Be the first to review!',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...reviews.map((review) => Semantics(
                        label:
                            'Review by ${review.reviewerName}, rated ${review.rating} stars. ${review.comment}',
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(review.reviewerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      Text(
                                          review.rating
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${review.createdAt.day} ${_monthName(review.createdAt.month)} ${review.createdAt.year}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12),
                                  ),
                                  if (review.isVerifiedBuyer) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2F1),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: const Text('Verified Buyer',
                                          style: TextStyle(
                                              color: Color(0xFF1A5C5A),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Semantics(
                                    label:
                                        'Mark review as helpful, ${review.helpfulCount} found helpful',
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () => _communityService
                                          .markHelpful(review.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                            'Helpful (${review.helpfulCount})',
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Semantics(
                                    label: 'Listen to review button',
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2F1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.volume_up_outlined,
                                                color: Color(0xFF1A5C5A),
                                                size: 14),
                                            SizedBox(width: 4),
                                            Text('Listen',
                                                style: TextStyle(
                                                    color:
                                                        Color(0xFF1A5C5A),
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),

                const SizedBox(height: 16),

                // Write a review
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Write a Review',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      // Star rating picker
                      Row(
                        children: List.generate(
                          5,
                          (i) => Semantics(
                            label: '${i + 1} star rating',
                            button: true,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _newRating = i + 1.0),
                              child: Icon(
                                i < _newRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1A5C5A), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (_commentCtrl.text.isEmpty) return;
                                  setState(() => _isSubmitting = true);
                                  try {
                                    await _communityService.postReview(
                                      productId: widget.productId,
                                      rating: _newRating,
                                      comment: _commentCtrl.text.trim(),
                                    );
                                    _commentCtrl.clear();
                                    setState(() {
                                      _newRating = 5.0;
                                      _isSubmitting = false;
                                    });
                                  } catch (e) {
                                    setState(() => _isSubmitting = false);
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A5C5A),
                            side: const BorderSide(
                                color: Color(0xFF1A5C5A), width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Write a Review',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}