import 'package:flutter/material.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
import 'package:anttec_movil/app/core/styles/texts.dart';

// ✅ Servicios (Mantener estos, son la capa de datos)
import 'package:anttec_movil/data/services/api/v1/brand_service.dart';
import 'package:anttec_movil/data/services/api/v1/category_service.dart';

class AdvancedFilterModal extends StatefulWidget {
  // Parámetros recibidos para mantener la selección actual
  final int? selectedBrand;
  final int? selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final String? orderBy;
  final String? orderDir;

  const AdvancedFilterModal({
    super.key,
    this.selectedBrand,
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
    this.orderBy,
    this.orderDir,
  });

  @override
  State<AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<AdvancedFilterModal> {
  // 1. Instancia de Servicios (Reemplaza al BrandController)
  final BrandService _brandService = BrandService();
  final CategoryService _categoryService = CategoryService();

  // 2. Estado Local (Variables temporales antes de aplicar)
  late int? _tempBrand;
  late int? _tempCategory;
  late RangeValues _priceRange;
  late String? _tempOrderBy;
  late String? _tempOrderDir;

  // 3. Listas de Datos (Reemplaza a BrandListWidget y CategoryList)
  List<dynamic> _brands = [];
  List<dynamic> _categories = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    // Inicializar estado con lo que viene del padre
    _tempBrand = widget.selectedBrand;
    _tempCategory = widget.selectedCategory;
    _priceRange = RangeValues(widget.minPrice ?? 0, widget.maxPrice ?? 3000);
    _tempOrderBy = widget.orderBy;
    _tempOrderDir = widget.orderDir;

    // Cargar datos de la API
    _loadFilterData();
  }

  // Lógica de carga (Antes estaba en BrandController)
  Future<void> _loadFilterData() async {
    try {
      final results = await Future.wait([
        _brandService.getAllBrands(),
        _categoryService.categoryAll(),
      ]);

      if (mounted) {
        setState(() {
          _brands = results[0] as List<dynamic>;
          // Ajusta '.data' si tu respuesta lo requiere
          _categories = (results[1] as dynamic).data;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        debugPrint("Error cargando filtros: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 85% de altura
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // --- BARRA DE ARRASTRE ---
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // --- ENCABEZADO ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filtros",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Limpiar"),
                )
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),

          // --- CONTENIDO (SCROLL) ---
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // SECCIÓN 1: ORDENAR
                      _buildSectionTitle("Ordenar por"),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildSortChip("Menor Precio", 'price', 'asc'),
                          _buildSortChip("Mayor Precio", 'price', 'desc'),
                          _buildSortChip("Nombre (A-Z)", 'name', 'asc'),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // SECCIÓN 2: PRECIO (Reemplaza PriceFilterWidget)
                      _buildSectionTitle("Rango de Precio"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("S/ ${_priceRange.start.round()}",
                              style: AppTexts.body1M
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Text("S/ ${_priceRange.end.round()}",
                              style: AppTexts.body1M
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 3000,
                        divisions: 30,
                        activeColor: AppColors.primaryP,
                        inactiveColor: Colors.grey[200],
                        labels: RangeLabels(
                          "S/ ${_priceRange.start.round()}",
                          "S/ ${_priceRange.end.round()}",
                        ),
                        onChanged: (values) =>
                            setState(() => _priceRange = values),
                      ),
                      const SizedBox(height: 30),

                      // SECCIÓN 3: CATEGORÍAS
                      _buildSectionTitle("Categorías"),
                      if (_categories.isEmpty)
                        const Text("No hay categorías disponibles",
                            style: TextStyle(color: Colors.grey)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected = _tempCategory == cat.id;
                          return _buildFilterChip(
                            label: cat.name,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() =>
                                  _tempCategory = isSelected ? null : cat.id);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),

                      // SECCIÓN 4: MARCAS (Reemplaza BrandListWidget)
                      _buildSectionTitle("Marcas"),
                      if (_brands.isEmpty)
                        const Text("No hay marcas disponibles",
                            style: TextStyle(color: Colors.grey)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _brands.map((brand) {
                          final isSelected = _tempBrand == brand['id'];
                          return _buildFilterChip(
                            label: brand['name'],
                            isSelected: isSelected,
                            onTap: () {
                              setState(() =>
                                  _tempBrand = isSelected ? null : brand['id']);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
          ),

          // --- BOTÓN APLICAR ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Devuelve todos los filtros seleccionados
                    Navigator.pop(context, {
                      'brand': _tempBrand,
                      'category': _tempCategory,
                      'minPrice': _priceRange.start,
                      'maxPrice': _priceRange.end,
                      'orderBy': _tempOrderBy,
                      'orderDir': _tempOrderDir,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryP,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Aplicar Filtros",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, String dir) {
    final isSelected = _tempOrderBy == value && _tempOrderDir == dir;
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _tempOrderBy = null;
            _tempOrderDir = null;
          } else {
            _tempOrderBy = value;
            _tempOrderDir = dir;
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryP.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryP : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryP : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryP : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryP : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _tempBrand = null;
      _tempCategory = null;
      _priceRange = const RangeValues(0, 3000);
      _tempOrderBy = null;
      _tempOrderDir = null;
    });
  }
}
