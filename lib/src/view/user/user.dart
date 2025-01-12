import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/utils/controllers/user/profile_controller.dart';
import 'package:holi/src/view/configuration/configuration_user.dart';
import 'package:holi/src/view/driver/join_driver.dart';
import 'package:holi/src/widget/card/account_card.dart';

class User extends StatefulWidget {
  const User({super.key});


  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  String name = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final profileController = ProfileController();
    final userData = await profileController.fetchUserData();

    if (userData != null) {
      print("Datos del usuario: $userData");
      setState(() {
        name = userData['fullName'] ??
            'Nombre no disponible';
      });
    } else {
      setState(() {
        name =
            'Nombre no disponible'; // Si no se encuentran datos, mostramos un valor por defecto
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 150,
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
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigurationUser()))
              },
            ),
            AccountCard(
              title: "Otros",
              subtitle: "Realiza mudanzas con Holi",
              width: 450,
              height: 130,
              icon: const Icon(Icons.fire_truck),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const JoinDriver()))
              },
            ),
          ],
        ),
      ),
    );
  }
}
