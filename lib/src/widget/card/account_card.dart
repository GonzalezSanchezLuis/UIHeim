import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;
  final double height;
  final Icon icon;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.width = 300.0,
    this.height = 150.0,
    this.onTap,
    this.icon = const Icon(Icons.settings),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: width,
            height: height,
            child: SizedBox(
              width: width, // Asignar ancho
              height: height, // Asignar alto
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      icon,
                      const SizedBox(width: 16.0),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea textos a la izquierda
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centra verticalmente
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            title,
                            style: AppTheme.boldTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            )));
  }
}
