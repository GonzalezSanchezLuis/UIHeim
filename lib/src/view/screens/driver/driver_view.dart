import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/service/drivers/driver_profile_service.dart';
import 'package:holi/src/view/screens/driver/configuration_driver_view.dart';
import 'package:holi/src/view/widget/card/account_card_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Driver extends StatefulWidget {
  const Driver({super.key});

  @override
  _DriverState createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  String name = "";
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    final profileService = DriverProfileService();
    final driverData = await profileService.fetchDriverData();

    if (driverData != null) {
      print("Datos del usuario: $driverData");
      setState(() {
        name = driverData['fullName'] ?? 'Nombre no disponible';
        String? url = driverData['urlAvatarProfile'];
        avatarUrl = (url != null && url.startsWith('http')) ? url : null;

      });
    } else {
      setState(() {
        name = 'Nombre no disponible'; 
        avatarUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
         backgroundColor: AppTheme.primarycolor,
        title:  Text(
          "Mi cuenta",
          style: StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,size: 20.sp,),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
             SizedBox( height: 40.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(
                    padding:  EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 35.r,
                            backgroundImage: NetworkImage(avatarUrl!),
                          )
                        : CircleAvatar(
                            radius: 35.r,
                            child: Icon(Icons.person, size: 36.sp, color: Colors.black),
                          ),
                  ),
                   SizedBox(width: 15.w),

                   Expanded(child:   Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                           SizedBox(height: 4.h),
                         Text(
                            "¡Hola!",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                   ),
                
                ],
              ),
            ),
             SizedBox(height: 30.h),
            AccountCard(
              title: "Mi cuenta",
              subtitle: "Configuracion",
              width: 0.9.sw,
              height: 60.h,
              icon:  Icon(Icons.settings,size: 22.sp,),
              onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationDriver()))},
            ),
          ],
        ),
      ),
      ) 
    );
  }
}
