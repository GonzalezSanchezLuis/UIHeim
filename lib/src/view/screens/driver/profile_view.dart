import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_welcome.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';
import 'package:holi/src/view/widget/image/image_picker_widget.dart';
import 'package:holi/src/view/widget/password_field/password_field.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileUserViewModel viewModel;
  bool _isInitialized = false;

  final nameController = TextEditingController();
  final documentController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(text: '••••••••••••');

  @override
  void initState() {
    super.initState();
    viewModel = ProfileUserViewModel();

    viewModel.fetchUserData().then((_) {
      if (mounted) {
        final profile = viewModel.profile;
        nameController.text = profile.fullName ?? '';
        documentController.text = profile.document ?? '';
        phoneController.text = profile.phone ?? '';
        emailController.text = profile.email ?? '';
      }
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    documentController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
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
          title: Text("Mi cuenta", style: StyleFontsTitle.titleStyle),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
              size: 20.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ProfileUserViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 25.h),
                      ImagePickerWidget(
                        selectedImage: viewModel.selectedImage,
                        imageUrl: viewModel.profile.urlAvatarProfile,
                        onImageSelected: (imageFile) {
                          viewModel.onImageSelected(imageFile);
                        },
                      ),
                      SizedBox(height: 24.h),
                      Card(
                        color: AppTheme.colorcards,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 16.h),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
                                  if (value.trim().split(' ').length < 2) return 'Ingresa nombre y apellido';
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: "Nombre(s)", labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14.sp), border: const UnderlineInputBorder(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2))),
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                      _buildFieldCard("Número de documento", "Ingresa tu número", documentController, readOnlyCondition: true, isRequired: true),
                      _buildFieldCard(
                        "Teléfono",
                        "Ingresa tu teléfono",
                        phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Obligatorio';
                          if (!RegExp(r'^3[0-9]{9}$').hasMatch(value)) return 'Número celular incorrecto';
                          return null;
                        },
                      ),
                      _buildFieldCard("Correo electrónico", "Ingresa tu correo", emailController, isRequired: true, keyboardType: TextInputType.emailAddress, validator: (value) {
                        if (value == null || value.isEmpty) return 'Obligatorio';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) return 'Correo no válido';
                        return null;
                      }),
                      PasswordFieldCard(
                        label: "Actualizar contraseña",
                        hintText: "Nueva contraseña",
                        controller: passwordController,
                        isRequired: true,
                      ),
                      SizedBox(height: 10.h),
                      ButtonUpdateData(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await viewModel.updateProfile(
                              fullName: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              document: documentController.text.trim(),
                              password: passwordController.text == '••••••••••••' ? null : passwordController.text,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 40.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05), // Fondo muy tenue para alertar
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  "Zona de Peligro",
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Al eliminar tu cuenta, perderás todo tu historial de viajes y datos registrados. Esta acción no se puede deshacer.",
                              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                minimumSize: Size(double.infinity, 45.h), // Ancho completo adaptable
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onPressed: () async {
                                // Tip de experto: Aquí deberías mostrar un Dialog de confirmación
                                _confirmDeleteAccount(context, viewModel);
                              },
                              child: Text(
                                "Eliminar mi cuenta permanentemente",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /* ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        onPressed: () async {
                          await viewModel.deleteAccount(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeView()),
                          );
                        },
                        child: Text(
                          "Eliminar cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ), */

                      SizedBox(height: 30.h),
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

void _confirmDeleteAccount(BuildContext context, ProfileUserViewModel viewModel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("¿Estás seguro?"),
      content: const Text("Esta acción eliminará todos tus datos de Heim de forma permanente."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Cerrar diálogo
            await viewModel.deleteAccount(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeView()),
            );
          },
          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Widget _buildFieldCard(String label, String hintText, TextEditingController controller, {bool readOnlyCondition = false, String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, bool isRequired = false, bool obscure = false}) {
  return Card(
    color: AppTheme.colorcards,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
    ),
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 8.h),
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              style: TextStyle(fontSize: 13.sp),
              validator: validator ??
                  (isRequired
                      ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        }
                      : null),
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black87, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black87, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
              readOnly: readOnlyCondition && controller.text.isNotEmpty,
            ),
          ),
        ],
      ),
    ),
  );
}


/*class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileDriverViewModel viewModelDriver;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    viewModelDriver = ProfileDriverViewModel();
    viewModelDriver.fetchDriverData().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

     if (!_isInitialized) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          strokeWidth: 4,
          color: Colors.black,
        )),
      );
    }

    return ChangeNotifierProvider.value(
      value: viewModelDriver,
        child: Scaffold(
            backgroundColor: AppTheme.colorbackgroundview,
            appBar: AppBar(
              backgroundColor: AppTheme.primarycolor,
              title:  Text(
                "Mi Perfil",
                style: StyleFontsTitle.titleStyle,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Consumer<ProfileDriverViewModel>(builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.black,));
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
                    child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                         ImagePickerWidget(
                            selectedImage: viewModel.selectedImage,
                            imageUrl: viewModel.profile.urlAvatarProfile,
                            onImageSelected: (imageFile) {
                              Provider.of<ProfileDriverViewModel>(context, listen: false).onImageSelected(imageFile);
                            },
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
                                  TextFormField(
                                    controller: nameController,
                                    validator: (value) => value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
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
                          _buildFieldCard("Número de documento", "Ingresa tu número", documentController, readOnlyCondition: true,isRequired: true),
                          _buildFieldCard("Teléfono", "Ingresa tu teléfono", phoneController,isRequired: true),
                          _buildFieldCard("Correo electrónico", "Ingresa tu correo", emailController),
                          _buildPasswordField("Actualizar contraseña", "Ingresa tu contraseña", passwordController),
                          const SizedBox(height: 20.0),
                          ButtonUpdateData(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                  await Provider.of<ProfileDriverViewModel>(context, listen: false).updateProfile(
                                    fullName: nameController.text, 
                                    email: emailController.text, 
                                    phone: phoneController.text, 
                                    document: documentController.text.trim(),
                                     password: passwordController.text == '••••••••••••' ? null : passwordController.text,
                                );
                              }
                              
                            },
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
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
                          const SizedBox(height: 50),
                        ],
                      ),
                    )
                  
                ),
              );
            })));
  }
}

Widget _buildFieldCard(String label, String hintText, TextEditingController controller, {bool readOnlyCondition = false, bool isRequired = false, bool obscure = false}) {
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

Widget _buildPasswordField(String label, String hintText, TextEditingController controller) {
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
} */
