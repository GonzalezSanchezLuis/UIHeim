import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';
import 'package:holi/src/view/widget/image/image_picker_widget.dart';
import 'package:holi/src/view/widget/password_field/password_field.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileUserViewModel viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    viewModel = ProfileUserViewModel();
    viewModel.fetchUserData().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
          strokeWidth: 4,
          color: Colors.black,
        )),
      );
    }
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          backgroundColor: AppTheme.primarycolor,
          title: const Text(
            "Mi cuenta",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ProfileUserViewModel>(
          builder: (context, viewModel, child) {
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      ImagePickerWidget(
                        selectedImage: viewModel.selectedImage,
                        imageUrl: viewModel.profile.urlAvatarProfile,
                        onImageSelected: (imageFile) {
                          viewModel.onImageSelected(imageFile);
                        },
                      ),

                      const SizedBox(height: 24),
                      Card(
                        color: AppTheme.colorcards,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'El nombre es obligatorio'
                                    : null,
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
                      _buildFieldCard("Número de documento", "Ingresa tu número",
                          documentController,
                          readOnlyCondition: true, isRequired: true),
                      _buildFieldCard("Teléfono", "Ingresa tu teléfono", phoneController,
                          isRequired: true),
                      _buildFieldCard("Correo electrónico", "Ingresa tu correo",
                          emailController,
                          isRequired: true),
                      PasswordFieldCard(
                        label: "Actualizar contraseña",
                        hintText: "Ingresa tu contraseña",
                        controller: passwordController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      ButtonUpdateData(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await viewModel.updateProfile(
                              fullName: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              document: documentController.text.trim(),
                              password: passwordController.text == '••••••••••••'
                                  ? null
                                  : passwordController.text,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          await viewModel.deleteAccount(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeView()),
                          );
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

  Widget _buildFieldCard(String label, String hintText, TextEditingController controller, {bool readOnlyCondition = false, bool isRequired = false, bool obscure = false}) {
    return Card(
      color: AppTheme.colorcards,
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
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                validator: isRequired
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      }
                    : null,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
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


  


