import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:accessitrade/services/cloudinary_service.dart';
import 'package:accessitrade/services/community_service.dart';

class ProductRequestScreen extends StatefulWidget {
  const ProductRequestScreen({super.key});

  @override
  State<ProductRequestScreen> createState() => _ProductRequestScreenState();
}

class _ProductRequestScreenState extends State<ProductRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final CommunityService _communityService = CommunityService();

  final SpeechToText _speech = SpeechToText();
  bool _speechInitialized = false;
  String? _listeningFieldName; // 'title', 'description', or null

  String _selectedCategory = 'Sensory';
  final List<String> _categories = [
    'Sensory',
    'Tactile',
    'Mobility',
    'Visual',
    'Hearing',
    'Daily Living',
    'Custom',
  ];

  XFile? _imageFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _listenForField(
      TextEditingController controller, String fieldName) async {
    if (_speech.isListening && _listeningFieldName == fieldName) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _listeningFieldName = null;
        });
      }
      return;
    }

    if (!_speechInitialized) {
      try {
        _speechInitialized = await _speech.initialize(
          onError: (err) {
            debugPrint('Speech error: ${err.errorMsg}');
            if (mounted) {
              setState(() => _listeningFieldName = null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Speech error: ${err.errorMsg}')),
              );
            }
          },
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              if (mounted) setState(() => _listeningFieldName = null);
            }
          },
        );
      } catch (e) {
        _speechInitialized = false;
      }
    }

    if (!_speechInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Voice typing is not available on this device')),
        );
      }
      return;
    }

    setState(() {
      _listeningFieldName = fieldName;
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              if (result.recognizedWords.isNotEmpty) {
                controller.text = result.recognizedWords;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            });
          }
        },
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 4),
        localeId: 'en_US',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _listeningFieldName = null);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = source == ImageSource.gallery
          ? await _cloudinaryService.pickFromGallery()
          : await _cloudinaryService.pickFromCamera();
      if (image != null && mounted) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF1A5C5A)),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: Color(0xFF1A5C5A)),
                title: const Text('Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final budget = _budgetController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? uploadedImageUrl;
      if (_imageFile != null) {
        uploadedImageUrl = await _cloudinaryService.uploadImage(_imageFile!);
      }

      await _communityService.postRequest(
        title: title,
        description: description,
        category: _selectedCategory,
        tags: [_selectedCategory],
        imageUrl: uploadedImageUrl,
        budget: budget.isNotEmpty ? budget : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Your custom product request has been posted!'),
            backgroundColor: Color(0xFF1A5C5A),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request created: $e'),
            backgroundColor: const Color(0xFF1A5C5A),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
            color: Color(0xFFE0F2F1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5C5A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Product Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name / Request Title Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _listeningFieldName == 'title'
                          ? Colors.red
                          : const Color(0xFF1A5C5A),
                      width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What product do you need?',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5C5A)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter what product you want';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Type product title or request...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Semantics(
                          label: 'Voice type product title',
                          button: true,
                          child: IconButton(
                            icon: Icon(
                              _listeningFieldName == 'title'
                                  ? Icons.mic
                                  : Icons.mic_none,
                              color: _listeningFieldName == 'title'
                                  ? Colors.red
                                  : const Color(0xFF1A5C5A),
                            ),
                            onPressed: () =>
                                _listenForField(_titleController, 'title'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Selection Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                        color: Color(0xFF1A5C5A),
                        fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF1A5C5A)),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Detailed Description with Voice Typing
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _listeningFieldName == 'description'
                        ? Colors.red
                        : const Color(0xFF1A5C5A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Describe what product you need',
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please describe your requirements';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText:
                              'Describe requirements (size, texture, material, specific needs)...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        label: 'Use voice to describe your request',
                        button: true,
                        child: GestureDetector(
                          onTap: () => _listenForField(
                              _descriptionController, 'description'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _listeningFieldName == 'description'
                                  ? Colors.red.shade100
                                  : const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _listeningFieldName == 'description'
                                      ? Icons.mic
                                      : Icons.mic_none,
                                  color: _listeningFieldName == 'description'
                                      ? Colors.red
                                      : const Color(0xFF1A5C5A),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _listeningFieldName == 'description'
                                      ? 'Listening...'
                                      : 'Voice Typing',
                                  style: TextStyle(
                                    color: _listeningFieldName ==
                                            'description'
                                        ? Colors.red
                                        : const Color(0xFF1A5C5A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Budget Range Field (Optional)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Range (Optional)',
                    labelStyle: TextStyle(
                        color: Color(0xFF1A5C5A),
                        fontWeight: FontWeight.bold),
                    hintText: 'e.g. Rs. 500 – Rs. 2,000',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Supporting Files & Screenshots',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Image Preview or Upload Container
              if (_imageFile != null) ...[
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1A5C5A)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FutureBuilder<Uint8List>(
                          future: _imageFile!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1A5C5A),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Semantics(
                  label: 'Upload supporting image or file button',
                  button: true,
                  child: GestureDetector(
                    onTap: _showImagePickerModal,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Click to select image',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'PNG or JPG up to 10MB',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Gallery and Camera Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Upload from gallery button',
                      button: true,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text(
                          'From Gallery',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A5C5A),
                          side: const BorderSide(
                              color: Color(0xFF1A5C5A), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Take a photo button',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5C5A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Submit Button
              Semantics(
                label: 'Submit custom request button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Submit Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
