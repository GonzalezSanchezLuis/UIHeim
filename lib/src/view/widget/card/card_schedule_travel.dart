import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardScheduleTravel extends StatelessWidget {
  const CardScheduleTravel({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _dateController = TextEditingController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
      child: Stack(
        children: [
          const Positioned(
            top: 10,
            left: 15,
            child: Text(
              "Selecciona la hora y fecha de recogida",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Fecha y hora de recogida",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12.r,
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white, width: 2.0)),
                      floatingLabelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () async {
                      // Seleccionar fecha
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        // Seleccionar hora
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          // Formatear fecha y hora
                          DateTime selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          String formattedDateTime = "${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')} "
                              "${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}";

                          // Asignar al controlador
                          _dateController.text = formattedDateTime;

                          // Cierra el modal; HomeUserView vuelve a mostrar _buildDataMove
                          if (context.mounted) {
                            Navigator.of(context).pop(selectedDateTime);
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScheduleMove() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print("ID DEL USUARIO $userId");

    if (userId == null) {
      print("User ID no encontrado");
      return null;
    }

    //DateTime moveDate = DateTime.parse(_dateController.text);
  }

/*  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  } */
}
