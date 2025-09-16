import 'package:anttec_movil/app.dart';
import 'package:anttec_movil/app/config/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Barra de estado transparente
      systemNavigationBarColor:
          Colors.transparent, // Barra de navegación transparente
    ),
  );

  runApp(MultiProvider(providers: providersRemote, child: const MyApp()));
}