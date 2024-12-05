import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/configuration/configuration_user.dart';
import 'package:holi/src/view/driver/join_driver.dart';
import 'package:holi/src/widget/card/account_card.dart';

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
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
            const Row(children: [
              CircleAvatar(
                radius: 35.0,
                backgroundImage: AssetImage("assets/images/profile.jpg"),
              ),
               SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "John Doe", // Reemplaza con el nombre real
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                   SizedBox(height: 2.0),
                    Text(
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
