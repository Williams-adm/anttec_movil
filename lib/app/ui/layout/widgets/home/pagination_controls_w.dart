import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
// Asegúrate de que esta ruta sea correcta para tus colores

class PaginationControlsW extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final Function(int) onPageChanged;

  const PaginationControlsW({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (lastPage <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      height: 60, // Altura del contenedor general
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(30), // Bordes muy redondeados (Cápsula)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Sombra suave
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: ListView.separated(
          shrinkWrap: true, // Se ajusta al contenido (centrado)
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: lastPage + 2,
          separatorBuilder: (_, __) =>
              const SizedBox(width: 8), // Separación entre bolitas
          itemBuilder: (context, index) {
            // --- BOTÓN ANTERIOR (<) ---
            if (index == 0) {
              return _PageArrowButton(
                icon: Symbols.chevron_left,
                isEnabled: currentPage > 1,
                onTap: () => onPageChanged(currentPage - 1),
              );
            }

            // --- BOTÓN SIGUIENTE (>) ---
            if (index == lastPage + 1) {
              return _PageArrowButton(
                icon: Symbols.chevron_right,
                isEnabled: currentPage < lastPage,
                onTap: () => onPageChanged(currentPage + 1),
              );
            }

            // --- NÚMEROS (1, 2, 3...) ---
            final int pageNumber = index;
            final bool isSelected = pageNumber == currentPage;

            return _PageNumberButton(
              pageNumber: pageNumber,
              isSelected: isSelected,
              onTap: () => onPageChanged(pageNumber),
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGET PARA LOS NÚMEROS (BOLITAS) ---
class _PageNumberButton extends StatelessWidget {
  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Animación suave
        curve: Curves.easeInOut,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular
          color: isSelected
              ? const Color(0xFF7E33A3) // Tu color morado activo
              : Colors.transparent,
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PARA LAS FLECHAS (< >) ---
class _PageArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PageArrowButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isEnabled ? onTap : null,
      icon: Icon(
        icon,
        color: isEnabled ? const Color(0xFF7E33A3) : Colors.grey[300],
        size: 24,
      ),
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
