import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/ui/layout/widgets/footer_w.dart';
import 'package:flutter/material.dart';

class LayoutScreen extends StatelessWidget {
  final Widget content;

  const LayoutScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6.0),
          child: Column(
            children: [
              Expanded(child: content),
              FooterW(),
            ],
          ),
        ),
      ),
    );
  }
}
