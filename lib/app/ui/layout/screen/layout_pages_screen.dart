import 'package:anttec_movil/app/core/styles/titles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class LayoutPagesScreen extends StatelessWidget {
  final String title;
  final Widget content;

  const LayoutPagesScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTitles.h1),
            IconButton(
              onPressed: () {
                context.goNamed('home');
              },
              icon: Icon(Symbols.close, size: 35, weight: 600),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 16, left: 4, right: 4),
            width: double.infinity,
            child: content,
          ),
        ),
      ],
    );
  }
}
