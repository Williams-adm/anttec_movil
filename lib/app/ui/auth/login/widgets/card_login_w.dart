import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:flutter/material.dart';

class CardLoginW extends StatelessWidget {
  final List<Widget> children;

  const CardLoginW({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.transparent),
      ),
      color: AppColors.primaryS,
      margin: EdgeInsets.only(left: 25.0, right: 25.0),
      elevation: 8.0,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 35.0, horizontal: 25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
