import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';

// LE PUSE 'Backup' AL NOMBRE PARA DIFERENCIARLO
class LayoutHomeScreenBackup extends StatefulWidget {
  final Widget content;
  final LayoutHomeViewmodel viewmodel;

  const LayoutHomeScreenBackup({
    super.key,
    required this.content,
    required this.viewmodel,
  });

  @override
  State<LayoutHomeScreenBackup> createState() => _LayoutHomeScreenBackupState();
}

class _LayoutHomeScreenBackupState extends State<LayoutHomeScreenBackup> {
  // Control del índice seleccionado
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos
    widget.viewmodel.loadProfile();
    widget.viewmodel.loadCategories();
    widget.viewmodel.addListener(_viewModelListener);
  }

  @override
  void dispose() {
    widget.viewmodel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    final errorMessage = widget.viewmodel.errorMessage;
    if (errorMessage != null && mounted) {
      ErrorDialogW.show(context, errorMessage);
    }
  }

  // --- LÓGICA DE NAVEGACIÓN ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // CASITA -> Ir a Home (ProductsScreen)
        context.go('/home');
        break;
      case 1:
        // ESCÁNER
        context.push('/scan');
        break;
      case 2:
        // CARRITO
        context.push('/cart');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewmodel,
      child: ListenableBuilder(
        listenable: widget.viewmodel,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),

            // CONTENIDO PRINCIPAL (Con Loader)
            body: LoaderW(
              isLoading: widget.viewmodel.isloading,
              child: SafeArea(child: widget.content),
            ),

            // BARRA DE NAVEGACIÓN (BOTTOM BAR)
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF7E33A3), // Morado
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner),
                    label: 'Escanear',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: 'Carrito',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
