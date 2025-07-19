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
  String? avatarUrl;

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
        avatarUrl = driverData['urlAvatarProfile'] ?? 'Nombre no disponible';

      });
    } else {
      setState(() {
        name = 'Nombre no disponible'; 
        avatarUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
         backgroundColor: AppTheme.primarycolor,
        title: const Text(
          "Mi cuenta",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 60,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(avatarUrl!),
                          )
                        : const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 35, color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      const Text(
                        "¡Hola!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
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
