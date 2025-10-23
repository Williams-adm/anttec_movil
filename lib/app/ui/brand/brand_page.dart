import 'package:flutter/material.dart';
import 'brand_controller.dart';
import 'widgets/brand_list_widget.dart';
import 'widgets/price_filter_widget.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({super.key});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final BrandController _controller = BrandController();

  @override
  void initState() {
    super.initState();
    _controller.loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtro")),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(child: Text("Error: ${_controller.errorMessage}"));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandListWidget(brands: _controller.brands),
              const SizedBox(height: 20),
              const PriceFilterWidget(),
            ],
          );
        },
      ),
    );
  }
}
