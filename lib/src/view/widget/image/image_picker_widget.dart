import 'dart:io';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final Function(File?) onImageSelected;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
    this.imageUrl,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      onImageSelected(imageFile);
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.primarycolor,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text("Tomar foto", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text("Seleccionar de la galería", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    }

    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.colorcards,
            backgroundImage: imageProvider,
            child: imageProvider == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Cambiar foto de perfil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

