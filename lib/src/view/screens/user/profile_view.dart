import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';
import 'package:holi/src/view/widget/image/image_picker_widget.dart';
import 'package:holi/src/view/widget/password_field/password_field.dart';
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
     final  documentController = TextEditingController();
     final phoneController = TextEditingController();
     final  emailController = TextEditingController();
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
          title: const Text( "Mi cuenta",style:  StyleFontsTitle.titleStyle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white, size: 20.w,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ProfileUserViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.black,));
            }

           /* final profile = viewModel.profile;
            final nameController = TextEditingController(text: profile.fullName);
            final documentController = TextEditingController(text: profile.document);
            final phoneController = TextEditingController(text: profile.phone);
            final emailController = TextEditingController(text: profile.email); */

            return SingleChildScrollView(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 16.w),
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
                        margin:  EdgeInsets.symmetric(vertical: 16.h),
                        child: Padding(
                          padding:  EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController, validator: (value) => value == null || value.isEmpty
                                    ? 'El nombre es obligatorio'
                                    : null,
                                decoration: InputDecoration(
                                  labelText: "Nombre(s)",
                                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 14.sp),
                                  border: const UnderlineInputBorder(),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: 2)
                                  )
                                ),   
                                                            
                              ),
                              
                               SizedBox(height: 10.h),
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

                       SizedBox(height: 10.h),

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

                       SizedBox(height: 20.h),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding:  EdgeInsets.symmetric(vertical: 16.h),
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
                        child:  Text(
                          "Eliminar cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
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

  Widget _buildFieldCard(String label, String hintText, TextEditingController controller, {bool readOnlyCondition = false, bool isRequired = false, bool obscure = false}) {
    return Card(
      color: AppTheme.colorcards,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      elevation: 2,
      margin:  EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding:  EdgeInsets.all(16.w),
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  contentPadding:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                readOnly: readOnlyCondition && controller.text.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }


  


