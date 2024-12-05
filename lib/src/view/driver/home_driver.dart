import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/widget/button/button_card_home.dart';
import 'package:holi/src/widget/google_maps_widget.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({Key? key}) : super(key: key);

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  bool _showConnectCard = true; // Controla qué tarjeta se muestra

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMapsWidget(),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
            onTap: (){

            },
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage("assets/images/profile.jpg"),

            ),
          ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _showConnectCard
                  ? MediaQuery.of(context).size.height * 0.12
                  : MediaQuery.of(context).size.height * 0.20, // Altura ajustada
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
                child: _showConnectCard
                    ? _buildConnectCard()
                    : _buildExpandedCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construir la tarjeta con el botón "Conectarme"
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
          child: const ButtonConnect(),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape:  BoxShape.circle
          ),
          child: IconButton(
            onPressed: () {
              // Cambia a la tarjeta expandida
              setState(() {
                _showConnectCard = false;
              });
            },
            icon: const Icon(Icons.add, size: 30,color: Colors.black,),

          ),
        )
        ,
      ],
    );
  }

  // Construir la tarjeta expandida
  Widget _buildExpandedCard() {
    return Stack(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            DisconnectButton(),
            SizedBox(height: 10),
              ButtonLogOut(),
          ],
        ),
        // Botón cerrar en la esquina inferior derecha
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape:  BoxShape.circle
            ),
          child: IconButton(
            onPressed: () {
              // Regresa a la tarjeta original
              setState(() {
                _showConnectCard = true;
              });
            },
            icon: const Icon(Icons.close, size: 30, color: Colors.black87),
          ),
          )


        ),
      ],
    );
  }
}
