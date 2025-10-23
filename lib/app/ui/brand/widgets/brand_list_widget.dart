import 'package:flutter/material.dart';

class BrandListWidget extends StatelessWidget {
  final List<dynamic> brands;

  const BrandListWidget({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(brand['name'] ?? 'Sin nombre'),
          );
        },
      ),
    );
  }
}
