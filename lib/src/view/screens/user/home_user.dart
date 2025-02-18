import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/login._service.dart';
import 'package:holi/src/view/screens/move/history_move.dart';
import 'package:holi/src/view/screens/user/user.dart';
import 'package:holi/src/view/widget/button/button_card_home.dart';
import 'package:holi/src/view/widget/maps/google_maps.dart';
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
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (!await _isLoggedIn()) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  @override
  Widget build(BuildContext context) {
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
          _buildHomePage(context),
          const HistoryMove(),
          const User(),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerHeight = constraints.maxHeight * 0.22;
        return Stack(
          children: [
            const GoogleMapsWidget(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: containerHeight,
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
        );
      },
    );
  }
}
