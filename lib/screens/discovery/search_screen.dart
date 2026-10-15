import 'package:flutter/material.dart';
import 'package:accessitrade/screens/discovery/search_results_screen.dart';
import 'package:accessitrade/services/voice_service.dart';

class SearchScreen extends StatefulWidget {
  final bool autoStartVoice;
  const SearchScreen({super.key, this.autoStartVoice = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _hasText = false;
  final _voiceService = VoiceService();
  bool _isListening = false;

  final _recentSearches = ['Lightweight Wheelchair', 'Braille Stick', 'Hearing Aid Battery'];
  final _suggestions = ['Mobility Aids → Walker Frame', 'Vision Aids → Braille'];
  final _popular = ['Magnifier', 'Ergonomic Spoon', 'Walker', 'Sign Language Guide'];

  @override
  void initState() {
    super.initState();
    if (widget.autoStartVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVoiceSearch();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _search(String query, {bool fromVoice = false}) {
    if (query.trim().isEmpty) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            query: query,
            fromVoice: fromVoice,
          ),
        ));
  }

  Future<void> _startVoiceSearch() async {
    final initialized = await _voiceService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice search not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isListening = true);

    await _voiceService.startListening(
      onResult: (text) {
        _controller.text = text;
        setState(() => _hasText = text.isNotEmpty);
        _search(text, fromVoice: true);  // <-- add fromVoice: true
      },
      onDone: () {
        setState(() => _isListening = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF1A5C5A), width: 1.5),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: 'Search products input',
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Type tools or equipment...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _hasText = v.isNotEmpty),
                          onSubmitted: _search,
                        ),
                      ),
                    ),
                    if (_hasText)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _hasText = false);
                        },
                      )
                    else
                      GestureDetector(
                        onTap: _isListening ? _voiceService.stopListening : _startVoiceSearch,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.red : const Color(0xFF1A5C5A),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isListening ? 'Listening...' : 'Speak',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),

                  // Suggestions
                  const Text('SEARCH SUGGESTIONS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ..._suggestions.map((s) => Semantics(
                        label: 'Search suggestion: $s',
                        button: true,
                        child: GestureDetector(
                          onTap: () => _search(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Recent searches
                  const Text('RECENT SEARCHES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ..._recentSearches.map((s) => Semantics(
                        label: 'Recent search: $s',
                        button: true,
                        child: GestureDetector(
                          onTap: () => _search(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history, color: Colors.grey, size: 18),
                                const SizedBox(width: 12),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 15))),
                                const Icon(Icons.cancel_outlined, color: Colors.grey, size: 18),
                              ],
                            ),
                          ),
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Popular searches
                  const Text('POPULAR SEARCHES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popular.map((s) => Semantics(
                          label: 'Popular search: $s',
                          button: true,
                          child: GestureDetector(
                            onTap: () => _search(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      color: Color(0xFF1A5C5A),
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}