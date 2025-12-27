import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/payment/payment_account_driver_view.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/wallet_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- CLASE PRINCIPAL ---
class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  // 🔹 Función para formatear fechas
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
          final wallets = viewModel.wallet!;

          final String lastPayment = _formatDate(wallets.lastPaymentDate);
          final String nextPayment = _formatDate(wallets.nextPaymentDate);

          final double availableBalance = wallets.availableBalance;
          final double pendingBalance = wallets.pendingBalance;

          final double totalBalance = availableBalance + pendingBalance;

          // Formateo de saldos
          final String rawTotal = formatPriceMovingDetails(totalBalance.toStringAsFixed(0));
          final String rawAvailable = formatPriceMovingDetails(availableBalance.toStringAsFixed(0));
          final String rawPending = formatPriceMovingDetails(pendingBalance.toStringAsFixed(0));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 💳 TARJETA PRINCIPAL CON TODOS LOS SALDOS Y FECHAS
                _buildMainBalanceCard(
                  rawTotal: rawTotal,
                  rawAvailable: rawAvailable,
                  rawPending: rawPending,
                  lastPayment: lastPayment,
                  nextPayment: nextPayment,
                ),

                const SizedBox(height: 24),

                // 2. ⚙️ TARJETA DE ACCIÓN (Configurar Pago)
                _buildActionCard(
                  title: "Configurar Cuenta de Pago",
                  subtitle: "Configura tu cuenta de pago",
                  icon: Icons.credit_card_outlined,
                  color: AppTheme.primarycolor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentAccountDriverView(),
                      ),
                    );
                  },
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
  Widget _buildMainBalanceCard({
    required String rawTotal,
    required String rawAvailable,
    required String rawPending,
    required String lastPayment,
    required String nextPayment,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SALDO TOTAL", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              rawTotal,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.primarycolor),
            ),
            const Divider(height: 30),
            _buildBalanceDetailRow(
              title: "Disponible para Retirar",
              value: rawAvailable,
              icon: Icons.check_circle_outline,
              color: AppTheme.confirmationscolor,
            ),
            const SizedBox(height: 12),
            _buildBalanceDetailRow(
              title: "Ganancias Pendientes (En Proceso)",
              value: rawPending,
              icon: Icons.watch_later_outlined,
              color: Colors.orange,
            ),

            const Divider(height: 30),

            _buildDateDetailRow(
              title: "Último Pago Recibido:",
              value: lastPayment,
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 8),
            _buildDateDetailRow(
              title: "Próxima Liquidación:",
              value: nextPayment,
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDetailRow({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateDetailRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}

Widget _buildActionCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            )),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}
