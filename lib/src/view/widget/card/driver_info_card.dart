import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/move/driver_information_view.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfoCard extends StatelessWidget {
  final int driverId;
  final String enrollVehicle;
  final String driverImageUrl;
  final String vehicleImageUrl;
  final String phone;
  final String nameDriver;
  final String vehicleType;

  const DriverInfoCard({
    super.key,
    required this.driverId,
    required this.enrollVehicle,
    required this.driverImageUrl,
    required this.vehicleImageUrl,
    required this.phone,
    required this.nameDriver,
    required this.vehicleType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${enrollVehicle.toUpperCase()} • ${vehicleType.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Image.asset(
                    vehicleImageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: (driverImageUrl != null && driverImageUrl.toString().isNotEmpty) ? NetworkImage(driverImageUrl) : null,
                child: (driverImageUrl == null || driverImageUrl.toString().isEmpty) ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
              ),

              const SizedBox(width: 12),

              // Nombre + botón flecha
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => DriverDataViewmodel(),
                          child: Builder(
                            builder: (context) {
                              return DriverInformationView(driverId: driverId);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '$nameDriver ya va en camino',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de llamada
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppTheme.thirdcolor1,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 20,
                  onPressed: () {
                    launchUrl(Uri.parse("tel:$phone"));
                  },
                  icon: const Icon(FontAwesomeIcons.phone, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
