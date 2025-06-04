import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/viewmodels/move/calculate_price_viewmodel.dart';
import 'package:holi/src/viewmodels/move/confirm_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';

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
  final locationService = LocationService(googleApiKey: "AIzaSyDB04XLcypB4xsGaRqNPjAGmf1xTegz0Rg");
  final LocationViewModel locationViewModel = LocationViewModel();

  // Variables de desplazamiento
  final double _numberOfRoomsYOffset = 100;
  final double _sourceAddressYOffset = 180;
  String? _selectedMovingType;
  List<Prediction> _suggestions = [];
  Map<String, double>? _destinationCoords;

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
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
                              icon: locationViewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
                                    )
                                  : const Icon(Icons.location_searching_rounded),
                              onPressed: locationViewModel.isLoading
                                  ? null
                                  : () async {
                                      //final hasConnection = await InternetConnectionChecker().hasConnection;

                                      final position = await locationViewModel.updateLocation(context);

                                      if (position != null && mounted) {
                                        _originAddressController.text = locationViewModel.currentAddress;
                                      }
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
                          )),
                      onChanged: (value) => {_updateSuggestions(value)},
                    ),
                    _buildSuggestionList(),
                    const SizedBox(height: 20),
                    Consumer<CalculatePriceViewmodel>(
                      builder: (context, viewmodel, _) {
                        return ElevatedButton(
                          onPressed: viewmodel.isLoading
                              ? null
                              : () async {
                                  final confirmViewModel = Provider.of<ConfirmMoveViewModel>(context, listen: false);
                                  confirmViewModel.setAddresses(
                                    origin: _originAddressController.text.trim(),
                                    destination: _destinationAddressController.text.trim(),
                                  );

                                  await viewmodel.handleRequestVehicle(
                                    context: context,
                                    typeOfMove: _selectedMovingType!,
                                    numberOfRooms: _numberOfRoomsController.text,
                                    originAddress: _originAddressController.text.trim(),
                                    destinationAddress: _destinationAddressController.text.trim(),
                                    locationService: locationService,
                                    locationViewModel: locationViewModel,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: ui.Size(MediaQuery.of(context).size.width * 0.9, 60),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: viewmodel.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Solicitar vehículo",
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                final prediction = _suggestions[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(prediction.description),
                      onTap: () async {
                        final coords = await locationService.getCoordinatesFromPlaceId(prediction.placeId);
                        if (coords != null) {
                          log('📍 Coordenadas del destino => Lat: ${coords['latitude']}, Lng: ${coords['longitude']}');
                        } else {
                          print('⚠️ No se pudieron obtener las coordenadas del destino');
                        }

                        setState(() {
                          _destinationAddressController.text = prediction.description;
                          _suggestions = []; // Oculta las sugerencias después de la selección
                        });
                      },
                    ),
                    if (index < _suggestions.length - 1)
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
