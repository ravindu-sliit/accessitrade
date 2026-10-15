import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'jllrtqfk';
  static const String _uploadPreset = 'accessitrade_uploads';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/jllrtqfk/image/upload';

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Pick image from camera
  Future<XFile?> pickFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Upload image file to Cloudinary, returns the secure URL
  Future<String> uploadImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.name.split('.').last.toLowerCase();
    final dataUri = 'data:image/$ext;base64,$base64Image';

    final response = await http.post(
      Uri.parse(_uploadUrl),
      body: {
        'file': dataUri,
        'upload_preset': _uploadPreset,
        'folder': 'accessitrade',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Cloudinary upload failed: ${error['error']['message']}');
    }
  }

  /// Get optimised thumbnail URL from a Cloudinary URL
  /// Adds width, height and auto quality transformations
  static String getThumbnailUrl(String url,
      {int width = 200, int height = 200}) {
    if (url.isEmpty || !url.contains('cloudinary.com')) return url;
    return url.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill,q_auto,f_auto/',
    );
  }
}