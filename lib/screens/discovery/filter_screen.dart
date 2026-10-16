import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _selectedCategories = {'Mobility Aids'};
  double _minPrice = 0;
  double _maxPrice = 100000;
  String? _rating;
  bool _inStockOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5C5A)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Filter Results',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedCategories.clear();
              _minPrice = 0;
              _maxPrice = 100000;
              _rating = null;
              _inStockOnly = false;
            }),
            child: const Text('Clear All',
                style: TextStyle(color: Color(0xFF1A5C5A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Category
                const Text('Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...['Mobility Aids', 'Daily Living', 'Vision Aids', 'Hearing Aids'].map((cat) {
                  final selected = _selectedCategories.contains(cat);
                  return Semantics(
                    label: '$cat category filter, ${selected ? 'selected' : 'not selected'}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedCategories.remove(cat);
                        } else {
                          _selectedCategories.add(cat);
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF1A5C5A) : Colors.transparent,
                                border: Border.all(
                                  color: selected ? const Color(0xFF1A5C5A) : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: selected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(cat, style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Divider(height: 32),

                // Price Range
                const Text('Price Range (Rs.)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: 'Min: Rs. 0',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: 'Max: Rs. 100,000',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Customer Rating
                const Text('Customer Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...['4 stars and above', '3 stars and above'].map((r) {
                  return Semantics(
                    label: '$r rating filter, ${_rating == r ? 'selected' : 'not selected'}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _rating = _rating == r ? null : r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _rating == r ? const Color(0xFF1A5C5A) : Colors.transparent,
                                border: Border.all(
                                  color: _rating == r ? const Color(0xFF1A5C5A) : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _rating == r
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(r, style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Divider(height: 32),

                // Availability
                const Text('Availability',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Semantics(
                  label: 'In stock only filter, ${_inStockOnly ? 'selected' : 'not selected'}',
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() => _inStockOnly = !_inStockOnly),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _inStockOnly ? const Color(0xFF1A5C5A) : Colors.transparent,
                            border: Border.all(
                              color: _inStockOnly ? const Color(0xFF1A5C5A) : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _inStockOnly
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Text('In Stock Only', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Semantics(
              label: 'Apply filters button',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Apply Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}