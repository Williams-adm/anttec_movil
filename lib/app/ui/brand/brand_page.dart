import 'package:flutter/material.dart';
import 'brand_controller.dart';
import 'widgets/brand_list_widget.dart';
// Asegúrate de importar tus estilos si los usas
// import 'package:anttec_movil/app/core/styles/colors.dart';

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
      appBar: AppBar(
        title: const Text("Filtro por Categoría"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Texto negro
      ),
      backgroundColor: Colors.grey[50], // Fondo sutil
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // --- ESTADOS DE CARGA Y ERROR ---
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error: ${_controller.errorMessage}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (_controller.categories.isEmpty) {
            return const Center(child: Text("No hay categorías disponibles"));
          }

          // --- LISTA DE CATEGORÍAS ---
          return ListView.builder(
            itemCount: _controller.categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              final category = _controller.categories[index];
              final categoryId = category.id;
              final categoryName = category.name;
              final isExpanded =
                  _controller.expandedCategories[categoryId] ?? false;

              // Color principal (puedes usar AppColors.primaryP si lo importas)
              final primaryColor = Theme.of(context).primaryColor;

              return Column(
                children: [
                  // --- TARJETA DE CATEGORÍA ---
                  Card(
                    elevation:
                        isExpanded ? 4 : 1, // Más elevación si está abierto
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shadowColor:
                        Colors.black.withValues(alpha: 0.1), // Sombra suave
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isExpanded
                          ? BorderSide(color: primaryColor, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _controller.toggleCategory(categoryId),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18, // Un poco más alto para mejor tacto
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isExpanded
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color:
                                    isExpanded ? primaryColor : Colors.black87,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: isExpanded ? primaryColor : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- SUB-SECCIÓN DE MARCAS (EXPANDIBLE) ---
                  if (isExpanded)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2)),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Text(
                              "Marcas disponibles en $categoryName:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 16),
                            child: BrandListWidget(brands: _controller.brands),
                          ),
                        ],
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
