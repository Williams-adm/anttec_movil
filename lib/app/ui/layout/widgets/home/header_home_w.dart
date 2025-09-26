import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:anttec_movil/app/ui/layout/widgets/home/profile_w.dart';
import 'package:flutter/material.dart';

class HeaderHomeW extends StatelessWidget {
  final String profileName;
  final VoidCallback logout;

  const HeaderHomeW({
    super.key,
    required this.profileName,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$profileName 👋',
                  style: AppTitles.h2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                '';
              },
              icon: Icon(Icons.shopping_cart, size: 35),
            ),
            ProfileW(logout: logout),
          ],
        ),
      ],
    );
  }
}
