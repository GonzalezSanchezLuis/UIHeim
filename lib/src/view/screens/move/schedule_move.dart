import 'dart:convert';
import 'package:holi/src/service/controllers/moves/schedule_move_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleMove extends StatefulWidget {
  const ScheduleMove({super.key});

  @override
  _ScheduleMoveState createState() => _ScheduleMoveState();
}

class _ScheduleMoveState extends State<ScheduleMove> {
  final TextEditingController _moveTypeController = TextEditingController();
  final TextEditingController _originAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _suggestions = [];
  String googleApiKey = "AIzaSyCox00NukoO4C-N-V-0ChQBjwl3y34faw0";
  final ScheduleMoveController _scheduleMove = ScheduleMoveController();

  // Variables de desplazamiento
  final double _numberOfRoomsYOffset = 100;
  String? _selectedMovingType;

  Future<void> _getAddressSuggestions(String query) async {
    final String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&language=es";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("RESPUESTA DE LA API: $data"); // <-- Agrega esto para ver errores

      if (data.containsKey('error_message')) {
        print("Error en la API de Google: ${data['error_message']}");
      }

      final predictions = data['predictions'];
      setState(() {
        _suggestions = predictions.map<String>((prediction) => prediction['description'].toString()).toList();
      });
    } else {
      print("Error en la solicitud: ${response.statusCode}");
    }
  }

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
                    DropdownButtonFormField<String>(
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMovingType = newValue!;
                        });
                      },
                      items: ["Pequeña", "Mediana", "Grande"].map(
                        (String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        },
                      ).toList(),
                      decoration: const InputDecoration(
                        labelText: "Tipo de mudanza",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _originAddressController,
                      decoration: InputDecoration(
                          labelText: "Dirección de origen",
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold, 
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_searching_rounded),
                            onPressed: _getUserLocation,
                          )),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _destinationAddressController,
                      decoration: const InputDecoration(
                          labelText: "Dirección de destino",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                      onChanged: (value) => _getAddressSuggestions(value),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa una contraseña';
                      //   }
                      //   return null;
                      // },
                    ),

                    _buildSuggestionList(),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _dateController,
                      readOnly: true, // Evita que el usuario escriba directamente
                      decoration: const InputDecoration(
                        labelText: "Fecha y hora de recogida",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black, 
                          fontWeight: FontWeight.bold, 
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        // Seleccionar fecha
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(), // No se permite seleccionar fechas pasadas
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

                            String formattedDateTime =
                                "${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')} "
                                "${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}";

                            // Asignar al controlador
                            _dateController.text = formattedDateTime;
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Botón de login
                    ElevatedButton(
                      onPressed: () => {_handleScheduleMove()},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
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

  Future<void> _getUserLocation() async {
    // Verificar permisos
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // Obtener la ubicación actual
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Obtener la dirección a partir de las coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      // Usar el primer resultado de la lista (puede haber más)
      Placemark place = placemarks[0];

      // Crear la dirección completa
      String address = '${place.street}, ${place.locality}, ${place.country}';

      // Actualizar el controlador con la dirección obtenida
      _originAddressController.text = address;
    } else {
      // Si el usuario no tiene permisos, puedes mostrar un mensaje
      print('Permiso de ubicación denegado');
    }
  }

  Widget _buildSuggestionList() {
    return _suggestions.isEmpty
        ? const SizedBox()
        : Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () {
                    setState(() {
                      _destinationAddressController.text = _suggestions[index];
                      _suggestions.clear(); // Oculta las sugerencias después de la selección
                    });
                  },
                );
              },
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

    final origin = _originAddressController.text.trim();
    final destination = _destinationAddressController.text.trim();
    DateTime moveDate = DateTime.parse(_dateController.text);

    Map<String, double>? originCoords = await _getCoordinates(origin);
    Map<String, double>? destinationCoords = await _getCoordinates(destination);

    if (originCoords == null || destinationCoords == null) {
      print("No se pudieron obtener las coordenadas");
      return;
    }

    print("Origen: ${originCoords['lat']}, ${originCoords['lng']}");
    print("Destino: ${destinationCoords['lat']}, ${destinationCoords['lng']}");

    if (_formKey.currentState!.validate()) {
      final messageError = await _scheduleMove.registerScheduleMove(
          moveType: _selectedMovingType ?? '',
          originAddress: origin,
          originLat: "${originCoords['lat']}",
          originLng: "${originCoords['lng']}",
          destinationAddress: destination,
          destinationLat: "${destinationCoords['lat']}",
          destinationLng: "${destinationCoords['lng']}",
          status: "PENDINTE",
          userId: userId,
          driverId: 1,
          moveDate: moveDate);

      if (messageError == null) {
        print("Redirigiendo");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              messageError ?? "Algo salio mal",
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red));
      }
    }
  }

  Future<Map<String, double>?> _getCoordinates(String address) async {
    final String url = "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      } else {
        print("Error en la API de Geocoding: ${data['status']}");
      }
    } else {
      print("Error en la solicitud HTTP: ${response.statusCode}");
    }
    return null;
  }

  @override
  void dispose() {
    _moveTypeController.dispose();
    _destinationAddressController.dispose();
    _originAddressController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
