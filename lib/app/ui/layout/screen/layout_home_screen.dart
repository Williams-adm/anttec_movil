import 'package:anttec_movil/app/ui/layout/view_models/layout_home_viewmodel.dart';
import 'package:anttec_movil/app/ui/shared/widgets/error_dialog_w.dart';
import 'package:anttec_movil/app/ui/shared/widgets/loader_w.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LayoutHomeScreen extends StatefulWidget {
  final Widget content;

  // CORREGIDO: Ya no pedimos el viewmodel aquí.
  const LayoutHomeScreen({
    super.key,
    required this.content,
  });

  @override
  State<LayoutHomeScreen> createState() => _LayoutHomeScreenState();
}

class _LayoutHomeScreenState extends State<LayoutHomeScreen> {
  // Variable para guardar la referencia al ViewModel Global
  late LayoutHomeViewmodel _viewModel;

  @override
  void initState() {
    super.initState();

    // 1. CONECTAMOS CON EL VIEWMODEL GLOBAL
    // Usamos 'read' porque estamos en initState (solo queremos la referencia)
    _viewModel = context.read<LayoutHomeViewmodel>();

    // 2. ESCUCHAMOS ERRORES
    _viewModel.addListener(_viewModelListener);

    //  IMPORTANTE: NO cargamos datos aquí (loadProfile/loadCategories).
    // El Provider Global en 'providers.dart' ya lo hizo con '..init()'.
    // Si lo hacemos aquí, se reiniciaría la lista al volver del producto.
  }

  @override
  void dispose() {
    // Limpiamos el listener cuando esta pantalla muere
    _viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    final errorMessage = _viewModel.errorMessage;
    if (errorMessage != null && mounted) {
      ErrorDialogW.show(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. ESCUCHAMOS CAMBIOS PARA DIBUJAR (Loading, etc.)
    // Usamos 'watch' para que se repinte si cambia el estado (ej. loading)
    final vm = context.watch<LayoutHomeViewmodel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LoaderW(
        isLoading: vm.isloading,
        child: SafeArea(child: widget.content),
      ),
    );
  }
}
