import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverInformationView extends StatefulWidget {
  final int driverId;

  const DriverInformationView({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverInformationView> createState() => _DriverDataViewState();
}

class _DriverDataViewState extends State<DriverInformationView> {
  final List<String> _securityChecks = ["Identidad Validada", "Antecedentes Judiciales Limpios", "Vehículo Inspeccionado", "Seguro de Carga Activo"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverDataViewmodel>().loadDriverData(widget.driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<DriverDataViewmodel>();
    if (viewmodel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (viewmodel.errorMessage != null) {
      return Center(child: Text("Error: ${viewmodel.errorMessage}"));
    }
    if (viewmodel.driverDataModel == null) {
      return const Center(child: Text("No se encontraron datos."));
    }
    final profile = viewmodel.driverDataModel!;
   
    return Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          title:  Text("Perfil del Conductor", style: StyleFontsTitle.titleStyle),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,size: 20.sp,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildProfileHeader(profile),
                 SizedBox(height: 16.h),
                //  _buildVehicleCard("Foton Turbo 2.5", "PLACA: JKL-987"),

                const SizedBox(height: 24),

                // 3. VERIFICACIONES DE SEGURIDAD
                _buildSectionTitle("Verificaciones de Seguridad"),
                SizedBox(height: 10.h),
                Divider(height: 1.h, color: Colors.grey.shade300),
                SizedBox(height: 16.h),
                _buildSecurityList(),

               SizedBox(height: 30.h),
              ],
            ),
          ),
        ));
  }

  Widget _buildProfileHeader(dynamic profile) {
    final String avatarUrl = profile.urlAvatar ?? "";
    final bool hasValidAvatar = avatarUrl.isNotEmpty && avatarUrl.startsWith('http');

    final String displayPhone = (profile.phone == null || profile.phone.isEmpty) ? "Teléfono no disponible" : profile.phone;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primarycolor, width: 2.w),
              ),
              child: CircleAvatar(
                radius: 25.r,
                backgroundColor: const Color(0xFF1E1E24),
                backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null, child: !hasValidAvatar ?  Icon(Icons.person, size: 45.sp, color: Colors.white,) : null,
              ),
            ),
            SizedBox(height: 16.h),
            Text(profile.name, style:  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(displayPhone, style:  TextStyle(fontSize: 12.sp, color: Colors.grey)),
             SizedBox(height: 12.sp),

            // Calificación con RichText (Negrita parcial)
            Container(
              padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.star, color: Colors.amber, size: 20.sp),
                   SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      text: '3.9 ',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '(10 servicios)',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVehicleCard(String model, String plate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(plate, style: const TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityList() {
    return Column(
      children: _securityChecks
          .map((check) => Padding(
                padding:  EdgeInsets.only(bottom: 14.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                     SizedBox(width: 12.w),
                    Text(check, style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade700)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
