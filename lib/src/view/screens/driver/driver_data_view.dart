import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:provider/provider.dart';

class DriverDataView extends StatefulWidget {
  final int driverId;

  const DriverDataView({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverDataView> createState() => _DriverDataViewState();
}

class _DriverDataViewState extends State<DriverDataView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverDataViewmodel>(context, listen: false).loadDriverData(widget.driverId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          title: const Text("Perfil del Conductor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<DriverDataViewmodel>(builder: (context, viewmodel, child) {
          if (viewmodel.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }
          if (viewmodel.errorMessage != null) {
            return Center(
              child: Text("Error ${viewmodel.errorMessage}"),
            );
          }
          if (viewmodel.driverDataModel == null) {
            return const Center(child: Text("No se encontraron datos del conductor."));
          }
          final profile = viewmodel.driverDataModel!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contenedor principal del perfil
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primarycolor,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(profile.urlAvatar),
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                           profile.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                           profile.phone,
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          // Calificación y viajes
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 5),
                              /*  Text(
                                 profile. rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                                ), */
                                const SizedBox(width: 10),
                              /*  Text(
                                  '($tripCount viajes)',
                                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                                ),*/
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Sección de verificaciones de seguridad
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Verificaciones de seguridad",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  // Lista de verificaciones con un diseño más limpio
                /*  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: securityChecks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.verified_user, color: Colors.green),
                        title: Text(
                          securityChecks[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),*/
                ],
              ),
            ),
          );
        }));
  }
}
