import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/wallet_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletView extends StatefulWidget {
  WalletView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final String? driverIdAsString = sessionVM.userId?.toString();
    final int driverId = int.tryParse(driverIdAsString ?? '0') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewmodel>(context, listen: false).loadWallet(driverId);
    });
  }

  /*double saldoPendiente = 120000;
  String ultimaTransaccion = "18 Sep 2025 - \$50,000";
  String proximaFechaPago = "30 Sep 2025";*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Ganancias",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WalletViewmodel>(builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(child: Text('Error: ${viewModel.errorMessage}'));
        }

        if (viewModel.wallet != null) {
          final wallets = viewModel.wallet;
          final String lastPayment = _formatDate(wallets!.lastPaymentDate);
          final String nextPayment = _formatDate(wallets.nextPaymentDate);
          final price = wallets.currentEarnedBalance;
          final priceString = price.toStringAsFixed(0);
          final raw = formatPriceMovingDetails(priceString);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saldo Pendiente Total
                _buildInfoCard(
                  title: "Saldo a Cobrar",
                  value: raw,
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                // Última Transacción
                _buildInfoCard(
                  title: "Último pago recibido",
                  value: lastPayment,
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                // Próxima Fecha de Pago
                _buildInfoCard(
                  title: "Próxima Fecha de Pago",
                  value: nextPayment,
                  icon: Icons.calendar_today_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  // 🔹 Widget reutilizable para cada card
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
