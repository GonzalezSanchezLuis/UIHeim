import 'package:flutter/material.dart';

class buttonRequestVehicle extends StatelessWidget {
  const buttonRequestVehicle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Solicitar vehículo",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  
}

class scheduleMove extends StatelessWidget {
  const scheduleMove({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Programar mudanza",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  
}
