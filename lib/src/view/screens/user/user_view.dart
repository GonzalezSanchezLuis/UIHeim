import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/user/profile_user_service.dart';
import 'package:holi/src/view/screens/driver/moving_summary_view.dart';
import 'package:holi/src/view/screens/user/configuration_user_view.dart';
import 'package:holi/src/view/screens/driver/join_driver_view.dart';
import 'package:holi/src/view/widget/card/account_card_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  String name = "";
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final profileService = ProfileUserService();
    final userData = await profileService.fetchUserData();

    if (userData != null) {
      print("Datos del usuario: $userData");
      setState(() {
        name = userData['fullName'] ?? 'Nombre no disponible';
        avatarUrl = userData['urlAvatarProfile'];
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
              icon: const Icon(
                Icons.settings,
                size: 30,
              ),
              onTap: () => {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const MovingSummaryView(origin: 'origin', destination: 'destination', distance: 'distance', duration: 'duration', paymentMethod: 'paymentMethod', amount: 45.00, paymentCompleted: true)))
               // Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationUser()))
                },
            ),
            AccountCard(
              title: "Otros",
              subtitle: "Realiza mudanzas con Heim",
              width: 450,
              height: 130,
              icon: const Icon(
                FontAwesomeIcons.truckFront,
                size: 20,
              ),
              onTap: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinDriver()))
                },
            ),
          ],
        ),
      ),
    );
  }
}
