import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/join_driver_view.dart';
import 'package:holi/src/view/screens/user/configuration_user_view.dart';
import 'package:holi/src/view/widget/card/account_card_widget.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileUserViewModel>().fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileUserViewModel = context.watch<ProfileUserViewModel>();

    if (profileUserViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        ),
      );
    }

      final imageUrl = profileUserViewModel.profile.urlAvatarProfile;
      final fullName = profileUserViewModel.profile.fullName ?? 'Nombre no disponible';
      return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30.r, 
                        backgroundColor: Colors.black,
                        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                        child: (imageUrl == null || imageUrl.isEmpty) ? Icon(Icons.person, size: 30.sp, color: Colors.white) : null,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 19.sp, // Fuente adaptable
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "¡Hola!",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              AccountCard(
                title: "Mi cuenta",
                subtitle: "Configuración",
                width: 0.9.sw, 
                height: 60.h, 
                icon: Icon(
                  Icons.settings_outlined,
                  size: 22.sp,
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationUser())),
              ),

              SizedBox(height: 5.h),
              AccountCard(
                title: "Otros",
                subtitle: "Realiza mudanzas con Heim",
                width: 0.9.sw, // Consistencia universal
                height: 60.h,
                icon: Icon(
                  Icons.local_shipping_outlined,
                  size: 22.sp,
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinDriver())),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
