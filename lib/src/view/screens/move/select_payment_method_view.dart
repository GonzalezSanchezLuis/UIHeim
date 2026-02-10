import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';

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
    selectedMethod = widget.initialMethod; 
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text("Selecciona un metodo de pago",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(       
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           const  SizedBox(height: 20,),
            const Text(
              "Selecciona tu método  de pago favorito.",
              style:  StyleFontsTitle.titleStyle,
            ),
               const SizedBox( height: 10,),
            _buildPaymentOption('Nequi', 'assets/images/nequi.png'),
            _buildPaymentOption('Daviplata', 'assets/images/daviplata.png'),
          //  _buildPaymentOption('Tarjeta crédito/débito', 'assets/images/cards.png'),
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
          color: selectedMethod == title ? Colors.black : Colors.grey.shade300,
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
        activeColor: Colors.black,
      ),
    );
  }
}
