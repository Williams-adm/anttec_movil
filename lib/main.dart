import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Importamos la configuración de providers y la App raíz
import 'package:anttec_movil/app/config/providers.dart';
import 'package:anttec_movil/app.dart';

void main() {
  // Aseguramos que el motor de Flutter esté listo antes de llamar a servicios nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de la barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Barra de estado transparente
      systemNavigationBarColor: Colors.transparent, // Barra de nav transparente
      statusBarIconBrightness:
          Brightness.dark, // Iconos oscuros (batería, hora)
    ),
  );

  // Ejecutamos la app envolviéndola en MultiProvider
  runApp(
    MultiProvider(
      providers: providersRemote, // Aquí se cargan Auth, Category y Cart
      child: const MyApp(),
    ),
  );
}
