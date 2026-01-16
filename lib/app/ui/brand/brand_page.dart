import 'package:flutter/material.dart';
import 'brand_controller.dart';
import 'widgets/brand_list_widget.dart';

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
    _controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtro por Categoría")),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(child: Text("Error: ${_controller.errorMessage}"));
          }

          if (_controller.categories.isEmpty) {
            return const Center(child: Text("No hay categorías disponibles"));
          }

          return ListView.builder(
            itemCount: _controller.categories.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final category = _controller.categories[index];

              // Asumimos que en tu modelo son tipos no nulos (int y String)
              final categoryId = category.id;
              final categoryName = category.name;

              final isExpanded =
                  _controller.expandedCategories[categoryId] ?? false;

              return Column(
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isExpanded
                          ? BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // CORREGIDO: Eliminamos el if (categoryId != null)
                        // porque el linter dice que ya es seguro.
                        _controller.toggleCategory(categoryId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12.0,
                        left: 4.0,
                        right: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          // CORREGIDO: Usamos .withValues(alpha: ...) en lugar de .withOpacity()
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                              child: Text(
                                "Selecciona una marca:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            BrandListWidget(brands: _controller.brands),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
