import 'dart:io';
import 'package:flutter/material.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String? initialImageUrl; // URL inicial si ya hay una imagen

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl; // Cargar la imagen inicial
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    if (!mounted) return;
    setState(() {
      _selectedImage = File(pickedFile.path);
      _isUploading = true;
    });

    // Enviar la imagen seleccionada al callback del widget
    widget.onImageSelected(_selectedImage);
    setState(() {
      _isUploading = false;
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Tomar foto"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Seleccionar de la galería"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final String? storedImageUrl = profileViewModel.profile.urlAvatarProfile;
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _uploadedImageUrl != null
                    ? NetworkImage(_uploadedImageUrl!)
                    : _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : storedImageUrl != null
                            ? NetworkImage(storedImageUrl)
                            : null,
                child: (_uploadedImageUrl == null && _selectedImage == null) ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
              ),
              if (_isUploading) const CircularProgressIndicator(),
            ],
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
