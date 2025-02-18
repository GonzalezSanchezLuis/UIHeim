import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/driver.dart';
import 'package:holi/src/view/widget/button/button_card_home.dart';
import 'package:holi/src/view/widget/maps/google_maps.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({super.key});

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  bool _showConnectCard = true;
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          _buildHomeScreen(),
          /*const HistoryMove(),
          const Driver(), */
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Stack(
      children: [
        const GoogleMapsWidget(),

        // Botón de perfil en la esquina superior izquierda
        Positioned(
          top: 50,
          left: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Driver()),
              );
            },
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage("assets/images/profile.jpg"),
            ),
          ),
        ),

        // Tarjeta inferior con botones
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: _showConnectCard ? MediaQuery.of(context).size.height * 0.12 : MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              color: AppTheme.colorbackgroundview,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _showConnectCard ? _buildConnectCard() : _buildExpandedCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            // Acción del botón "Conectarme"
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colorButtonConnect,
            minimumSize: const Size(150, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: ConnectButton(),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _showConnectCard = false;
              });
            },
            icon: const Icon(Icons.add, size: 30, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedCard() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const DisconnectButton(),
            const SizedBox(height: 10),
            ButtonLogOut(),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showConnectCard = true;
                });
              },
              icon: const Icon(Icons.close, size: 30, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
