import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warranty_auto_manager/dialogos.dart';
import 'package:warranty_auto_manager/pages/welcome.dart';
import 'package:warranty_auto_manager/pages/menu.dart';
import 'package:sizer/sizer.dart';
import 'package:animate_do/animate_do.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode enfocarEmail = FocusNode();
  final FocusNode enfocarContra = FocusNode();
  bool emailenfocado = false;
  bool contraenfocado = false;
  bool contravisible = false;
  final TextEditingController emailControl = TextEditingController();
  final TextEditingController contracontrol = TextEditingController();

  @override
  void initState() {
    super.initState();
    enfocarEmail.addListener(() {
      setState(() {
        emailenfocado = enfocarEmail.hasFocus;
      });
    });
    enfocarContra.addListener(() {
      setState(() {
        contraenfocado = enfocarContra.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    enfocarEmail.dispose();
    enfocarContra.dispose();
    emailControl.dispose();
    contracontrol.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String email = emailControl.text.trim();
    String password = contracontrol.text.trim();

    if (email.isEmpty) {
      dialogos.Error(context, 'Por favor ingrese su correo electrónico.');
      return;
    }

    if (password.isEmpty) {
      dialogos.Error(context, 'Por favor ingrese su contraseña.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      dialogos.Error(context, 'Correo electrónico inválido');
      return;
    }

    if (email != 'speed_servisch@hotmail.com' || password != 'FAM.CHAPARROC.') {
      dialogos.Error(context, 'Correo electrónico o contraseña incorrectos.');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const menuPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      String message = "";
      if (error.code == 'invalid-email') {
        message = 'El correo electrónico está mal formateado.';
      } else if (error.code == 'user-disabled') {
        message = 'El usuario con este correo ha sido deshabilitado.';
      } else if (error.code == 'user-not-found') {
        message = 'No se encontró ningún usuario con este correo.';
      } else if (error.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else {
        message = 'Error de autenticación. Por favor, inténtelo de nuevo.';
      }
      dialogos.Error(context, message);
      print('Error de autenticación de Firebase: $error');
    } catch (error) {
      dialogos.Error(context,
          'Se produjo un error inesperado. Por favor, inténtelo de nuevo.');
      print('Error inesperado: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: 100.h,
                decoration: const BoxDecoration(color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    FadeInUp(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 3.6.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: Text(
                            'Inicia Sesión',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        FadeInUp(
                          child: Text(
                            '!!!Bienvenido De Vuelta!!!',
                            style: TextStyle(
                              fontSize: 23.1.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    FadeInDown(
                      child: const Text(
                        'Correo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FadeInUp(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0.8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: .3.h),
                        decoration: BoxDecoration(
                          color: emailenfocado
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (emailenfocado)
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(.3),
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: emailControl,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(128),
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Correo',
                            suffixIcon: Icon(Icons.email),
                          ),
                          focusNode: enfocarEmail,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FadeInDown(
                      child: const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FadeInUp(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0.8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: .3.h),
                        decoration: BoxDecoration(
                          color: contraenfocado
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (contraenfocado)
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(.3),
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: contracontrol,
                          obscureText: !contravisible,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(128),
                          ],
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                contravisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                                size: 16.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  contravisible = !contravisible;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            hintText: 'Contraseña',
                          ),
                          focusNode: enfocarContra,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(height: 10),
                    ),
                    FadeInUp(
                      child: Row(
                        children: [
                          SizedBox(height: 20.h),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _login();
                              },
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Satoshi',
                                ),
                              ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 0, 0, 0)),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
