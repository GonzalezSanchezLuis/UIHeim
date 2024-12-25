import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';

class ScheduleMove extends StatefulWidget {
  const ScheduleMove({super.key});

  @override
  _ScheduleMoveState createState() => _ScheduleMoveState();
}

class _ScheduleMoveState extends State<ScheduleMove> {
  final TextEditingController _numberOfRoomsController =
      TextEditingController();
  final TextEditingController _sourceAddressController =
      TextEditingController();
  final TextEditingController _originAddressController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables de desplazamiento
  final double _numberOfRoomsYOffset = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Programar mudanza"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
          children: [
            const Positioned(
              top: 35,
              left: 15,
              child: Text(
                "Completa el formulario para programar tu mudanza",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Formulario para gestionar los inputs de manera optimizada
            Positioned(
              top: _numberOfRoomsYOffset,
              left: 10,
              right: 10,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de correo
                    TextFormField(
                      controller: _numberOfRoomsController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Número de de habitaciones",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors
                                .black, // Cambia este color al que prefieras
                            fontWeight:
                                FontWeight.bold, // Opcional, para resaltar
                          )),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa un email';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _sourceAddressController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Dirección de origen",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors
                                .black, // Cambia este color al que prefieras
                            fontWeight:
                                FontWeight.bold, // Opcional, para resaltar
                          )),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa una contraseña';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _originAddressController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Dirección de destino",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors
                                .black, // Cambia este color al que prefieras
                            fontWeight:
                                FontWeight.bold, // Opcional, para resaltar
                          )),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa una contraseña';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _dateController,
                      readOnly:
                          true, // Evita que el usuario escriba directamente
                      decoration: const InputDecoration(
                        labelText: "Fecha de recogida",
                        border: OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 2.0)),
                        floatingLabelStyle: const TextStyle(
                          color: Colors
                              .black, // Cambia este color al que prefieras
                          fontWeight:
                              FontWeight.bold, // Opcional, para resaltar
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime
                              .now(), // No se permite seleccionar fechas pasadas
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          // Formatear la fecha y asignarla al controlador
                          _dateController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Botón de login
                    ElevatedButton(
                      onPressed: () => {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const RequestVehicle()))
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.9, 60),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Solicitar vehículo",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberOfRoomsController.dispose();
    _sourceAddressController.dispose();
    _originAddressController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
