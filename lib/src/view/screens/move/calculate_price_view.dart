import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/view/widget/validate_form/validate_dropdown_form_field.dart';
import 'package:holi/src/view/widget/validate_form/validated_text_form_field.dart';
import 'package:holi/src/viewmodels/move/calculate_price_viewmodel.dart';
import 'package:holi/src/viewmodels/move/confirm_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        title: Text("A donde sera nuestro nuevo hogar?", style: StyleFontsTitle.titleStyle),
      ),
      body: SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 35.w),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValidatedDropdownFormField(
                      value: _selectedMovingType,
                      label: "¿Qué tan grande es tu mudanza?",
                      items: const ["Pequeña 1 hab.", "Mediana 2-3 hab.", "Grande 4+ hab."],
                      onChanged: (value) => setState(() => _selectedMovingType = value),
                      validator: (value) => value == null ? 'Selecciona un tipo de mudanza' : null,
                    ),

                    SizedBox(height: 15.h),

                    ValidatedTextFormField(
                      controller: _numberOfRoomsController,
                      label: "Número de habitaciones",
                     // keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                     SizedBox(height: 15.h),

                    ValidatedTextFormField(
                      controller: _originAddressController,
                      label: "Dirección de origen",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: locationViewModel.isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              )
                            : Icon(Icons.location_searching_rounded, size: 22.w),
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
                    SizedBox(height: 15.w),

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
                    SizedBox(height: 15.w),

                    Consumer<CalculatePriceViewmodel>(
                      builder: (context, viewmodel, _) {
                        return ElevatedButton(
                          onPressed: viewmodel.isLoading ? null: () async {
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
                            minimumSize: Size(double.infinity, 50.h),
                            backgroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: viewmodel.isLoading
                              ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              :  Text(
                                  "Continuar",
                                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100.h : 20.h),
                  ],
                ),
              ),
            )

            /*  top: _numberOfRoomsYOffset,
              left: 10,
              right: 10, */

            ),
      ),
    );
  }

  Widget _buildSuggestionList() {
    return _suggestions.isEmpty
        ? const SizedBox()
        : Container(
            height: 150.h,
            margin: EdgeInsets.only(top: 5.h),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8.r), boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final prediction = _suggestions[index];

                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 18.w,
                      ),
                      title: Text(
                        prediction.description,
                        style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      horizontalTitleGap: 0,
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
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    if (index < _suggestions.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                        indent: 40.w,
                      ),
                  ],
                );
              },
            ),
          );
  }

  Widget _buildMovingTypeSelector() {
    return FormField<MoveType>(
      initialValue: _selectedMovingType,
      validator: (value) => value == null ? 'Por favor, selecciona un tipo de mudanza' : null,
      builder: (FormFieldState<MoveType> state) {
        final options = [
          {
            'label': 'Pequeña',
            'value': MoveType.PEQUENA, // <--- Tu valor de Enum
            'icon': Icons.inventory_2_outlined,
            'desc': '1-2 hab.'
          },
          {
            'label': 'Mediana',
            'value': MoveType.MEDIANA, // <--- Tu valor de Enum
            'icon': Icons.local_shipping_outlined,
            'desc': '3-4 hab.'
          },
          {
            'label': 'Grande',
            'value': MoveType.GRANDE, // <--- Tu valor de Enum
            'icon': Icons.local_shipping,
            'desc': '5+ hab.'
          },
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Qué tan grande es tu mudanza?",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: options.map((opt) {
                final MoveType val = opt['value'] as MoveType;
                bool isSelected = _selectedMovingType == val;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMovingType = val);
                    state.didChange(val); // <--- ESTO le avisa al Form que ya hay valor
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 100.w,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primarycolor : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? AppTheme.primarycolor : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: AppTheme.primarycolor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          opt['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 24.w,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          opt['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          opt['desc'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
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
