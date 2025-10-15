import 'package:flutter/foundation.dart';
import 'package:holi/src/model/driver/driver_data_model.dart';
import 'package:holi/src/service/drivers/driver_data_service.dart';

class DriverDataViewmodel extends ChangeNotifier {
  final DriverDataService _driverDataService = DriverDataService();

  DriverDataModel? driverDataModel;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadDriverData(int driverId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> rawData = await _driverDataService.fetchDriverData(driverId);
      print("RAW $rawData");
      driverDataModel = DriverDataModel.fromJson(rawData);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
