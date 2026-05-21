import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingMoveCardWrapper extends StatefulWidget {
  final Map<String, dynamic> moveData;

  const FloatingMoveCardWrapper({super.key, required this.moveData});

  @override
  State<FloatingMoveCardWrapper> createState() => _FloatingMoveCardWrapperState();
}

class _FloatingMoveCardWrapperState extends State<FloatingMoveCardWrapper> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  Offset _offset = const Offset(0, 0.2);

@override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _offset = Offset.zero;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: _offset,
        curve: Curves.easeOut,
        child: _buildFloatingMoveCard(context, widget.moveData),
      ),
    );
  }

  Widget _buildFloatingMoveCard(BuildContext context, Map<String, dynamic> moveData) {
    String originalAddress = moveData['origin'];
    List<String> parts = originalAddress.split(',');
    String reduced = parts.take(2).join(',').trim();
    final String userName = (moveData['fullName'] ?? moveData['userName'])?.toString() ?? '';

    String destinationAddress = moveData['destination'];
    List<String> partsDestination = destinationAddress.split(',');
    String reducedDestination = partsDestination.take(2).join(',').trim();

    return Card(
      color: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: const BorderSide(color: AppTheme.primarycolor, width: 2),
      ),
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                SizedBox(width: 5.w),
                Text(
                  'Aceptado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
             SizedBox(height: 5.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: (moveData['avatarProfile'] != null && moveData['avatarProfile'].toString().isNotEmpty) ? NetworkImage(moveData['avatarProfile']) : null,
                  child: (moveData['avatarProfile'] == null || moveData['avatarProfile'].toString().isEmpty) ?  Icon(Icons.person, size: 14.sp, color: Colors.white) : null,
                ),
                 SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'Vamos por la carga de $userName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                 Icon(Icons.circle, color: Colors.green, size: 10.sp),
                 SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    reduced,
                    style:  TextStyle(color: Colors.white70, fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
             SizedBox(height: 8.h),
            Row(
              children: [
                 Icon(Icons.circle, color: Colors.blueAccent, size: 10.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    reducedDestination,
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding:  EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child:  Row(
                children: [
                  Icon(Icons.location_on, color: Colors.greenAccent, size: 13.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Tu presencia mantiene el viaje en marcha.',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
