import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/welcome/logo.dart';
import 'package:holi/src/widget/button/button.dart';
import 'package:holi/src/widget/settings/setting_option.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para manejar archivos locales
import 'package:holi/src/utils/controllers/user/profile_controller.dart'; // Importa el controlador

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();

}


class _ProfileState extends State<Profile> {
  File? _profileImage;

  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  final profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await profileController.fetchUserData();

    if (userData != null) {
      print("Datos del usuario $userData");
      setState(() {
        nameController.text = userData['fullName'] ?? '';
        documentController.text = userData['document'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        emailController.text = userData['email'] ?? '';
        passwordController.text = ''; // Dejar vacío por seguridad
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    final fullName = nameController.text;
    final email = emailController.text;
    final phone = phoneController.text;
    final password = passwordController.text;

    final response = await profileController.updateDataUser(
      fullName,
      email,
      phone,
      password,
    );

    setState(() {
      isLoading = false;
    });

    if (response != null && response['status'] == 'success') {
      // Si la respuesta es exitosa, mostrar un mensaje de éxito
      await _fetchUserData();

       profileController.updateUserData({
        'fullName': fullName,
        'email': email,
        'phone': phone,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado exitosamente")),);

    } else {
      // Si la respuesta tiene algún error, mostrar el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar el perfil")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Mi cuenta",style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Row(
                        children: [
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
                          const Expanded(
                            child: Text(
                              "Cambiar foto de perfil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre(s)",labelStyle: TextStyle(fontWeight: FontWeight.w600),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    _buildFieldCard("Número de documento", "Ingresa tu número",
                        documentController),
                    _buildFieldCard(
                        "Teléfono", "Ingresa tu teléfono", phoneController),
                    _buildFieldCard("Correo electrónico", "Ingresa tu correo",
                        emailController),
                    _buildFieldCard("Contraseña", "Ingresa tu contraseña",
                        passwordController),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),   
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                           backgroundColor:
                                Colors.red[600], // Color rojo para el botón
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Bordes redondeados
                            ),
                            
                        ),
                        onPressed: () async {
                          await profileController
                              .deleteAccount(context)
                              .then((_) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WelcomeView()));
                          });
                        },
                        child: const Text("Eliminar cuenta",
                        style: TextStyle(
                            color:
                                Colors.white, // Texto en blanco para contraste
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonUpdateData(onPressed: _updateProfile),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFieldCard(
      String label, String hintText, TextEditingController controller) {
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
                style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
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
