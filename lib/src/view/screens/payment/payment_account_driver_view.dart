import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/model/payment/payment_driver_account_model.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/payment_driver_account_viewmodel.dart';
import 'package:another_flushbar/flushbar.dart';

class PaymentMethod {
  final String name;
  final String hint;
  final String logoPath;
  final Color color;

  const PaymentMethod({
    required this.name,
    required this.hint,
    required this.logoPath,
    required this.color,
  });
}

class PaymentAccountDriverView extends StatefulWidget {
  const PaymentAccountDriverView({super.key});

  @override
  State<PaymentAccountDriverView> createState() => _BankAccountViewState();
}

class _BankAccountViewState extends State<PaymentAccountDriverView> {
  late int driverId;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController = TextEditingController();
  final List<PaymentMethod> _paymentMethods = [
    const PaymentMethod(name: 'Nequi', hint: 'Número de Nequi ', color: Colors.red, logoPath: 'assets/images/nequi.png'),
    const PaymentMethod(name: 'Daviplata', hint: 'Número de Daviplata ', color: Colors.orange, logoPath: 'assets/images/daviplata.png'),
  ];

  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final rawUserId = sessionVM.userId;
     driverId = int.tryParse(rawUserId?.toString() ?? '1') ?? 1;
    print("ID $driverId");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialAccount();
    });

    _selectedMethod = _paymentMethods.first;
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAccount() async {
    final viewModel = Provider.of<PaymentDriverAccountViewmodel>(context, listen: false);
    await viewModel.loadPaymentAccount(driverId);
    _updateUIFromLoadedData(viewModel.currentAccount);
  }

  void _updateUIFromLoadedData(PaymentDriverAccountModel? account) {
    if (account == null) return;

    setState(() {
      _selectedMethod = _paymentMethods.firstWhere(
        (m) => m.name.toUpperCase() == account.paymentMethod.toUpperCase(),
        orElse: () => _paymentMethods.first,
      );
      _accountNumberController.text = account.accountNumber;
    });
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final method = _selectedMethod!.name;
      final accountNumber = _accountNumberController.text;

      final viewModel = Provider.of<PaymentDriverAccountViewmodel>(context, listen: false);
      final accountData = PaymentDriverAccountModel(driverId: driverId, paymentMethod: method, accountNumber: accountNumber);
      final success = await viewModel.savePaymentAccount(accountData);

      print('Método Seleccionado: $method');
      print('Número de Cuenta/Celular: $accountNumber');

      if (success) {
         Flushbar(
            title: 'Todo salio bien',
            message:'Hemos registrado tus datos con éxito.', 
            backgroundColor: AppTheme.confirmationscolor,
            icon: const Icon(
            Icons.check_circle_outline,
            size: 28.0,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
      } else {
        Flushbar(
          title: 'Hubo un error',
          message: 'No pudimos guardar tus datos.',
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
    }
  }

  Widget _buildLogo(String? path) {
    if (path == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.credit_card, color: Colors.grey, size: 28),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      child: Image.asset(
        path,
        height: 40,
        width: 40,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Configurar Cuenta de Pago",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Selecciona el método y registra tu número para recibir tus liquidaciones:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<PaymentMethod>(
                decoration: InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: _buildLogo(_selectedMethod?.logoPath),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                value: _selectedMethod,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Row(
                      children: [
                        Image.asset(
                          method.logoPath,
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(method.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (PaymentMethod? newValue) {
                  setState(() {
                    _selectedMethod = newValue;
                    _accountNumberController.clear();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecciona un método de pago';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _selectedMethod?.hint ?? 'Ingresa el número de cuenta',
                  hintText: 'Cuenta',
                  prefixIcon: const Icon(Icons.dialpad),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número de cuenta  es obligatorio';
                  }
                  if (value.length < 10) {
                    return 'Debe tener al menos 10 dígitos';
                  }
                  return null;
                },
              ),
              const Spacer(),
              Consumer<PaymentDriverAccountViewmodel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Guardar Cuenta de Pago',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
