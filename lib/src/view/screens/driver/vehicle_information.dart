import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:provider/provider.dart';

class VehicleInformation extends StatefulWidget {
  const VehicleInformation({super.key});

  @override
  State<VehicleInformation> createState() => _VehicleInformationState();
}

class _VehicleInformationState extends State<VehicleInformation> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileDriverViewModel viewModelDriver;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    viewModelDriver = ProfileDriverViewModel();
    viewModelDriver.fetchDriverData().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          strokeWidth: 4,
          color: Colors.black,
        )),
      );
    }

    return ChangeNotifierProvider.value(
        value: viewModelDriver,
        child: Scaffold(
            backgroundColor: AppTheme.colorbackgroundview,
            appBar: AppBar(
              backgroundColor: AppTheme.primarycolor,
              title: const Text(
                "Información del vehículo",
                style: StyleFontsTitle.titleStyle,
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Consumer<ProfileDriverViewModel>(builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final profile = viewModel.profile;
              final licenseNumberController = TextEditingController(text: profile.licenseNumber);
              final vehicleTypeController = TextEditingController(text: profile.vehicleType);
              final enrollVehicleController = TextEditingController(text: profile.enrollVehicle);

              return SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                          ),

                          const SizedBox(height: 20.0),
                          _buildFieldCard("Licencia número", "Ingresa tu número", licenseNumberController, readOnlyCondition: true, isRequired: true),
                          _buildFieldCard("Tipo de vehículo", "Ingresa el tipo de vehículo", vehicleTypeController, readOnlyCondition: true, isRequired: true),
                          _buildFieldCard("Matricula  del vehículo", "Ingresa la matricula de vehículo", enrollVehicleController, readOnlyCondition: true, isRequired: true),
                        ],
                      ),
                    )),
              );
            })));
  }
}

Widget _buildFieldCard(String label, String hintText, TextEditingController controller, {bool readOnlyCondition = false, bool isRequired = false, bool obscure = false}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              validator: isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    }
                  : null,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              readOnly: readOnlyCondition && controller.text.isNotEmpty,
            ),
          ),
        ],
      ),
    ),
  );
}
