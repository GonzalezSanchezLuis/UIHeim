import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? width; // Lo hacemos opcional para que pueda heredar del padre
  final double? height;
  final Widget icon; // Cambiado a Widget para más flexibilidad
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.width,
    this.height,
    this.onTap,
    this.icon = const Icon(Icons.settings),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 0.9.sw,
        height: height ?? 100.h,
        decoration: BoxDecoration(
          color: AppTheme.colorcards,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              // Contenedor para el icono con tamaño adaptable
              SizedBox(
                width: 40.w,
                child: icon,
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTheme.boldTitle.copyWith(
                        fontSize: 16.sp, 
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),

              // Agregamos una flechita sutil al final para indicar que es clickeable
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
