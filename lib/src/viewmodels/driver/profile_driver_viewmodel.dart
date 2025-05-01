import 'package:flutter/material.dart';
import 'package:holi/src/model/driver/profile_driver_model.dart';
import 'package:holi/src/service/controllers/drivers/driver_profile_controller.dart';
import 'package:holi/src/service/cloudinary/cloudinary_service.dart';
import 'dart:io';

class ProfileViewModel with ChangeNotifier {
  final DriverProfileController _profileController = DriverProfileController();
  ProfileModel _profile = ProfileModel();
  bool _isLoading = false;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  ProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchDriverData() async {
    _isLoading = true;
    notifyListeners();

    final data = await _profileController.fetchDriverData();
    if (data != null) {
      _profile = ProfileModel.fromMap(data);
    }

    _isLoading = false;
    notifyListeners();
  }

  void onImageSelected(File? imageFile) {
    _selectedImage = imageFile; // Guarda la imagen seleccionada
    notifyListeners();
  }

  Future<void> updateProfile(
      {required String fullName,
      required String email,
      required String phone,
      required String document,
      String? password,
      required licenseNumber,
      required String vehicleType,
      required String enrollVehicle}) async {
    _isLoading = true;
    notifyListeners();

    String? imageUrl = _profile.urlAvatarProfile;

    // Sube la imagen a Cloudinary si se seleccionó una nueva
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
    final response = await _profileController.updateDataDriver(
      imageUrl ?? _profile.urlAvatarProfile ?? '',
      fullName,
      document,
      email,
      phone,
      password ?? '',
      licenseNumber,
      vehicleType,
      enrollVehicle,
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
          licenseNumber: licenseNumber,
          vehicleType: vehicleType,
          enrollVehicle: enrollVehicle);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    await _profileController.deleteAccount(context);
  }
}
