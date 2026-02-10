import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/widget/history_move_list_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/move/moving_history_viewmodel.dart';
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
    print("ID $id");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovingHistoryViewmodel>(context, listen: false).loadMoveHistory(id, role!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text(
          "Todas mis mudanzas",
          style: StyleFontsTitle.titleStyle,
        ),
      
      ),
      backgroundColor: AppTheme.colorbackgroundview,
      body: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Consumer<MovingHistoryViewmodel>(builder: (context, viewmodel, child) {
            if (viewmodel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewmodel.errorMessage != null) {
              return Center(child: Text('Error: ${viewmodel.errorMessage}'));
            } else if (viewmodel.movingHistory != null && viewmodel.movingHistory!.isNotEmpty) {
              return HistoryMoveList(moves: viewmodel.movingHistory!);
            } else {
              return const Center(child: Text('No hay historial de mudanzas.', style: TextStyle(color: Colors.black, fontSize: 20),));
            }
          })),
    );
  }
}
