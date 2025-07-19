import 'package:flutter/material.dart';
import 'package:holi/src/model/driver/profile_driver_model.dart';
import 'package:holi/src/service/drivers/driver_profile_service.dart';
import 'package:holi/src/service/cloudinary/cloudinary_service.dart';
import 'dart:io';

class ProfileDriverViewModel with ChangeNotifier {
  final DriverProfileService _profileService = DriverProfileService();
  ProfileDriverModel _profile = ProfileDriverModel();
  bool _isLoading = false;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  ProfileDriverModel get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchDriverData() async {
    _isLoading = true;
    notifyListeners();

    final data = await _profileService.fetchDriverData();
    if (data != null) {
      _profile = ProfileDriverModel.fromMap(data);
    }

    _isLoading = false;
    notifyListeners();
  }

  void onImageSelected(File? imageFile) {
    _selectedImage = imageFile; 
    notifyListeners();
  }

  Future<void> updateProfile(
      {required String fullName,
      required String email,
      required String phone,
      required String document,
      String? password,}) async {
    _isLoading = true;
    notifyListeners();

    String? imageUrl = _profile.urlAvatarProfile;

    if (_selectedImage != null) {
      imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      print("URL DE LA IMAGEN $imageUrl");
      if (imageUrl == null) {
        _isLoading = false;
        notifyListeners();
        return; // Si falla la subida, no continúes
      }
    }

    // Actualiza el perfil con la nueva URL de la imagen
   final response = await _profileService.updateDataDriver(
      fullName,
      document,
      email,
      phone,
      password ?? '',
      imageUrl ?? _profile.urlAvatarProfile ?? '',
    );


    _isLoading = false;
    notifyListeners();

    if (response != null && response['status'] == 'success') {
      _profile = _profile.copyWith(
          urlAvatarProfile: imageUrl,
          fullName: fullName,
          document: document,
          email: email,
          phone: phone, 
          );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    await _profileService.deleteAccount(context);
  }
}
