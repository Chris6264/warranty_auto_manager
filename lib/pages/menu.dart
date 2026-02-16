// Muestra el menú principal de la aplicación
// ignore_for_file: camel_case_types, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warranty_auto_manager/constants.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:warranty_auto_manager/pages/Con_Gart_Page.dart';
import 'package:warranty_auto_manager/pages/login.dart';
import 'package:warranty_auto_manager/pages/mec_page.dart';
import 'package:warranty_auto_manager/data.dart';
import 'package:warranty_auto_manager/pages/mryg_page.dart';
import 'package:warranty_auto_manager/dialogos.dart';
import 'package:warranty_auto_manager/pages/registration_page.dart';
import 'package:warranty_auto_manager/pages/ryg_page.dart';

class menuPage extends StatefulWidget {
  const menuPage({super.key});

  @override
  State<menuPage> createState() => _MenuPageState();
}

// Muestra el menú principal de la aplicación
class _MenuPageState extends State<menuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Llamada a showSuccessDialog después de que el widget se haya construido
      dialogos.Exito(
        context,
        'Sesión Iniciada con éxito',
      );
    });
  }

// Construye la página del menú principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 134, 213, 250)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    // Texto de bienvenida
                    Text(
                      '!!!!Bienvenido!!!!',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 44,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Swiper para mostrar las opciones de menú
              Container(
                height: 500,
                padding: const EdgeInsets.only(left: 28),
                child: Swiper(
                  itemCount: opciones.length,
                  itemHeight: 500,
                  itemWidth: MediaQuery.of(context).size.width - 2 * 64,
                  layout: SwiperLayout.STACK,
                  pagination: const SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 20),
                    builder: DotSwiperPaginationBuilder(
                      activeSize: 10,
                      space: 5,
                      activeColor: Colors.black,
                      color: Colors.white,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (opciones[index].name == 'Registro de información') {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a, b) =>
                                  DetailPage(appinfo: opciones[index]),
                            ),
                          );
                        } else {
                          if (opciones[index].name ==
                              'Modificar/Eliminar Cliente') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => const MecPage(),
                              ),
                            );
                          }
                          if (opciones[index].name ==
                              'Registro Reparaciones Y Garantías') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => const RygPage(),
                              ),
                            );
                          }
                          if (opciones[index].name ==
                              'Modificar/Eliminar Reparaciones Y Garantías') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) =>
                                    const MrygPage(),
                              ),
                            );
                          }
                          if (opciones[index].name == 'Consulta Garantías') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) =>
                                    const Consul_Page(),
                              ),
                            );
                          } else {
                            if (opciones[index].name == 'Salir') {
                              dialogos.Salida(
                                context,
                                '¿Salir De La Aplicación?',
                                () async {
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                    );
                                  } catch (error) {
                                    dialogos.Error(
                                      context,
                                      'Se produjo un error al cerrar sesión. Por favor, inténtelo de nuevo.',
                                    );
                                    print('Error al cerrar sesión: $error');
                                  }
                                },
                              );
                            }
                          }
                        }
                      },
                      // Construye la tarjeta de menú
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              const SizedBox(height: 80),
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height:
                                            150, // Ajustamos la altura de la imagen
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                opciones[index].iconImage),
                                            fit: BoxFit
                                                .contain, // Ajustamos la imagen a contener en su espacio
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        opciones[index].name,
                                        style: const TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 22,
                                          color: Color(0xFF47455F),
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Realizar Acción',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 18,
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: secondaryTextColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
