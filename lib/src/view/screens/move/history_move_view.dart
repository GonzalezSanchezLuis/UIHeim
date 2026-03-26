import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/widget/history_move_list_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/move/moving_history_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HistoryMoveView extends StatefulWidget {
  const HistoryMoveView({super.key});

  @override
  _HistoryMoveState createState() => _HistoryMoveState();
}

class _HistoryMoveState extends State<HistoryMoveView> {
  @override
  void initState() {
    super.initState();

    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final rawUserId = sessionVM.userId;
    final role = sessionVM.role;

    final int id = int.tryParse(rawUserId?.toString() ?? '1') ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovingHistoryViewmodel>(context, listen: false).loadMoveHistory(id, role!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: AppTheme.primarycolor,
        centerTitle: true, 
        title: Text(
          "Todas mis mudanzas",
          style: StyleFontsTitle.titleStyle.copyWith(fontSize: 18.sp),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Consumer<MovingHistoryViewmodel>(
            builder: (context, viewmodel, child) {
              if (viewmodel.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3.w,
                  ),
                );
              } else if (viewmodel.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      'Error: ${viewmodel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                );
              } else if (viewmodel.movingHistory != null && viewmodel.movingHistory!.isNotEmpty) {
                return HistoryMoveList(moves: viewmodel.movingHistory!);
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_outlined, size: 80.sp, color: Colors.grey[400]),
                      SizedBox(height: 10.h),
                      Text(
                        'No hay historial de mudanzas.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp, // Fuente adaptable
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
