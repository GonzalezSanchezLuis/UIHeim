import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart'; // Importa Flushbar
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/travel/history_moving_model.dart';
import 'package:holi/src/view/screens/travel/move_details_view.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formatear fechas
import 'package:holi/src/viewmodels/travel/moving_history_viewmodel.dart'; // Importa el ViewModel
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class HistoryMoveList extends StatefulWidget {
  const HistoryMoveList({
    super.key,
    required this.moves,
  });

  final List<HistoryMovingModel> moves;
  @override
  State<HistoryMoveList> createState() => _HistoryMoveListState();
}

class _HistoryMoveListState extends State<HistoryMoveList> {
  int? _currentUserId; // State variable to hold the current user's ID

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.moves.length,
      padding: EdgeInsets.only(bottom: 20.h),
      itemBuilder: (context, index) {
        final move = widget.moves[index];
        final String originalAddress = move.origin;
        final List<String> parts = originalAddress.split(',');
        final String reducedOriginAddress = parts.take(1).join(',').trim();

        final String destinationAddress = move.destination;
        final List<String> partsDestination = destinationAddress.split(',');
        final String reducedDestinationAddress = partsDestination.take(1).join(',').trim();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoveDetailsView(
                  moveId: move.moveId,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8..h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(move.status),
                      if (move.status == 'programada')
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Confirmar Cancelación'),
                                  content: const Text('¿Estás seguro de que quieres cancelar este viaje? No hay cobro.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                    ),
                                    TextButton(
                                      child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        Navigator.of(dialogContext).pop();
                                        // Context del Navigator: sobrevive al rebuild de la lista.
                                        final flushbarContext = Navigator.of(context).context;

                                        if (_currentUserId == null) {
                                          _showFlushbar(flushbarContext, 'Error', 'No se pudo  cancelar el viaje.', AppTheme.warningcolor, Icons.error_outline);
                                          return;
                                        }

                                        final movingHistoryViewModel = Provider.of<MovingHistoryViewmodel>(context, listen: false);
                                        final bool success = await movingHistoryViewModel.cancelMove(move.moveId);

                                        if (!flushbarContext.mounted) {
                                          return;
                                        }

                                        if (success) {
                                          _showFlushbar(
                                            flushbarContext,
                                            '¡Viaje Cancelado!',
                                            'El viaje ha sido cancelado exitosamente.',
                                            AppTheme.confirmationscolor,
                                            Icons.check_circle_outline,
                                          );
                                        } else {
                                          _showFlushbar(
                                            flushbarContext,
                                            'Error al Cancelar',
                                            movingHistoryViewModel.errorMessage ?? 'No se pudo cancelar el viaje.',
                                            AppTheme.warningcolor,
                                            Icons.error_outline,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (move.status == 'programada' && move.scheduledTime != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'Programado para: ${DateFormat('dd/MM/yyyy hh:mm a').format(move.scheduledTime!)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      CircleAvatar(
                        // Asegúrate de que move.avatar sea válido
                        backgroundImage: move.avatar.startsWith('http') ? NetworkImage(move.avatar) : AssetImage(move.avatar) as ImageProvider,
                        radius: 22.r,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              move.name,
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              move.enrollVehicle,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.colorcards,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildLocationColumn('Origen', reducedOriginAddress),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(Icons.arrow_right_alt, color: Colors.grey[400], size: 20.sp),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildLocationColumn('Destino', reducedDestinationAddress),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationColumn(String label, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: const Color(0xFF002C2B),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          address,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'cancelada':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;

      case 'programada':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFFFFBC11);
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.sp,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showFlushbar(BuildContext context, String title, String message, Color color, IconData icon) {
    if (!context.mounted) {
      return;
    }

    Flushbar(
      title: title,
      message: message,
      backgroundColor: color,
      icon: Icon(icon, size: 28.sp, color: Colors.white),
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(12.w),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}
