import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/move/request_vehicle.dart';
import 'package:holi/src/view/move/schedule_move.dart';




class ButtonRequestVehicle extends StatelessWidget {
  const ButtonRequestVehicle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestVehicle()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Solicitar vehículo",
        style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
      ),
    );
  }

  
}

class ScheduleMoveWidget extends StatelessWidget {
  const ScheduleMoveWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleMove()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Programar mudanza",
        style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
      ),
    );
  }

  
}


class DisconnectButton extends StatelessWidget {
  const DisconnectButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
        backgroundColor: AppTheme.colorButtonHomeDriver,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Desconectarme",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }


}

class ButtonLogOut extends StatelessWidget {
  const ButtonLogOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
        backgroundColor: AppTheme.colorButtonHomeDriver,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Cerrar sesión",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class ButtonConnect extends StatelessWidget {
  const ButtonConnect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
        backgroundColor: AppTheme.colorButtonConnect,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Conectarme",
        style: TextStyle(color: Colors.white, fontSize: 20,),
      ),
    );
  }
}


