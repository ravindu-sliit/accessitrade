import 'package:flutter/material.dart';
import 'package:accessitrade/models/custom_request.dart';
import 'package:accessitrade/screens/community/product_request_screen.dart';
import 'package:accessitrade/services/community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();

  final List<Map<String, dynamic>> _sellers = [
    {
      'name': 'AccessAbility Store',
      'rating': 4.9,
      'reviews': 87,
      'speciality': 'Visual & Tactile aids',
      'badge': 'Top Seller',
      'isVerified': true,
      'responseTime': 'Usually replies in 2 hours',
    },
    {
      'name': 'Sanduni\'s Crafts',
      'rating': 4.7,
      'reviews': 34,
      'speciality': 'Sensory & handmade items',
      'badge': 'Accessibility Verified',
      'isVerified': true,
      'responseTime': 'Usually replies same day',
    },
    {
      'name': 'MobilityPlus SL',
      'rating': 4.5,
      'reviews': 52,
      'speciality': 'Mobility aids & equipment',
      'badge': null,
      'isVerified': false,
      'responseTime': 'Usually replies in 1 day',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Community Hub',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Semantics(
              label: 'Post a new custom request button',
              button: true,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductRequestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Post Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Custom Requests'),
            Tab(text: 'Trusted Sellers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildSellersTab(),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return StreamBuilder<List<CustomRequest>>(
      stream: _communityService.getRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A5C5A)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading requests: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No custom requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to post a request for accessible products!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Semantics(
              label:
                  'Custom request: ${request.title}, posted by ${request.posterName}, ${request.responseCount} seller responses',
              button: true,
              child: GestureDetector(
                onTap: () => _showRequestDetailSheet(context, request),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag & optional budget
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              request.category,
                              style: const TextStyle(
                                  color: Color(0xFF1A5C5A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (request.budget != null &&
                              request.budget!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                request.budget!,
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        request.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        request.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                      if (request.imageUrl != null &&
                          request.imageUrl!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            request.imageUrl!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(request.posterName,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(request.timeAgo,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A5C5A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${request.responseCount} Responses',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSellersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sellers.length,
      itemBuilder: (context, index) {
        final seller = _sellers[index];
        return Semantics(
          label:
              '${seller['name']}, rated ${seller['rating']} stars from ${seller['reviews']} reviews, ${seller['speciality']}${seller['isVerified'] ? ', accessibility verified' : ''}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_outlined,
                          color: Color(0xFF1A5C5A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(seller['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              if (seller['isVerified']) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified,
                                    color: Color(0xFF1A5C5A), size: 16),
                              ],
                            ],
                          ),
                          Text(seller['speciality'],
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '${seller['rating']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text('${seller['reviews']} reviews',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                if (seller['badge'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      seller['badge'],
                      style: const TextStyle(
                          color: Color(0xFF1A5C5A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(seller['responseTime'],
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    const Spacer(),
                    Semantics(
                      label: 'Contact ${seller['name']} button',
                      button: true,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A5C5A),
                          side: const BorderSide(
                              color: Color(0xFF1A5C5A)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                        ),
                        child: const Text('Contact',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRequestDetailSheet(BuildContext context, CustomRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(request.description,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 14)),
              if (request.budget != null && request.budget!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Budget: ${request.budget}',
                    style: const TextStyle(
                        color: Color(0xFF1A5C5A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
              if (request.imageUrl != null && request.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    request.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Seller Responses',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const _SellerResponse(
                sellerName: 'Sanduni\'s Crafts',
                message:
                    'Hello! I specialise in sensory-safe handmade products. I can customize this to your exact requirements.',
                rating: 4.7,
                isVerified: true,
                isRecommended: true,
              ),
              const SizedBox(height: 10),
              const _SellerResponse(
                sellerName: 'AccessAbility Store',
                message:
                    'We stock similar items in our store. Delivery available islandwide.',
                rating: 4.9,
                isVerified: true,
                isRecommended: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerResponse extends StatelessWidget {
  final String sellerName;
  final String message;
  final double rating;
  final bool isVerified;
  final bool isRecommended;

  const _SellerResponse({
    required this.sellerName,
    required this.message,
    required this.rating,
    required this.isVerified,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Response from $sellerName, rated $rating stars${isVerified ? ', accessibility verified' : ''}${isRecommended ? ', recommended' : ''}. Message: $message',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended
              ? const Color(0xFFE0F2F1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended
                ? const Color(0xFF1A5C5A)
                : Colors.grey.shade200,
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(sellerName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified,
                      color: Color(0xFF1A5C5A), size: 15),
                ],
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text('$rating',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
            if (isRecommended) ...[
              const SizedBox(height: 4),
              const Text('Recommended',
                  style: TextStyle(
                      color: Color(0xFF1A5C5A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 8),
            Text(message,
                style:
                    TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 10),
            Semantics(
              label: 'Contact $sellerName button',
              button: true,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Contact Seller',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
