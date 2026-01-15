import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para pasar el ViewModel abajo

class LayoutHomeScreen extends StatefulWidget {
  final Widget content;
  final LayoutHomeViewmodel viewmodel;

  const LayoutHomeScreen({
    super.key,
    required this.content,
    required this.viewmodel,
  });

  @override
  State<LayoutHomeScreen> createState() => _LayoutHomeScreenState();
}

class _LayoutHomeScreenState extends State<LayoutHomeScreen> {
  // El _formKey y _searchController se mueven a ProductsScreen, aquí ya no sirven.

  @override
  Widget build(BuildContext context) {
    // Usamos ChangeNotifierProvider.value para que los hijos (ProductsScreen)
    // puedan acceder a este viewModel y pintar las categorías/perfil.
    return ChangeNotifierProvider.value(
      value: widget.viewmodel,
      child: ListenableBuilder(
        listenable: widget.viewmodel,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5), // Color de fondo general
            body: LoaderW(
              isLoading: widget.viewmodel.isloading,
              // AQUÍ ESTÁ EL CAMBIO: Ya no hay Column con Headers.
              // Solo mostramos el contenido hijo dentro de un SafeArea.
              child: SafeArea(child: widget.content),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.viewmodel.removeListener(_viewModelListener);
    // widget.viewmodel.loadProfile(); // No es necesario cargar al salir
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.viewmodel.loadProfile();
    widget.viewmodel.loadCategories();
    widget.viewmodel.addListener(_viewModelListener);
  }

  void _viewModelListener() {
    final errorMessage = widget.viewmodel.errorMessage;
    if (errorMessage != null && mounted) {
      ErrorDialogW.show(context, errorMessage);
    }
  }
}
