import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static final _categories = [
    {'label': 'Mobility Aids', 'count': '140', 'icon': Icons.accessible},
    {'label': 'Daily Living Aids', 'count': '85', 'icon': Icons.restaurant},
    {'label': 'Vision Aids', 'count': '62', 'icon': Icons.visibility},
    {'label': 'Hearing Aids', 'count': '44', 'icon': Icons.hearing},
    {'label': 'Home Mods', 'count': '31', 'icon': Icons.home},
    {'label': 'Clothing', 'count': '92', 'icon': Icons.checkroom},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Browse Categories',
                  style: TextStyle(fontSize: accessibility.titleFontSize, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Search bar
              Semantics(
                label: 'Search categories',
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: colorScheme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Search categories...',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                      ),
                      Semantics(
                        label: 'Voice search categories button',
                        button: true,
                        hint: 'Start voice search for categories',
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.mic, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Speak', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return Semantics(
                      label: '${cat['label']}, ${cat['count']} items',
                      button: true,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(cat['icon'] as IconData,
                                    color: colorScheme.primary, size: 28),
                              ),
                              const SizedBox(height: 10),
                              Text(cat['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: accessibility.smallFontSize)),
                              const SizedBox(height: 4),
                              Text('${cat['count']} Items',
                                  style: TextStyle(
                                      color: Colors.grey.shade500, fontSize: accessibility.smallFontSize)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}