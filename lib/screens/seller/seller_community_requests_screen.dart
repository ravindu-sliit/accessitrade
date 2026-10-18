import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accessitrade/models/custom_request.dart';
import 'package:accessitrade/services/community_service.dart';

class SellerCommunityRequestsScreen extends StatefulWidget {
  const SellerCommunityRequestsScreen({super.key});

  @override
  State<SellerCommunityRequestsScreen> createState() => _SellerCommunityRequestsScreenState();
}

class _SellerCommunityRequestsScreenState extends State<SellerCommunityRequestsScreen> {
  final _service = CommunityService();

  Future<void> _reply(CustomRequest request) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to ${request.title}'),
        content: TextField(controller: controller, autofocus: true, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Your offer or response', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Send response')),
        ],
      ),
    );
    controller.dispose();
    if (message == null || message.isEmpty || !mounted) return;
    try {
      await _service.respondToRequest(requestId: request.id, message: message);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Response sent')));
    } on FirebaseException catch (error) {
      final detail = error.code == 'permission-denied'
          ? 'Permission denied. Deploy the updated firestore.rules and confirm this account has userType "seller".'
          : '${error.code}: ${error.message ?? 'Firestore request failed.'}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send response: $detail')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send response: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Requests')),
      body: StreamBuilder<List<CustomRequest>>(
        stream: _service.getRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load requests: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!;
          if (requests.isEmpty) return const Center(child: Text('No community requests yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(request.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))), Chip(label: Text(request.category))]),
                    Text('Requested by ${request.posterName} · ${request.timeAgo}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Text(request.description),
                    if (request.budget?.isNotEmpty == true) ...[const SizedBox(height: 8), Text('Budget: ${request.budget}')],
                    if (request.imageUrl?.isNotEmpty == true) ...[const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(request.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()))],
                    const SizedBox(height: 12),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _service.getSellerResponses(request.id),
                      builder: (context, responseSnapshot) {
                        final responses = responseSnapshot.data ?? [];
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${responses.length} seller response${responses.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.labelLarge),
                          ...responses.map((response) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.storefront_outlined), title: Text(response['sellerName'] ?? 'Seller'), subtitle: Text(response['message'] ?? ''))),
                        ]);
                      },
                    ),
                    Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => _reply(request), icon: const Icon(Icons.reply), label: const Text('Respond'))),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
