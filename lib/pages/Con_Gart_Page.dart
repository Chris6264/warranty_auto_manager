// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warranty_auto_manager/dialogos.dart';

class Consul_Page extends StatefulWidget {
  const Consul_Page({super.key});

  @override
  _ConsulPageState createState() => _ConsulPageState();
}

class _ConsulPageState extends State<Consul_Page> {
  final TextEditingController _vinControl = TextEditingController();
  final TextEditingController _NumReparacionControl = TextEditingController();
  final TextEditingController _TotalSubtotalControl = TextEditingController();
  List<String> _vinList = [];
  List<String> _numReparacionList = [];
  final List<Map<String, TextEditingController>> _repairList = [
    {
      'description': TextEditingController(),
      'cost': TextEditingController(),
      'quantity': TextEditingController(),
      'subtotal': TextEditingController(),
    }
  ];
  final TextEditingController _IvaControl = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  DateTime? _fechaInicio;
  String? _duracion;
  DateTime? _fechaFin;
  bool _mostrardetalles = false;

  @override
  void initState() {
    super.initState();
    _obtenerVin();
  }

  Future<void> _obtenerVin() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .get();
      List<String> vins = querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _vinList = vins;
      });
    } catch (e) {
      print('Error al obtener los VINs: $e');
    }
  }

  Future<void> _obtenerNumReparaciones(String vin) async {
    try {
      // Limpiar la lista antes de obtener los nuevos números
      setState(() {
        _numReparacionList = [];
        _NumReparacionControl.clear();
        _mostrardetalles = false; // Ocultar detalles
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ReparacionesGarantias')
          .doc(vin)
          .collection('Reparaciones')
          .get();

      List<String> numReparaciones =
          querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _numReparacionList = numReparaciones;
      });
    } catch (e) {
      print('Error al obtener los números de reparación: $e');
    }
  }

  Future<void> _obtenerDatosReparacion(String vin, String numReparacion) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('ReparacionesGarantias')
          .doc(vin)
          .collection('Reparaciones')
          .doc(numReparacion)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          setState(() {
            _repairList[0]['description']!.text = data['Descripción'] ?? '';
            _repairList[0]['cost']!.text = data['Costo'].toString();
            _repairList[0]['quantity']!.text = data['Cantidad'].toString();
            _repairList[0]['subtotal']!.text = data['Subtotal'].toString();
            _TotalSubtotalControl.text = data['Total/Subtotal'].toString();
            _IvaControl.text = data['Iva'].toString();
            _totalController.text = data['Total'].toString();
            _fechaInicio = data['FechaInicioGarantia'] != null
                ? (data['FechaInicioGarantia'] as Timestamp).toDate()
                : null;
            _duracion = data['DuracionGarantia'].toString();
            _fechaFin = data['FechaFinGarantia'] != null
                ? (data['FechaFinGarantia'] as Timestamp).toDate()
                : null;
            _mostrardetalles = true; // Mostrar detalles
          });
        }
      }
    } catch (e) {
      print('Error al obtener los datos de la reparación: $e');
    }
  }

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
              items: _vinList.map((String vin) {
                return DropdownMenuItem<String>(
                  value: vin,
                  child: Text(vin),
                );
              }).toList(),
              onChanged: (String? value) async {
                if (value != null) {
                  setState(() {
                    _vinControl.text = value;
                    _obtenerNumReparaciones(value);
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

  Future<void> _mostrarNumReparacion(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Selecciona un Número de Reparación:',
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
              value: _NumReparacionControl.text.isEmpty
                  ? null
                  : _NumReparacionControl.text,
              items: _numReparacionList.map((String numReparacion) {
                return DropdownMenuItem<String>(
                  value: numReparacion,
                  child: Text(numReparacion),
                );
              }).toList(),
              onChanged: (String? value) async {
                if (value != null) {
                  setState(() {
                    _NumReparacionControl.text = value;
                    Navigator.of(context).pop();
                    _obtenerDatosReparacion(_vinControl.text, value);
                  });
                }
              },
              hint: const Text('Núm de Reparación'),
            ),
          ),
        );
      },
    );
  }

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
                  'assets/images/consul.png',
                  width: 250,
                  height: 250,
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                child: Text(
                  '5',
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
                  icon: const Icon(Icons.arrow_back_ios),
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
                        "Consulta Garantías",
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
                          value: _vinControl.text.isNotEmpty
                              ? _vinControl.text
                              : null,
                          items: _vinList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _vinControl.text = newValue!;
                              _obtenerNumReparaciones(newValue);
                              _mostrardetalles = false;
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
                    Column(
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
                        GestureDetector(
                          onTap: () {
                            _mostrarNumReparacion(context);
                          },
                          child: AbsorbPointer(
                            child: DropdownButtonFormField<String>(
                              value: _NumReparacionControl.text.isEmpty
                                  ? null
                                  : _NumReparacionControl.text,
                              items: _numReparacionList
                                  .map((String numReparacion) {
                                return DropdownMenuItem<String>(
                                  value: numReparacion,
                                  child: Text(numReparacion),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _NumReparacionControl.text = newValue!;
                                  _obtenerDatosReparacion(
                                      _vinControl.text, newValue);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Seleccionar Núm De Reparación',
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.construction),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Visibility(
                          visible: _mostrardetalles,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(
                                        child: Text(
                                          'Resumen de la reparación:',
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (_fechaInicio != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Fecha de inicio:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_repairList[0]['description']!
                                          .text
                                          .isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Descripción:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              _repairList[0]['description']!
                                                  .text,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_repairList[0]['cost']!
                                          .text
                                          .isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Costo:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '\$${_repairList[0]['cost']!.text}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_repairList[0]['quantity']!
                                          .text
                                          .isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Cantidad:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              _repairList[0]['quantity']!.text,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_repairList[0]['subtotal']!
                                          .text
                                          .isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Subtotal:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '\$${_repairList[0]['subtotal']!.text}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_TotalSubtotalControl.text.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total/Subtotal:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '\$${_TotalSubtotalControl.text}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_IvaControl.text.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('IVA:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '\$${_IvaControl.text}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_totalController.text.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '\$${_totalController.text}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_duracion != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Duración de garantía:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '$_duracion meses',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      if (_fechaFin != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Fecha de fin:',
                                                style: TextStyle(fontSize: 18)),
                                            Text(
                                              '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_fechaFin != null &&
                                        _fechaInicio != null) {
                                      DateTime hoy = DateTime.now();
                                      if (_fechaFin!.isAfter(hoy)) {
                                        dialogos.Exito(
                                            context, "Garantía Válida");
                                      } else {
                                        dialogos.Error(
                                            context, "Garantía No Válida");
                                      }
                                    } else {
                                      dialogos.Error(context,
                                          "Falta Información Importante");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 30),
                                  ),
                                  child: const Text(
                                    'Consultar garantía',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
