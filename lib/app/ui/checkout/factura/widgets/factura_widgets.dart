import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:anttec_movil/app/core/styles/colors.dart';
// Importa BoletaInputField desde boleta_widgets
import 'package:anttec_movil/app/ui/checkout/boleta/widgets/boleta_widgets.dart';

class CompanyHeaderSection extends StatelessWidget {
  final TextEditingController rucController;
  final bool isSearching;
  final VoidCallback onSearch;

  const CompanyHeaderSection({
    super.key,
    required this.rucController,
    required this.isSearching,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Datos de la Empresa",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.extradarkT,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: BoletaInputField(
                label: "Número RUC (11 dígitos)",
                icon: Symbols.badge,
                controller: rucController,
                isNumeric: true,
                maxLength: 11,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isSearching ? null : onSearch,
              child: Container(
                margin: const EdgeInsets.only(top: 15),
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryP,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isSearching
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Symbols.search, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
