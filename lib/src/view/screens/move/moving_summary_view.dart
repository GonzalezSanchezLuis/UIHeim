import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/viewmodels/move/moving_summary_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MovingSummaryView extends StatefulWidget {
  final int moveId;
  const MovingSummaryView({super.key, required this.moveId});

  @override
  State<MovingSummaryView> createState() => _MovingSummaryViewState();
}

class _MovingSummaryViewState extends State<MovingSummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovingSummaryViewmodel>(context, listen: false).loadMovingSummary(widget.moveId);
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: Text(
          "Resumen",
          style: StyleFontsTitle.titleStyle,
        ),
    
        backgroundColor: Colors.black,
      ),
      body: Consumer<MovingSummaryViewmodel>(
        builder: (context, viewmodel, child) {
          if (viewmodel.isLoading) {
            return const Center(child: CircularProgressIndicator(color:Colors.black));
          } else if (viewmodel.errorMessage != null) {
            return Center(child: Text("Error: ${viewmodel.errorMessage}"));
          } else if (viewmodel.movingSummary != null) {
            final summary = viewmodel.movingSummary!;
            final String paymentMethod = summary.paymentMethod.toLowerCase();

            Widget _buildLocationSummary(IconData icon, String label, String address) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: AppTheme.primarycolor, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          Text(
                            address,
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

             /* Color _getPaymentColor() {
              final String paymentMethod = summary.paymentMethod.toLowerCase();
              if (paymentMethod.toLowerCase() == "nequi") {
                return const Color(0xFF7B1FA2); 
              } else if (paymentMethod.toLowerCase() == "daviplata") {
                return const Color(0xFFE53935); 
              }
              return Colors.orange; 
            }*/


            List<String> partsOrigin = summary.origin.split(',');
            String reducedOrigin = partsOrigin.take(2).join(',').trim();

            List<String> partsDestination = summary.destination.split(',');
            String reducedDestination = partsDestination.take(2).join(',').trim();         
            String formattedPrice = formatPriceMovingDetails(summary.amount.toString());

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      child: Padding(
                        padding:  EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Center(
                              child: Column(
                                 children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 22.sp),
                                  SizedBox(width: 12.h),
                                  Text(
                                    "¡Mudanza finalizada!",
                                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                                    ),
                                    Text("El servicio se completó con éxito", style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                                ],
                              ),
                             
                            ),
                           Divider(height: 40.h, thickness: 1),

                           // Text("Origen: $reducedOrigin", style:  TextStyle(fontSize: 14.sp)),
                            //Text("Destino: $reducedDestination", style:  TextStyle(fontSize: 14.sp)),
                            _buildLocationSummary(Icons.location_on_outlined, "ORIGEN", reducedOrigin),
                            _buildLocationSummary(Icons.flag_outlined, "DESTINO", reducedDestination),

                           SizedBox(height: 10.h),
                            Text(
                              "Distancia: ${summary.distanceKm} | Tiempo: ${summary.durationMin}",
                              style:  TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                              Divider(height: 30.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("Total a pagar:", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                Text(                               
                                  formattedPrice,
                                  style:  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                             SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Método de pago:", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                                Row(
                                children: [
                                Image.asset(
                                paymentMethod.toLowerCase() == "daviplata" ? 'assets/images/daviplata.png' : 'assets/images/nequi.png',
                                width: 35.w,
                                height: 35.h,
                                fit: BoxFit.contain,
                              ),
                                ],
                                )
                              ],
                            ),
                             SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                               decoration: BoxDecoration(
                                    color: summary.paymentCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(color: summary.paymentCompleted ? Colors.green : Colors.orange),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, 
                                    children: [
                                      Icon(summary.paymentCompleted ? Icons.check_circle : Icons.pending_actions, color: summary.paymentCompleted ? Colors.green : Colors.orange,size: 18.sp,),
                                       SizedBox(width: 8.h),
                                      Text(
                                        summary.paymentCompleted ? "Pago Completado" : "Pago en proceso",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: summary.paymentCompleted ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  )
                                
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:  EdgeInsets.all(20.w),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
                  child: SafeArea(
                    child:ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 55.h),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeDriverView()),
                            (route) => false,
                          );
                        },
                        child:  Text(
                          "Finalizar",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                    )
                  
               
                ),
              ],
            );
          } else {
            return  Center(
              child: Text("No se pudo cargar el resumen de la mudanza.",style: TextStyle(fontSize: 16.sp),),
            );
          }
        },
      ),
    );
  }
}
