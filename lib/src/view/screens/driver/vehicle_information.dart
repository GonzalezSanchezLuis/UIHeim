import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleInformation extends StatefulWidget {
  const VehicleInformation({super.key});

  @override
  State<VehicleInformation> createState() => _VehicleInformationState();
}

class _VehicleInformationState extends State<VehicleInformation> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileDriverViewModel viewModelDriver;
  bool _isInitialized = false;

final TextEditingController licenseController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController enrollController = TextEditingController();


  @override
  void initState() {
    super.initState();
    viewModelDriver = ProfileDriverViewModel();

  
    viewModelDriver.fetchDriverData().then((_) {
      final p = viewModelDriver.profile;
      licenseController.text = p.licenseNumber ?? '';
      typeController.text = p.vehicleType  ?? '';
      enrollController.text = p.enrollVehicle ?? '';

      setState(() {
        _isInitialized = true;
      });
    });
  }

@override
  void dispose() {
    licenseController.dispose();
    typeController.dispose();
    enrollController.dispose();
    super.dispose();
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
              title: Text(
                "Información del vehículo",
                style: StyleFontsTitle.titleStyle,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.w,
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

              return SingleChildScrollView(
                child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 12.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 12.w),
                          ),

                          SizedBox(height: 20.h),

                          _buildFieldCard("Licencia número", "N° de licencia", licenseController),
                          _buildFieldCard("Tipo de vehículo", "Ej: NPR, NHR", typeController),
                          _buildFieldCard("Matrícula", "Placa del vehículo", enrollController),
                        ],
                      ),
                    )),
              );
            })));
  }
}


Widget _buildFieldCard(String label, String hint, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: controller,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                isDense: true, 
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                border: InputBorder.none, 
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

