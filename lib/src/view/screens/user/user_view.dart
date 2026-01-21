import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/join_driver_view.dart';
import 'package:holi/src/view/screens/user/configuration_user_view.dart';
import 'package:holi/src/view/widget/card/account_card_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:provider/provider.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileUserViewModel>().fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileUserViewModel = context.watch<ProfileUserViewModel>();

    if (profileUserViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        ),
      );
    }

      final imageUrl = profileUserViewModel.profile.urlAvatarProfile;
      final fullName = profileUserViewModel.profile.fullName ?? 'Nombre no disponible';

    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      body: profileUserViewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : Center(
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
                           child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey,
                            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                            child: (imageUrl == null || imageUrl.isEmpty) ? const Icon(Icons.person, size: 35, color: Colors.white) : null,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                             fullName,
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
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const MovingSummaryView(origin: 'origin', destination: 'destination', distance: 'distance', duration: 'duration', paymentMethod: 'paymentMethod', amount: 45.00, paymentCompleted: true)))
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigurationUser()))
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
                    onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinDriver()))},
                  ),
                ],
              ),
            ),
    );
  }
}
