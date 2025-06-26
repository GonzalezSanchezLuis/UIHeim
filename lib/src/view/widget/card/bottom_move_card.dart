import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/status_of_the_move.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/viewmodels/move/update_status_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class BottomMoveCard extends StatefulWidget {
  final int driverId;
  final int moveId;
  const BottomMoveCard({super.key, required this.driverId, required this.moveId});

  @override
  State<BottomMoveCard> createState() => _BottomMoveCardState();
}

class _BottomMoveCardState extends State<BottomMoveCard> {
  bool _isExpanded = false;
  StatusOfTheMove _statusOfTheMove = StatusOfTheMove.DRIVER_ARRIVED;

  @override
  Widget build(BuildContext context) {
    final updateStausMoveViewmodel = Provider.of<UpdateStatusMoveViewmodel>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera con flechita animada
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isExpanded ? 0.5 : 0.0,
                  child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rumbo al punto de encuentro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contenido con animación suave
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Builder(
              builder: (context) {
                switch (_statusOfTheMove) {
                  case StatusOfTheMove.DRIVER_ARRIVED:
                    return SlideAction(
                      onSubmit: () async {
                        print("✅ Enviando DRIVER_ARRIVED con moveId: ${widget.moveId}, driverId: ${widget.driverId}");
                        await updateStausMoveViewmodel.changeStatus(
                          moveId: widget.moveId,
                          driverId: widget.driverId,
                        );
                        setState(() {
                          _statusOfTheMove = StatusOfTheMove.MOVING_STARTED;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Esperando al pasajero...")),
                        );
                      },
                      text: 'Desliza para notificar que llegaste',
                      outerColor: AppTheme.primarycolor,
                    );

                  case StatusOfTheMove.MOVING_STARTED:
                    return SlideAction(
                      onSubmit: () {
                        print("🟢 Iniciando recorrido...");
                        setState(() {
                          _statusOfTheMove = StatusOfTheMove.MOVE_COMPLETE;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Recorrido iniciado")),
                        );
                      },
                      text: 'Iniciar mudanza',
                      outerColor: AppTheme.confirmationscolor,
                    );

                  case StatusOfTheMove.MOVE_COMPLETE:
                  return SlideAction(
                      onSubmit: () async {
                        print("🟢 FInalizando recorrido...");
                        await updateStausMoveViewmodel.changeStatus(
                          moveId: widget.moveId,
                          driverId: widget.driverId,
                        );
                        setState(() {
                          _statusOfTheMove = StatusOfTheMove.MOVE_FINISHED;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Recorrido finalizado")),
                        );
                      },
                      text: 'Finalizar mudanza',
                      outerColor: AppTheme.warningcolor,
                    );

                  case StatusOfTheMove.MOVE_FINISHED:
                   return const Column(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
                        SizedBox(height: 12),
                        Text(
                          "✅ Mudanza finalizada con éxito",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


