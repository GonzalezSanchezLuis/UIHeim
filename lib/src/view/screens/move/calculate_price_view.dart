import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/view/widget/validate_form/validated_text_form_field.dart';
import 'package:holi/src/viewmodels/move/calculate_price_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holi/src/core/analytics/analytics_mixin.dart';

class CalculatePrice extends StatefulWidget {
  const CalculatePrice({super.key});

  @override
  _CalculatePriceState createState() => _CalculatePriceState();
}

class _CalculatePriceState extends State<CalculatePrice> with AnalyticsMixin {
  final TextEditingController _originAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  bool _isCalculating = false;

  MoveType? _selectedMovingType;
  List<Prediction> _suggestions = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final locationService = LocationService(googleApiKey: "AIzaSyDF6pFogbufSdpW3nIeCgQMRFyoSEd1Rmw");
  final LocationViewModel locationViewModel = LocationViewModel();

  Map<String, double>? _destinationCoords;

  @override
  void initState() {
    super.initState();
    // El seguimiento de la pantalla se gestiona en HomeUserView para evitar registros prematuros.
  }

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
        elevation: 0,
        title: Text("Que moveremos hoy?", style: StyleFontsTitle.titleStyle),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _suggestions = [];
            });
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMovingTypeSelector(),
                  SizedBox(height: 25.h),
                  _buildAddressSection(locationViewModel),
                  SizedBox(height: 35.h),
                  _buildSubmitButton(locationViewModel),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 50.h : 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Encuentra un vehículo para tu mercancía en minutos, conoce el precio antes de solicitar el servicio y evita perder tiempo buscando un transportista.",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        SizedBox(height: 20.h),
        Text(
          "Detalles de envio",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            _buildUnifiedSmallCard(
              label: "Express",
              desc: "Cajas/Paquetes",
              icon: Icons.local_post_office_outlined,
              value: MoveType.XPRESS,
              groupValue: _selectedMovingType,
              onTap: (val) => setState(() => _selectedMovingType = val),
            ),
            SizedBox(width: 10.w),
            _buildUnifiedSmallCard(
              label: "Mediana",
              desc: "Bultos/Muebles",
              icon: Icons.inventory_2_outlined,
              value: MoveType.MEDIANA,
              groupValue: _selectedMovingType,
              onTap: (val) => setState(() => _selectedMovingType = val),
            ),
            SizedBox(width: 10.w),
            _buildUnifiedSmallCard(
              label: "Grande",
              desc: "Estibas/Carga",
              icon: Icons.local_shipping_outlined,
              value: MoveType.GRANDE,
              groupValue: _selectedMovingType,
              onTap: (val) => setState(() => _selectedMovingType = val),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildUnifiedSmallCard({
    required String label,
    required String desc,
    required IconData icon,
    required dynamic value,
    required dynamic groupValue,
    required Function(dynamic) onTap,
  }) {
    bool isSelected = groupValue == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.black54,
                    size: 14.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(LocationViewModel locationViewModel) {
    return Column(
      children: [
        ValidatedTextFormField(
          controller: _originAddressController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          label: "Punto de partida",
          suffixIcon: IconButton(
            icon: Icon(Icons.my_location, size: 20.w, color: AppTheme.primarycolor),
            onPressed: () async {
              await locationViewModel.updateLocation(context);
              _originAddressController.text = locationViewModel.currentAddress;
            },
          ),
        ),
        SizedBox(height: 15.h),
        ValidatedTextFormField(
          controller: _destinationAddressController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          label: "¿A dónde vamos?",
          onChanged: _updateSuggestions,
        ),
        _buildSuggestionList(),
      ],
    );
  }

  Widget _buildSubmitButton(LocationViewModel locationViewModel) {
    return Consumer<CalculatePriceViewmodel>(
      builder: (context, viewmodel, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onPressed: (_selectedMovingType == null)
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    trackEvent(
                      'calculate_price_requested',
                      params: {
                        'move_type': _selectedMovingType.toString().split('.').last, 
                        'origin_address': _originAddressController.text.trim(),
                        'destination_address': _destinationAddressController.text.trim(),
                      },
                    );
                    await viewmodel.handleRequestVehicle(
                      context: context,
                      typeOfMove: _selectedMovingType,
                      numberOfRooms: _selectedMovingType == MoveType.XPRESS ? "1" : "3",
                      originAddress: _originAddressController.text.trim(),
                      destinationAddress: _destinationAddressController.text.trim(),
                      locationService: locationService,
                      locationViewModel: locationViewModel,
                    );
                  }
                },
          child: viewmodel.isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text("Calcular precio", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        );
      },
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
                          _suggestions = [];
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
}
