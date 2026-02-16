//clase para registrar las reparaciones y garantias
// ignore_for_file: non_constant_identifier_names, unnecessary_import, library_private_types_in_public_api, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warranty_auto_manager/dialogos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class RygPage extends StatefulWidget {
  const RygPage({super.key});

  @override
  _RygPageState createState() => _RygPageState();
}

class _RygPageState extends State<RygPage> {
  final TextEditingController _vinControl = TextEditingController();
  final TextEditingController _NumReparacionControl = TextEditingController();
  final TextEditingController _TotalSubtotalControl = TextEditingController();
  List<String> _vinLista = [];
  //lista de reparaciones
  final List<Map<String, TextEditingController>> _listarepara = [
    {
      'descripcion': TextEditingController(),
      'costo': TextEditingController(),
      'cantidad': TextEditingController(),
      'subtotal': TextEditingController(),
    }
  ];
  final TextEditingController _IvaControl = TextEditingController();
  final TextEditingController _totalControl = TextEditingController();
  DateTime? _fechaInicio; // Fecha de inicio de garantía
  String? _duracion; // Duración de la garantía en meses
  DateTime? _fechaFin; // Fecha de fin de garantía
  final List<int> _duraciong = [1,2,3,4,5,6,7,8,9,10,11,12]; // Duraciones de garantía

  @override
  void initState() {
    super.initState();
    _obtenerVin(); // Obtener los VINs de la base de datos
  }
 //funcion para obtener los vins
  Future<void> _obtenerVin() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .get();
      List<String> vins = querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _vinLista = vins;
      });
    } catch (e) {
      print('Error al obtener los VINs: $e');
    }
  }
//funcion para obtener el numero de reparacion
  Future<void> _obtenerNumReparacion(String vin) async {
    try {
      // Obtener la subcolección 'Reparaciones' dentro del documento identificado por el VIN
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ReparacionesGarantias')
          .doc(vin)
          .collection('Reparaciones')
          .get();

      // Encontrar el número de reparación más grande
      int maxNum = 0;
      querySnapshot.docs.forEach((doc) {
        String numReparacion = doc.id;
        // Extraer el número después del guion y convertirlo a entero
        int num = int.parse(numReparacion.split('-')[1]);
        if (num > maxNum) {
          maxNum = num;
        }
      });

      // Incrementar el número más grande en uno
      int nextNum = maxNum + 1;

      // Formatear nextNum para que sean tres dígitos con ceros a la izquierda
      String numReparacionFormatted =
          'REP-${nextNum.toString().padLeft(3, '0')}';

      setState(() {
        _NumReparacionControl.text = numReparacionFormatted;
      });

      print('Nuevo número de reparación: $numReparacionFormatted');
    } catch (e) {
      print('Error al obtener el número de reparación: $e');
    }
  }
//funcion para calcular el subtotal
  void _calcularSubtotal(Map<String, TextEditingController> repair) {
    double costo = double.tryParse(repair['costo']!.text) ?? 0.0;
    int cantidad = int.tryParse(repair['cantidad']!.text) ?? 0;
    double subtotal = costo * cantidad;
    repair['subtotal']!.text = subtotal.toStringAsFixed(2);
    _calcularTotalSubtotal();
  }
//funcion para calcular el total y subtotal
  void _calcularTotalSubtotal() {
    double total = _listarepara.fold(0.0, (sum, repair) {
      double subtotal = double.tryParse(repair['subtotal']!.text) ?? 0.0;
      return sum + subtotal;
    });
    _TotalSubtotalControl.text = total.toStringAsFixed(2);
    _calcularIVA(total);
    _calcularTotal(total);
  }
//funcion para calcular el iva
  void _calcularIVA(double subtotal) {
    double iva = subtotal * 0.16;
    _IvaControl.text = iva.toStringAsFixed(2);
  }
//funcion para calcular el total
  void _calcularTotal(double subtotal) {
    double iva = double.tryParse(_IvaControl.text) ?? 0.0;
    double total = subtotal + iva;
    _totalControl.text = total.toStringAsFixed(2);
  }
//funcion para almacenar la reparacion
  Future<void> almacenarReparacion() async {
    String vin = _vinControl.text;
    String numReparacion = _NumReparacionControl.text;

    // Verificar si todos los campos de texto no están vacíos
    if (vin.isEmpty ||
        numReparacion.isEmpty ||
        _fechaInicio == null ||
        _fechaFin == null ||
        _duracion == null ||
        _listarepara.any((repair) =>
            repair['descripcion']!.text.isEmpty ||
            repair['costo']!.text.isEmpty ||
            repair['cantidad']!.text.isEmpty ||
            repair['subtotal']!.text.isEmpty) ||
        _TotalSubtotalControl.text.isEmpty ||
        _IvaControl.text.isEmpty ||
        _totalControl.text.isEmpty) {
      // Mensajes para indicar qué campos están vacíos
      List<String> camposVacios = [];
      if (vin.isEmpty) camposVacios.add('VIN');
      if (numReparacion.isEmpty) camposVacios.add('Número de Reparación');
      if (_fechaInicio == null) camposVacios.add('Fecha de Inicio');
      if (_fechaFin == null) camposVacios.add('Fecha de Fin');
      if (_duracion == null) camposVacios.add('Duración');
      _listarepara.forEach((repair) {
        if (repair['descripcion']!.text.isEmpty) {
          camposVacios.add('Descripción de Reparación');
        }
        if (repair['costo']!.text.isEmpty) {
          camposVacios.add('Costo de Reparación');
        }
        if (repair['cantidad']!.text.isEmpty) {
          camposVacios.add('Cantidad de Reparación');
        }
        if (repair['subtotal']!.text.isEmpty) {
          camposVacios.add('Subtotal de Reparación');
        }
      });
      if (_TotalSubtotalControl.text.isEmpty) {
        camposVacios.add('Total Subtotal');
      }
      if (_IvaControl.text.isEmpty) camposVacios.add('IVA');
      if (_totalControl.text.isEmpty) camposVacios.add('Total');

      // Mostrar un diálogo de error indicando los campos vacíos
      dialogos.Error(context,
          "Por favor, complete los siguientes campos:\n${camposVacios.join('\n')}");
      return; // Salir de la función sin almacenar los datos
    }

    try {
      // Almacenar en la colección de Reparaciones dentro de ReparacionesGarantias
      for (int i = 0; i < _listarepara.length; i++) {
        Map<String, TextEditingController> repair = _listarepara[i];

        // Crear el mapa de datos para almacenar en Firestore
        Map<String, dynamic> data = {
          'Vin': vin,
          'NumReparacion': '$numReparacion',
          'Descripción': repair['descripcion']!.text,
          'Costo': double.tryParse(repair['costo']!.text) ?? 0.0,
          'Cantidad': int.tryParse(repair['cantidad']!.text) ?? 0,
          'Subtotal': double.tryParse(repair['subtotal']!.text) ?? 0.0,
          'Total/Subtotal': double.tryParse(_TotalSubtotalControl.text) ?? 0.0,
          'Iva': double.tryParse(_IvaControl.text) ?? 0.0,
          'Total': double.tryParse(_totalControl.text) ?? 0.0,
          'FechaInicioGarantia': _fechaInicio,
          'DuracionGarantia': int.tryParse(_duracion!) ?? 0,
          'FechaFinGarantia': _fechaFin,
        };

        await FirebaseFirestore.instance
            .collection('ReparacionesGarantias')
            .doc(vin)
            .collection('Reparaciones')
            .doc('$numReparacion')
            .set(data);
      }
      setState(() {
        _vinControl.clear();
        _NumReparacionControl.clear();
        _listarepara.forEach((repair) {
          repair['descripcion']!.clear();
          repair['costo']!.clear();
          repair['cantidad']!.clear();
          repair['subtotal']!.clear();
        });
        _TotalSubtotalControl.clear();
        _IvaControl.clear();
        _totalControl.clear();
        _fechaInicio = null;
        _duracion = null;
        _fechaFin = null;
      });

      // Mostrar un diálogo de éxito
      dialogos.Exito(context, "Información almacenada con éxito.");
    } catch (e) {
      // Mostrar un diálogo de error
      dialogos.Error(context, "Error al guardar información.");
    }
  }
//funcion para seleccionar la fecha de inicio
  void _seleccionarFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Cambia el color de fondo de la selección
              onPrimary:
                  Colors.white, // Cambia el color del texto sobre la selección
              onSurface: Colors.black, // Cambia el color del texto de la fecha
            ),
            dialogBackgroundColor:
                Colors.white, // Cambia el color de fondo del diálogo
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaInicio) {
      setState(() {
        _fechaInicio = picked;
        _calcularFechaFin();
      });
    }
  }
//funcion para calcular la fecha de fin
  void _calcularFechaFin() {
    if (_fechaInicio != null && _duracion != null) {
      int duracion = int.tryParse(_duracion!) ?? 0;
      setState(() {
        _fechaFin = DateTime(
          _fechaInicio!.year,
          _fechaInicio!.month + duracion,
          _fechaInicio!.day,
        );
      });
    }
  }
//funcion para mostrar el vin
  Future<void> _mostrarvin(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Selecciona un VIN:',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              value: _vinControl.text.isEmpty ? null : _vinControl.text,
              items: _vinLista.map((String vin) {
                return DropdownMenuItem<String>(
                  value: vin,
                  child: Text(vin),
                );
              }).toList(),
              onChanged: (String? value) async {
                if (value != null) {
                  setState(() {
                    _vinControl.text = value;
                    _obtenerNumReparacion(value);
                  });
                  Navigator.of(context).pop();
                }
              },
              hint: const Text('Selecciona un VIN'),
            ),
          ),
        );
      },
    );
  }
//funcion para construir la pagina
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 160,
                top: 55,
                child: Image.asset(
                  'assets/images/agregarhe.png', // Imagen de fondo
                  width: 250,
                  height: 250,
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                child: Text(
                  '3',
                  style: TextStyle(
                    fontFamily: 'Sathosi',
                    fontSize: 247,
                    color: Colors.black.withOpacity(0.10),
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Positioned(
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios), // Botón de regreso
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 300),
                    const Center(
                      child: Text(
                        "Registro De Reparaciones Y Garantías",
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.black38),
                    const SizedBox(height: 30),
                    Container(
                      alignment: Alignment.center,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Información Reparación',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '*VIN:',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        _mostrarvin(context);
                      },
                      child: AbsorbPointer(
                        child: DropdownButtonFormField<String>(
                          value: _vinControl.text.isEmpty
                              ? null
                              : _vinControl.text,
                          items: _vinLista.map((String vin) {
                            return DropdownMenuItem<String>(
                              value: vin,
                              child: Text(vin),
                            );
                          }).toList(),
                          onChanged: (String? valorn) {
                            setState(() {
                              _vinControl.text = valorn!; // Actualizar el VIN
                              _obtenerNumReparacion(valorn); // Obtener el número de reparación
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Seleccionar VIN',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.directions_car),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _vinControl.text.isNotEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '*Número de Reparación:',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _NumReparacionControl,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Número de Reparación',
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.construction),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 30),
                          Container(
                            alignment: Alignment.center,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Reparaciones',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _listarepara.length,
                            itemBuilder: (context, index) {
                              Map<String, TextEditingController> repair =
                                  _listarepara[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '*Descripción de Reparación:',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: repair['descripcion'],
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(100)
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Descripción de Reparación',
                                          filled: true,
                                          fillColor:
                                              Colors.grey.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(Icons.description),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '*Costo:',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: repair['costo'],
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}$'), // Solo permite números y un punto
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                              hintText: 'Costo',
                                              filled: true,
                                              fillColor:
                                                  Colors.grey.withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              prefixIcon:
                                                  const Icon(Icons.monetization_on),
                                            ),
                                            onChanged: (value) {
                                              _calcularSubtotal(repair); // Calcular el subtotal
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '*Cantidad:',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: repair['cantidad'],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              hintText: 'Cantidad',
                                              filled: true,
                                              fillColor:
                                                  Colors.grey.withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              prefixIcon: const Icon(
                                                  Icons.format_list_numbered),
                                            ),
                                            onChanged: (value) {
                                              _calcularSubtotal(repair);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            '*Subtotal:',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: repair['subtotal'],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: 'Subtotal',
                                          filled: true,
                                          fillColor:
                                              Colors.grey.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(Icons
                                              .monetization_on),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 30),
                          Container(
                            alignment: Alignment.center,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Información de Pago',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    '*Total/Subtotal:',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _TotalSubtotalControl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Total/Subtotal',
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons
                                      .monetization_on),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    '*IVA (16%):',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _IvaControl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'IVA (16%)',
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons
                                      .monetization_on),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text(
                                    '*Total:',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _totalControl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Total',
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons
                                      .monetization_on),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 30),
                          Container(
                            alignment: Alignment.center,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Garantías',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '*Fecha de Inicio de Garantía:',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: _fechaInicio != null
                                    ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                                    : '',
                              ),
                              onTap: () => _seleccionarFechaInicio(context),
                              decoration: InputDecoration(
                                hintText: 'Fecha de Inicio de Garantía',
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => _seleccionarFechaInicio(context),
                                  child: const Icon(Icons.calendar_today),
                                ),
                              )),
                          const SizedBox(height: 20),
                          const Text(
                            '*Duración de Garantía (Meses)',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _duracion,
                            items: _duraciong.map((int value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (String? valorn) {
                              setState(() {
                                _duracion = valorn;
                                _calcularFechaFin();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Duración de Garantía (Meses):',
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '*Fecha de Fin de Garantía:',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _fechaFin != null
                                  ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                                  : '',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Fecha de Fin de Garantía',
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: const InkWell(
                                child: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Center(
                            child: ElevatedButton(
                              onPressed: almacenarReparacion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 80),
                              ),
                              child: const Text(
                                'Almacenar Reparación',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
