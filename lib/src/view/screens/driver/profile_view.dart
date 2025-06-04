import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';
import 'package:holi/src/view/widget/image/image_picker_widget.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ProfileViewModel()..fetchDriverData(),
        child: Scaffold(
          backgroundColor: AppTheme.colorbackgroundview,
          appBar: AppBar(
            title: const Text("Mi cuenta",style: TextStyle(fontWeight: FontWeight.bold),),
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
          ),
          body: Consumer<ProfileViewModel>(builder: (context, viewModel, child){
            if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
            }
                  final profile = viewModel.profile;
                  final nameController = TextEditingController(text: profile.fullName);
                  final documentController = TextEditingController(text: profile.document);
                  final phoneController = TextEditingController(text: profile.phone);
                  final emailController = TextEditingController(text: profile.email);
                  final passwordController = TextEditingController(text: '••••••••••••');


              return SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    ImagePickerWidget(onImageSelected: (imageFile) {
                      Provider.of<ProfileViewModel>(context, listen: false).onImageSelected(imageFile);
                    }),
                    const SizedBox(height: 24),
                    Card(color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),
                      ),
                      
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre(s)",
                                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    _buildFieldCard("Número de documento", "Ingresa tu número", documentController,readOnlyCondition: true),
                    _buildFieldCard("Teléfono", "Ingresa tu teléfono", phoneController),
                    _buildFieldCard("Correo electrónico", "Ingresa tu correo", emailController),
                    _buildPasswordField("Actualizar contraseña", "Ingresa tu contraseña", passwordController),

                    const SizedBox(height: 20.0),
                    const Center(child: Text("Información del vehículo",style: TextStyle(fontSize: 18),),),
                    const SizedBox(height: 20.0),


                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await viewModel.deleteAccount(context).then((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeView()),
                            );
                          });
                        },
                        child: const Text(
                          "Eliminar cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonUpdateData(
                      onPressed: () async {
                        await Provider.of<ProfileViewModel>(context, listen: false).updateProfile(
                            fullName: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            document: documentController.text.trim());

                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          })

        ));
  }
  }

  Widget _buildFieldCard(String label, String hintText, TextEditingController controller,
      {bool readOnlyCondition = false}) {
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                readOnly: readOnlyCondition && controller.text.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87, width: 2.0),
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

