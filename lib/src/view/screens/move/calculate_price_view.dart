import 'dart:developer';
import 'dart:ui' as ui;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/view/widget/validate_form/validate_dropdown_form_field.dart';
import 'package:holi/src/view/widget/validate_form/validated_text_form_field.dart';
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
  MoveType? _selectedMovingType;
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
        backgroundColor: AppTheme.primarycolor,
        title: const Text("A donde sera nuestro nuevo hogar?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
          children: [
            Positioned(
              top: _numberOfRoomsYOffset,
              left: 10,
              right: 10,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     ValidatedDropdownFormField(
                      value: _selectedMovingType,
                      label: "Tipo de mudanza",
                      items: const  ["Pequeña", "Mediana", "Grande"],
                        onChanged: (value) => setState(() => _selectedMovingType = value),
                      validator: (value) => value == null ? 'Selecciona un tipo de mudanza' : null,
                    ),
                    const SizedBox(height: 20),
                    ValidatedTextFormField(
                      controller: _numberOfRoomsController,
                      label: "Número de habitaciones",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ValidatedTextFormField(
                      controller: _originAddressController,
                      label: "Dirección de origen",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: locationViewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              )
                            : const Icon(Icons.location_searching_rounded),
                        onPressed: locationViewModel.isLoading
                            ? null
                            : () async {
                                final position = await locationViewModel.updateLocation(context);
                                if (position != null && context.mounted) {
                                  _originAddressController.text = locationViewModel.currentAddress;
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ValidatedTextFormField(
                      controller: _destinationAddressController,
                      label: "Dirección de destino",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _updateSuggestions(value);
                      },
                    ),

                    _buildSuggestionList(),
                    const SizedBox(height: 20),
                    Consumer<CalculatePriceViewmodel>(
                      builder: (context, viewmodel, _) {
                        return ElevatedButton(
                          onPressed: viewmodel.isLoading
                              ? null
                              : () async {
                                  final formValid = _formKey.currentState?.validate() ?? false;

                                  final allEmpity = _numberOfRoomsController.text.trim().isEmpty && _originAddressController.text.trim().isEmpty && _destinationAddressController.text.trim().isEmpty && _selectedMovingType == null;

                                  if (allEmpity) {
                                    Flushbar(
                                      title: "Importante",
                                      message: "Para brindarte un excelente servicio, completa todos los campos",
                                      duration: const Duration(seconds: 3),
                                      margin: const EdgeInsets.all(10),
                                      borderRadius: BorderRadius.circular(10),
                                      flushbarPosition: FlushbarPosition.TOP,
                                      animationDuration: const Duration(milliseconds: 500),
                                      backgroundColor: Colors.red.shade700,
                                    ).show(context);
                                    return;
                                  }

                                  if (!formValid) return;

                                  final confirmViewModel = Provider.of<ConfirmMoveViewModel>(context, listen: false);
                                  confirmViewModel.setAddresses(
                                    origin: _originAddressController.text.trim(),
                                    destination: _destinationAddressController.text.trim(),
                                  );

                                  await viewmodel.handleRequestVehicle(
                                    context: context,
                                    typeOfMove: _selectedMovingType,
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
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: viewmodel.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Continuar",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 16,
                      ),
                      title: Text(prediction.description),
                      horizontalTitleGap: -8.0,
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
