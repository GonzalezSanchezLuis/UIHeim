import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/widget/button/button.dart';
import 'package:holi/src/widget/settings/setting_option.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para manejar archivos locales

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Mi perfil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Encabezado con foto de perfil, texto y flecha
              GestureDetector(
                onTap: _pickImage,
                child: Row(
                  children: [
                    // Foto de perfil circular
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Texto "Cambiar foto de perfil"
                    const Expanded(
                      child: Text(
                        "Cambiar foto de perfil",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Icono de flecha hacia la derecha
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Card superior (Nombre y Apellido)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Nombre(s)",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Apellido(s)",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tarjetas adicionales con campos (texto a la izquierda e input a la derecha)
              _buildFieldCard("Número de documento", "Ingresa tu número"),
              _buildFieldCard("Teléfono", "Ingresa tu teléfono"),
              _buildFieldCard("Correo electrónico", "Ingresa tu correo"),
              _buildFieldCard("Contraseña", "Ingresa tu contraseña"),

              SettingOption(
                title: "Eliminar cuenta",
                onTap: () => {
                  // Eliminar cuenta
                  print("Cuenta eliminada")
                },
              ),

              const SizedBox(
                height: 20,
              ),
              const Button(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método reutilizable para crear las tarjetas de campos
  Widget _buildFieldCard(String label, String hintText) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
