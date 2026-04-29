import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:holi/src/service/location/location_service.dart';
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
  final TextEditingController _originAddressController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  bool _isCalculating = false;

  MoveType? _selectedMovingType;
  List<Prediction> _suggestions = [];

 String? _selectedAccess;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final locationService = LocationService(googleApiKey: "AIzaSyDF6pFogbufSdpW3nIeCgQMRFyoSEd1Rmw");
  final LocationViewModel locationViewModel = LocationViewModel();

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
        elevation: 0,
        title: Text("A donde sera nuestro nuevo hogar? ", style: StyleFontsTitle.titleStyle),
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
                  SizedBox(height: 25.h),
                  if (_selectedMovingType != null) ...[
                    Text(
                      "Detalles de acceso",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 10.h),
                    _buildAccessOption(),
                  ],
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
          "Ajustamos los detalles para que el precio que veas sea el que pagues. Sin sorpresas al llegar.",
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            _buildSelectableCard(
              label: "Apartaestudio",
              desc: "1 Habitación",
              value: MoveType.PEQUENA,
              icon: Icons.home_outlined,
            ),
            SizedBox(width: 15.w),
            _buildSelectableCard(
              label: "Apartamento",
              desc: "2-3 Habitaciones",
              value: MoveType.MEDIANA,
              icon: Icons.apartment_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableCard({required String label, required String desc, required MoveType value, required IconData icon}) {
    bool isSelected = _selectedMovingType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMovingType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.secondarycolor: AppTheme.primarycolor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSelected ? AppTheme.primarycolor : Colors.grey.shade300, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: AppTheme.primarycolor.withOpacity(0.2), blurRadius: 10)] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey, size: 18.w),
              Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              Text(desc, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 11.sp)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessOption() {
    return Row(
      children: [
        _buildTinyCard(
            title: "Primer piso",
            value: "CALLE",
            isSelected: _selectedAccess == 'CALLE',
            icon: Icons.home_work_outlined),
             SizedBox(width: 5.w),
        _buildTinyCard(title: "Ascensor", value: "ASCENSOR", isSelected: _selectedAccess == "ASCENSOR", icon: Icons.elevator_outlined),
        SizedBox(width: 5.w),
        _buildTinyCard(title: "Escaleras", value: "ESCALERAS", isSelected: _selectedAccess == "ESCALERAS", icon: Icons.stairs_outlined),
      ],
    );
  }

  Widget _buildTinyCard({required String title, required IconData icon,required String value, required bool isSelected}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedAccess = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black54, size: 15.w),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12.sp, fontWeight: FontWeight.w500)),
            ],
          )
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
          onPressed: (_selectedMovingType == null || _selectedAccess == null)
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                
                    await viewmodel.handleRequestVehicle(
                      context: context,
                      typeOfMove: _selectedMovingType,
                      numberOfRooms: _selectedMovingType == MoveType.PEQUENA ? "1" : "3",
                      originAddress: _originAddressController.text.trim(),
                      destinationAddress: _destinationAddressController.text.trim(),
                      locationService: locationService,
                      locationViewModel: locationViewModel,
                      accessType:_selectedAccess
                    );
                  }
                },
          child: viewmodel.isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) : Text("Continuar", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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



