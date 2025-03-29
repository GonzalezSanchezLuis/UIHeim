import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/controllers/moves/calculate_price_controller.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/view/screens/user/home_user.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatePrice extends StatefulWidget {
  const CalculatePrice({super.key});

  @override
  _CalculatePriceState createState() => _CalculatePriceState();
}

class _CalculatePriceState extends State<CalculatePrice> {
  final TextEditingController _numberOfRoomsController = TextEditingController();
  final TextEditingController _originAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  bool _isCalculating = false;

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocationService locationService = LocationService();
  final LocationViewModel locationViewModel = LocationViewModel();
  final CalculatePriceController calculatePriceController = CalculatePriceController();

  // Variables de desplazamiento
  final double _numberOfRoomsYOffset = 100;
  final double _sourceAddressYOffset = 180;
  String? _selectedMovingType;
  List<String> _suggestions = [];

   Future<void> _updateSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final suggestions = await locationService.getAddressSuggestions(query);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.colorbackgroundview,
        title: const Text("Calculemos un precio",
            style: TextStyle(fontWeight: FontWeight.bold,)),
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
                "Completa el formulario y calculemos un precio juntos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
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
                    TextFormField(
                      controller: _numberOfRoomsController,
                      decoration: const InputDecoration(
                          labelText: "Número de de habitaciones",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 20),
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
                              onPressed: () async {
                                locationViewModel.updateLocation();
                                _originAddressController.text = locationViewModel.currentAddress;
                              })),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _destinationAddressController,
                      decoration: const InputDecoration(
                          labelText: "Dirección de destino",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )
                          ),
                          onChanged: (value) => {_updateSuggestions(value)},
                    ),

                    _buildSuggestionList(),

                    const SizedBox(height: 20),
                    
                    ElevatedButton(
                      onPressed: () async {
                        _isCalculating ? null : await _handleRequestVehicle();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: ui.Size(MediaQuery.of(context).size.width * 0.9, 60),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isCalculating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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

  Future<void> _handleRequestVehicle() async {
    setState(() {
      _isCalculating = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print("ID DEL USUARIO $userId");

    if (userId == null) {
      print("User ID no encontrado");
      setState(() {
        _isCalculating = false;
      });
      return null;
    }

    final origin = _originAddressController.text.trim();
    final destination = _destinationAddressController.text.trim();

    Map<String, double>? originCoords;
    Map<String, double>? destinationCoords;

    if (origin.isEmpty) {
      Position? position = await locationViewModel.updateLocation();
      if (position != null) {
        originCoords = {"lat": position.latitude, "lng": position.longitude};
        print("Coordenadas de origen  : $originCoords");
      }
    } else {
      originCoords = await locationService.getCoordinatesFromAddress(origin);
    }
    if (destination.isNotEmpty) {
      destinationCoords = await locationService.getCoordinatesFromAddress(destination);
      print(" Coordenadas de destino : $destinationCoords");
    }

    if (originCoords == null || destinationCoords == null) {
      print("No se pudieron obtener coordenadas");
      setState(() {
        _isCalculating = false;
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      final response = await calculatePriceController.calculatedPrice(
        typeOfMove: _selectedMovingType,
        numberOfRooms: _numberOfRoomsController.text,
        originAddress: origin,
        destinationAddress: destination,
        originLat: originCoords['latitude']?.toString(),
        originLng: originCoords['longitude']?.toString(),
        destinationLat: destinationCoords['latitude']?.toString(),
        destinationLng: destinationCoords['longitude']?.toString(),
      );

    if (response != null) {
        try {
          final String formattedPrice = response['formattedPrice'] ?? "Precio no disponible";
          final String formattedKm = response['distanceKm']?.toString() ?? "0.0";
          final String formattedDuration = response['timeMin']?.toString() ?? "0";
          final String typeOfMove = _selectedMovingType ?? "Tipo no disponible";
          final String estimatedTime = response['timeMin']?.toString() ?? "Tiempo no disponible";
          final List<Map<String, double>> route = List<Map<String, double>>.from(response['route'] ?? []);

          print("Redirigiendo a HomeUser con precio: $formattedPrice");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeUser(
                calculatedPrice: formattedPrice,
                distanceKm: formattedKm,
                duration: formattedDuration,
                typeOfMove: typeOfMove,
                estimatedTime: estimatedTime,
                route: route, 
              ),
            ),
          ); 
        } catch (e) {
          print("Error al decodificar la respuesta: $e");
        }
      } else {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

Widget _buildSuggestionList() {
    return _suggestions.isEmpty
        ? const SizedBox() // No muestra nada si no hay sugerencias
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
                return Column(
                  children: [
                    ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () {
                        setState(() {
                          _destinationAddressController.text = _suggestions[index];
                          _suggestions = []; // Oculta las sugerencias después de la selección
                        });
                      },
                    ),
                    if (index < _suggestions.length - 1) // No añadir Divider después del último elemento
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                  ],
                );
              },
            ),
          );
  }
  
  @override
  void dispose() {
    _numberOfRoomsController.dispose();
    _originAddressController.dispose();
    _destinationAddressController.dispose();

    super.dispose();
  }
}
