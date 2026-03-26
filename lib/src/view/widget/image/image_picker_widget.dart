import 'dart:io';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: Colors.black,
        useSafeArea: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading:  Icon(Icons.camera_alt, color: Colors.white,size: 24.sp,),
                  title:  Text("Tomar foto", style: TextStyle(color: Colors.white,fontSize: 14.sp)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading:  Icon(Icons.photo_library, color: Colors.white,size: 24.sp,),
                  title: Text("Seleccionar de la galería", style: TextStyle(color: Colors.white,fontSize: 14.sp)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                 SizedBox(height: 8.h,)
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
  if (selectedImage != null) {
    imageProvider = FileImage(selectedImage!);
  } 
  else if (imageUrl != null && imageUrl!.startsWith('http')) {
    imageProvider = NetworkImage(imageUrl!);
  }

    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical:8.h),
        decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.grey[300],
            backgroundImage: imageProvider,
            child: imageProvider == null ?  Icon(Icons.person, size: 35.sp, color: Colors.black) : null,
          ),
           SizedBox(width: 16.w),
           Expanded(
            child: Text(
              "Cambiar foto de perfil",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
           Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey[600]),
        ],
      ),
       ),
    );
  }
}
