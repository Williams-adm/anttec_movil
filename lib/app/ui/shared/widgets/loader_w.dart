import 'package:flutter/material.dart';

class LoaderW extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoaderW({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
      ],
    );
  }
}
