import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:holi/src/view/screens/welcome/introducction_view.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/support/support_view.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/widget/button/button_account_widget.dart';
import 'package:holi/src/viewmodels/auth/password_reset_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final passwordVM = Provider.of<PasswordResetViewmodel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _isLoading ? Colors.black : AppTheme.colorbackgroundview,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            if (!_isLoading) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.w),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                  height: isKeyboardOpen ? 100.h : 120.h,
                                  child: const SizedBox.shrink(),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: isKeyboardOpen ? 0.0 : 1.0,
                                  child: isKeyboardOpen
                                      ? const SizedBox.shrink()
                                      : Column(
                                          children: [
                                            Text(
                                              "Ingresar a mi cuenta de Heim",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 30.h),
                                          ],
                                        ),
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 15.sp),
                                  decoration: InputDecoration(
                                    labelText: "Ingresa tu correo electrónico",
                                    labelStyle: TextStyle(fontSize: 13.sp),
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(color: Colors.black, width: 2.0),
                                    ),
                                    floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // CAMPO: CONTRASEÑA
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: TextStyle(fontSize: 15.sp),
                                  decoration: InputDecoration(
                                    labelText: "Ingresa tu contraseña",
                                    labelStyle: TextStyle(fontSize: 13.sp),
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: const BorderSide(color: Colors.black, width: 2.0),
                                    ),
                                    floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    suffixIcon: IconButton(
                                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20.sp),
                                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 35.h),
                                ButtonAuth(formKey: _formKey, onPressed: _handleLogin),
                                const Spacer(flex: 3),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Support())),
                          child: Image.asset('assets/images/support.png', width: 28.w, height: 28.w),
                        ),
                        GestureDetector(
                          onTap: () => _showForgotPasswordModal(context), // El modal que adaptamos antes
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10.r))),
            SizedBox(height: 20.h),
            Text(
              'Recuperar contraseña',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: Colors.white),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ingresa tu correo',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 25.h),
            Consumer<PasswordResetViewmodel>(
              builder: (context, passwordVM, _) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: passwordVM.isLoading
                      ? null
                      : () async {
                          String email = emailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            _showFlushbar(context, "Por favor ingresa un correo válido", Colors.orange);
                            return;
                          }
                          await passwordVM.resetPassword(email);
                          if (passwordVM.successMessage != null) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showFlushbar(context, passwordVM.successMessage!, AppTheme.confirmationscolor);
                            }
                          } else if (passwordVM.errorMessage != null) {
                            _showFlushbar(context, passwordVM.errorMessage!, Colors.red);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: passwordVM.isLoading ? Colors.grey.shade700 : AppTheme.confirmationscolor,
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    elevation: passwordVM.isLoading ? 0 : 2,
                  ),
                  child: passwordVM.isLoading ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white)) : Text('Enviar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    if (email.isEmpty || password.isEmpty) {
      Flushbar(
        title: 'Error',
        message: 'Por favor, ingresa tu correo y contraseña',
        backgroundColor: AppTheme.warningcolor,
        icon: const Icon(
          Icons.error_outline,
          size: 28.0,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (mounted) setState(() => _isLoading = true);
      final response = await authViewModel.login(email, password);

      // if (mounted) setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('intro_view', true);
      final role = prefs.getString('role');

      log("ROL OBTENIDO: $role");

      if (role == "USER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUserView()));
      } else if (role == "DRIVER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      final error = authViewModel.errorMessage ?? "Correo o contraseña incorrectos.";

      Flushbar(
        title: 'Error',
        message: error,
        backgroundColor: AppTheme.warningcolor,
        icon: const Icon(
          Icons.error_outline,
          size: 28.0,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
    /* finally {
      if (mounted) setState(() => _isLoading = false);
    }*/
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void _showFlushbar(BuildContext context, String message, Color color) {
  Flushbar(
    message: message,
    backgroundColor: color,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: BorderRadius.circular(8),
    margin: const EdgeInsets.all(8),
    icon: Icon(
      color == AppTheme.confirmationscolor ? Icons.check_circle : Icons.error_outline,
      color: Colors.white,
    ),
  ).show(context);
}
