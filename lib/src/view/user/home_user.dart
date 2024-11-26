import 'package:flutter/material.dart';
import 'package:holi/src/view/user/history_move.dart';
import 'package:holi/src/view/user/user.dart';
import 'package:holi/src/widget/button/button_card_home.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int currentPageIndex = 0;

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
      body: Stack(
        children: [
          // Contenido principal
          Padding(
            padding: EdgeInsets.only(
              bottom: currentPageIndex == 0
                  ? MediaQuery.of(context).size.height * 0.22
                  : 0, // Espacio solo para la vista principal
            ),
            child: IndexedStack(
              index: currentPageIndex,
              children: const [
                // Página principal
                Center(
                  child: Text(
                    'Página de Inicio',
                    style: TextStyle(fontSize: 20),
                  ),
                ),

                // Página de historial
                HistoryMove(),
                User(),
              ],
            ),
          ),

          // Card fijo solo en la vista principal
          if (currentPageIndex == 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height *
                    0.22, // Altura relativa
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
                      buttonRequestVehicle(),
                      SizedBox(height: 20),
                      scheduleMove(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
