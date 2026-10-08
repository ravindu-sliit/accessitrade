import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'REQ-001',
      'title': 'Sensory-safe school clothing for 16-year-old',
      'description':
          'Looking for seamless, tagless cotton shirts in sizes 14-16 boys. My son has ASD and cannot tolerate rough textures or tight collars.',
      'poster': 'Kamala F.',
      'date': '2 hours ago',
      'responses': 3,
      'tags': ['Sensory', 'Clothing'],
    },
    {
      'id': 'REQ-002',
      'title': 'Occupational therapy grip tools for home use',
      'description':
          'Need hand strengthening tools recommended for post-stroke rehabilitation. Prefer locally made or sourced items.',
      'poster': 'Nimal P.',
      'date': 'Yesterday',
      'responses': 1,
      'tags': ['Mobility', 'Therapy'],
    },
    {
      'id': 'REQ-003',
      'title': 'Braille labelling service for kitchen items',
      'description':
          'Looking for someone who can create braille labels for spice jars and pantry containers. Approximately 30 items.',
      'poster': 'Anoma S.',
      'date': '3 days ago',
      'responses': 5,
      'tags': ['Visual', 'Custom'],
    },
  ];

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
          Semantics(
            label: 'Post a new custom request button',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showPostRequestSheet(context),
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
      floatingActionButton: Semantics(
        label: 'Post a new custom request button',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () => _showPostRequestSheet(context),
          backgroundColor: const Color(0xFF1A5C5A),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Post Request',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Semantics(
          label:
              'Custom request: ${request['title']}, posted by ${request['poster']}, ${request['responses']} seller responses',
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 6,
                    children: (request['tags'] as List<String>)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(tag,
                                  style: const TextStyle(
                                      color: Color(0xFF1A5C5A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    request['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(request['poster'],
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(request['date'],
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
                          '${request['responses']} Responses',
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
                    color: Colors.black.withOpacity(0.05),
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
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

  void _showPostRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Post Custom Request',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _requestField('What do you need?',
                  'e.g. Sensory-safe clothing for teenager with ASD'),
              const SizedBox(height: 12),
              _requestField(
                  'Describe your requirements',
                  'Include size, material, specific needs...',
                  maxLines: 3),
              const SizedBox(height: 12),
              _requestField('Category', 'e.g. Sensory, Mobility, Visual'),
              const SizedBox(height: 12),
              _requestField(
                  'Budget range (optional)', 'e.g. Rs. 500 – Rs. 2000'),
              const SizedBox(height: 20),
              Semantics(
                label: 'Submit custom request button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Your request has been posted to the community'),
                          backgroundColor: Color(0xFF1A5C5A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Text('Submit Request',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetailSheet(
      BuildContext context, Map<String, dynamic> request) {
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
              Text(request['title'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(request['description'],
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 16),
              const Text('Seller Responses',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _SellerResponse(
                sellerName: 'Sanduni\'s Crafts',
                message:
                    'Hello! I specialise in sensory-safe handmade clothing. I can make seamless tagless shirts in organic cotton. Price: Rs. 1,200 per shirt.',
                rating: 4.7,
                isVerified: true,
                isRecommended: true,
              ),
              const SizedBox(height: 10),
              _SellerResponse(
                sellerName: 'AccessAbility Store',
                message:
                    'We stock imported sensory-friendly clothing. Available sizes 14-16. Price: Rs. 2,800. Can deliver to your door.',
                rating: 4.9,
                isVerified: true,
                isRecommended: false,
              ),
              const SizedBox(height: 10),
              _SellerResponse(
                sellerName: 'Lanka Textiles',
                message:
                    'We can do custom stitching. Contact us for a quote.',
                rating: 3.8,
                isVerified: false,
                isRecommended: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestField(String label, String hint, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF1A5C5A), width: 2),
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
// updated
// updated
// updated
