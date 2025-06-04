import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class SelectPaymentMethod extends StatefulWidget {
  final String initialMethod;
  const SelectPaymentMethod({super.key, required this.initialMethod});

  @override
  _SelectPaymentMethodState createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  String selectedMethod = 'Nequi';
 
@override
  void initState() {
    super.initState();
    selectedMethod = widget.initialMethod; // 🔸 Iniciamos con el método recibido
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.colorbackgroundview,
        title: const Text("Seleccionar un metodo de pago",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPaymentOption('Nequi', 'assets/images/nequi.png'),
            _buildPaymentOption('Daviplata', 'assets/images/daviplata.png'),
            _buildPaymentOption('Tarjeta crédito/débito', 'assets/images/cards.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String assetPath) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selectedMethod == title ? Colors.blue : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: selectedMethod,
        onChanged: (value) {
          setState(() {
            selectedMethod = value!;
          });
          Navigator.pop(context, value);
        },
        title: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 219, 203, 203),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Image.asset(assetPath, width: 30, height: 30),
              ],
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        activeColor: Colors.blue,
      ),
    );
  }
}
