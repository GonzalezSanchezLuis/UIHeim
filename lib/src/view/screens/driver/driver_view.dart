import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/drivers/driver_profile_service.dart';
import 'package:holi/src/view/screens/driver/configuration_driver_view.dart';
import 'package:holi/src/view/widget/card/account_card_widget.dart';

class Driver extends StatefulWidget {
  const Driver({super.key});

  @override
  _DriverState createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  String name = "";

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    final profileService = DriverProfileService();
    final driverData = await profileService.fetchDriverData();

    if (driverData != null) {
      print("Datos del usuario: $driverData");
      setState(() {
        name = driverData['fullName'] ?? 'Nombre no disponible';
      });
    } else {
      setState(() {
        name = 'Nombre no disponible'; // Si no se encuentran datos, mostramos un valor por defecto
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
         backgroundColor: AppTheme.colorbackgroundview,
        title: const Text(
          "Mi cuenta",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 80,
            ),
            Row(children: [
              const CircleAvatar(
                radius: 35.0,
                backgroundImage: AssetImage("assets/images/profile.jpg"),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, // Reemplaza con el nombre real
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  const Text(
                    "¡Hola!", // Reemplaza con el texto deseado
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            ]),
            const SizedBox(height: 20),
            AccountCard(
              title: "Mi cuenta",
              subtitle: "Configuracion",
              width: 450,
              height: 130,
              icon: const Icon(Icons.settings),
              onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationDriver()))},
            ),
            /*AccountCard(
              title: "Otros",
              subtitle: "Realiza mudanzas con Holi",
              width: 450,
              height: 130,
              icon: const Icon(Icons.fire_truck),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const JoinDriver()))
              },
            ), */
          ],
        ),
      ),
    );
  }
}
