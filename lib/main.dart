// ignore_for_file: unused_import
//Clase encargada de inicializar la aplicación y de mostrar la página de inicio
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:warranty_auto_manager/firebase_options.dart';
import 'package:warranty_auto_manager/pages/login.dart';
import 'package:warranty_auto_manager/pages/menu.dart';
import 'package:warranty_auto_manager/pages/welcome.dart';
import 'package:firebase_core/firebase_core.dart';

// Main inicializa a firebase en la plataforma actual y ejecuta la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AnimatedLogin());
}

// AnimatedLogin es el widget principal de la aplicación
class AnimatedLogin extends StatelessWidget {
  const AnimatedLogin({super.key});

// Construye la aplicación con el tema y la página de inicio
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        theme: ThemeData(
          fontFamily: 'Satoshi',
          primaryColor: Colors.black,
          hintColor: Colors.grey,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const WelcomePage(),
        debugShowCheckedModeBanner: false,
      ),
    ); 
  }
}
