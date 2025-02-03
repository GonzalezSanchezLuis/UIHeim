import 'package:flutter/material.dart';
import 'package:holi/src/view/account/login.dart';
import 'package:holi/src/view/move/history_move.dart';
import 'package:holi/src/view/user/user.dart';
import 'package:holi/src/widget/button/button_card_home.dart';
import 'package:holi/src/widget/maps/google_maps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkSSession();
    // _checkTokenValidity();
  }
/*
  Future<void> _checkTokenValidity() async {
    final authController = AuthController();
    bool isValidToken = await authController.isTokenValid();

    if(!isValidToken){
         Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }
  } */

  Future<void> _checkSSession() async {
    bool isLoggedIn = await _isLoggedIn();
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    return userId != null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Perfil',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          // Página inicial con el mapa
          Stack(
            children: [
              const GoogleMapsWidget(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        ButtonRequestVehicle(),
                        SizedBox(height: 20),
                        ScheduleMoveWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Página de historial
          const HistoryMove(),

          // Página de perfil de usuario
          const User(),
        ],
      ),
    );
  }
}
