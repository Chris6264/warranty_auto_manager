//Clase para la modificacion de reparaciones y garantias
// ignore_for_file: non_constant_identifier_names, unnecessary_import, library_private_types_in_public_api, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warranty_auto_manager/dialogos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MrygPage extends StatefulWidget {
  const MrygPage({super.key});

  @override
  _MrygPageState createState() => _MrygPageState();
}

class _MrygPageState extends State<MrygPage> {
  final TextEditingController _vinControl = TextEditingController();
  final TextEditingController _NumReparacionControl = TextEditingController();
  final TextEditingController _TotalSubtotalControl = TextEditingController();
  List<String> _vinLista = [];
  List<String> _numReparacionLista = [];
  bool _mostrarDetallesReparacion = false;
  final List<Map<String, TextEditingController>> _repararlista = [
    {
      'descripcion': TextEditingController(),
      'costo': TextEditingController(),
      'cantidad': TextEditingController(),
      'subtotal': TextEditingController(),
    }
  ];
  final TextEditingController _IvaControl = TextEditingController();
  final TextEditingController _totalControl = TextEditingController();
  DateTime? _fechaInicio;
  String? _duracion;
  DateTime? _fechaFin;
  final List<int> _duracionOpciones = [1,2,3,4,5,6,7,8,9,10,11,12]; // Duraciones de garantía


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
        _vinLista = vins;
      });
    } catch (e) {
      print('Error al obtener los VINs: $e');
    }
  }

  Future<void> _obtenerNumReparaciones(String vin) async {
    try {
      // Limpiar la lista antes de obtener los nuevos números
      setState(() {
        _numReparacionLista = [];
        _NumReparacionControl.clear();
        _mostrarDetallesReparacion = false; // Ocultar detalles
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ReparacionesGarantias')
          .doc(vin)
          .collection('Reparaciones')
          .get();

      List<String> numReparaciones =
          querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _numReparacionLista = numReparaciones;
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
            _repararlista[0]['descripcion']!.text = data['Descripción'] ?? '';
            _repararlista[0]['costo']!.text = data['Costo'].toString();
            _repararlista[0]['cantidad']!.text = data['Cantidad'].toString();
            _repararlista[0]['subtotal']!.text = data['Subtotal'].toString();
            _TotalSubtotalControl.text = data['Total/Subtotal'].toString();
            _IvaControl.text = data['Iva'].toString();
            _totalControl.text = data['Total'].toString();
            _fechaInicio = data['FechaInicioGarantia'] != null
                ? (data['FechaInicioGarantia'] as Timestamp).toDate()
                : null;
            _duracion = data['DuracionGarantia'].toString();
            _fechaFin = data['FechaFinGarantia'] != null
                ? (data['FechaFinGarantia'] as Timestamp).toDate()
                : null;
          });
        }
      }
    } catch (e) {
      print('Error al obtener los datos de la reparación: $e');
    }
  }

  void _calcularSubtotal(Map<String, TextEditingController> reparar) {
    double costo = double.tryParse(reparar['costo']!.text) ?? 0.0;
    int cantidad = int.tryParse(reparar['cantidad']!.text) ?? 0;
    double subtotal = costo * cantidad;
    reparar['subtotal']!.text = subtotal.toStringAsFixed(2);
    _calcularTotalSubtotal();
  }

  void _calcularTotalSubtotal() {
    double total = _repararlista.fold(0.0, (sum, reparar) {
      double subtotal = double.tryParse(reparar['subtotal']!.text) ?? 0.0;
      return sum + subtotal;
    });
    _TotalSubtotalControl.text = total.toStringAsFixed(2);
    _calcularIVA(total);
    _calcularTotal(total);
  }

  void _calcularIVA(double subtotal) {
    double iva = subtotal * 0.16;
    _IvaControl.text = iva.toStringAsFixed(2);
  }

  void _calcularTotal(double subtotal) {
    double iva = double.tryParse(_IvaControl.text) ?? 0.0;
    double total = subtotal + iva;
    _totalControl.text = total.toStringAsFixed(2);
  }

  Future<void> actualizarReparacion() async {
  String vin = _vinControl.text.trim();
  String numReparacion = _NumReparacionControl.text.trim();

  // Lista para almacenar mensajes de error
  List<String> errores = [];

  // Validar VIN
  if (vin.isEmpty) {
    errores.add('El VIN no puede estar vacío.');
  }

  // Validar número de reparación
  if (numReparacion.isEmpty) {
    errores.add('El número de reparación no puede estar vacío.');
  }

  // Validar lista de reparaciones
  if (_repararlista.isEmpty) {
    errores.add('La lista de reparaciones está vacía.');
  } else {
    for (int i = 0; i < _repararlista.length; i++) {
      Map<String, TextEditingController> reparar = _repararlista[i];
      if (reparar['descripcion']!.text.trim().isEmpty ||
          reparar['costo']!.text.trim().isEmpty ||
          reparar['cantidad']!.text.trim().isEmpty ||
          reparar['subtotal']!.text.trim().isEmpty) {
        errores.add('Por favor, complete todos los campos de la reparación.');
        break;
      }
    }
  }

  // Mostrar mensajes de error si los hay
  if (errores.isNotEmpty) {
    dialogos.Error(context, errores.join('\n'));
    return; // Salir de la función si hay errores
  }

  try {
    // Verificar si el documento existe antes de intentar actualizarlo
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('ReparacionesGarantias')
        .doc(vin)
        .collection('Reparaciones')
        .doc(numReparacion)
        .get();

    if (!docSnapshot.exists) {
      dialogos.Error(context, "El documento no existe y no se puede actualizar.");
      return; // Salir de la función si el documento no existe
    }

    // Actualizar en la colección de Reparaciones dentro de ReparacionesGarantias
    for (int i = 0; i < _repararlista.length; i++) {
      Map<String, TextEditingController> reparar = _repararlista[i];

      // Crear el mapa de datos para actualizar en Firestore
      Map<String, dynamic> data = {
        'Vin': vin,
        'NumReparacion': numReparacion,
        'Descripcion': reparar['descripcion']!.text.trim(),  // Reemplazar 'Descripción' por 'Descripcion'
        'Costo': double.tryParse(reparar['costo']!.text.trim()) ?? 0.0,
        'Cantidad': int.tryParse(reparar['cantidad']!.text.trim()) ?? 0,
        'Subtotal': double.tryParse(reparar['subtotal']!.text.trim()) ?? 0.0,
        'TotalSubtotal': double.tryParse(_TotalSubtotalControl.text.trim()) ?? 0.0,  // Reemplazar 'Total/Subtotal' por 'TotalSubtotal'
        'Iva': double.tryParse(_IvaControl.text.trim()) ?? 0.0,
        'Total': double.tryParse(_totalControl.text.trim()) ?? 0.0,
        'FechaInicioGarantia': _fechaInicio,
        'DuracionGarantia': int.tryParse(_duracion!) ?? 0,
        'FechaFinGarantia': _fechaFin,
      };

      await FirebaseFirestore.instance
          .collection('ReparacionesGarantias')
          .doc(vin)
          .collection('Reparaciones')
          .doc(numReparacion)
          .update(data);
    }
    setState(() {
      _vinControl.clear();
      _NumReparacionControl.clear();
      _repararlista.forEach((reparar) {
        reparar['descripcion']!.clear();
        reparar['costo']!.clear();
        reparar['cantidad']!.clear();
        reparar['subtotal']!.clear();
      });
      _TotalSubtotalControl.clear();
      _IvaControl.clear();
      _totalControl.clear();
      _fechaInicio = null;
      _duracion = null;
      _fechaFin = null;
    });

    // Mostrar un diálogo de éxito
    dialogos.Exito(context, "Información actualizada con éxito.");
    _mostrarDetallesReparacion = false; // Ocultar detalles
  } catch (e) {
    // Mostrar un diálogo de error
    dialogos.Error(context, "Error al actualizar la información: $e");
  }
}

  void _Opciones(BuildContext context, String Vin, String NumReparacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline,
                  color: Colors.black,
                  size: 90,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '¿Qué desea realizar con la reparación: $NumReparacion?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_NumReparacionControl.text.isNotEmpty) {
                            _mostrarDetallesReparacion = true;
                          } else {
                            _mostrarDetallesReparacion = false;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Modificar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Mostrar diálogo de confirmación personalizado
                        dialogos.Confirmacion(context,
                            '¿Está seguro de que desea eliminar la reparación: $NumReparacion?',
                            () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('ReparacionesGarantias')
                                .doc(Vin)
                                .collection('Reparaciones')
                                .doc(NumReparacion)
                                .delete();
                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('ReparacionesGarantias')
                                    .doc(Vin)
                                    .collection('Reparaciones')
                                    .get();
                            List<String> rep = querySnapshot.docs
                                .map((doc) => doc.id)
                                .toList();

                            setState(() {
                              _numReparacionLista = rep;
                              // Actualizar el valor seleccionado solo si la lista no está vacía
                              if (_numReparacionLista.isNotEmpty) {
                                _NumReparacionControl.text =
                                    _numReparacionLista[0];
                              } else {
                                _NumReparacionControl.clear();
                                _mostrarDetallesReparacion =
                                    false; // Ocultar detalles
                              }
                            });

                            Navigator.of(context).pop();
                            dialogos.Exito(context,
                                'Información Eliminada De La Reparación: $NumReparacion Con Éxito');
                            _mostrarDetallesReparacion =
                                false; // Ocultar detalles
                          } catch (e) {
                            print('Error al eliminar la reparación: $e');
                            dialogos.Error(context,
                                'No Es Posible Eliminar La Información De La Reparación: $NumReparacion');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectFechaInicio(BuildContext context) async {
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

  void _calcularFechaFin() {
    if (_fechaInicio != null && _duracion != null) {
      int durationMonths = int.tryParse(_duracion!) ?? 0;
      setState(() {
        _fechaFin = DateTime(
          _fechaInicio!.year,
          _fechaInicio!.month + durationMonths,
          _fechaInicio!.day,
        );
      });
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
              items: _numReparacionLista.map((String numReparacion) {
                return DropdownMenuItem<String>(
                  value: numReparacion,
                  child: Text(numReparacion),
                );
              }).toList(),
              onChanged: (String? value) async {
                if (value != null) {
                  setState(() {
                    _NumReparacionControl.text = value;
                    _obtenerDatosReparacion(_vinControl.text, value);
                  });
                  Navigator.of(context).pop();
                  _Opciones(context, _vinControl.text,
                      value); // Llamar a _Opciones aquí
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
                  'assets/images/editarh.png',
                  width: 250,
                  height: 250,
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                child: Text(
                  '4',
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
                        "Modificar/Eliminar Reparaciones Y Garantías",
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
                          value: _vinControl.text.isNotEmpty
                              ? _vinControl.text
                              : null,
                          items: _vinLista.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _vinControl.text = newValue!;
                              _obtenerNumReparaciones(newValue);
                              _mostrarDetallesReparacion =
                                  false; // Ocultar detalles
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
                              items: _numReparacionLista
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
                                  _Opciones(
                                      context, _vinControl.text, newValue);
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
                        const SizedBox(height: 30),
                        Visibility(
                          visible: _mostrarDetallesReparacion,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                itemCount: _repararlista.length,
                                itemBuilder: (context, index) {
                                  Map<String, TextEditingController> reparar =
                                      _repararlista[index];
                                  return Column(
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
                                        controller: reparar['descripcion'],
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
                                          prefixIcon:
                                              const Icon(Icons.description),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
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
                                        controller: reparar['costo'],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}$'),
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
                                          _calcularSubtotal(reparar);
                                        },
                                      ),
                                      const SizedBox(height: 20),
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
                                        controller: reparar['cantidad'],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
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
                                          _calcularSubtotal(reparar);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        '*Subtotal:',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: reparar['subtotal'],
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
                                          prefixIcon:
                                              const Icon(Icons.monetization_on),
                                        ),
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
                                  const Text(
                                    '*Total/Subtotal:',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _TotalSubtotalControl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon:
                                          const Icon(Icons.monetization_on),
                                      hintText: 'Total/Subtotal',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*IVA (16%):',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _IvaControl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon:
                                          const Icon(Icons.monetization_on),
                                      hintText: 'IVA (16%)',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    '*Total:',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _totalControl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon:
                                          const Icon(Icons.monetization_on),
                                      hintText: 'Total',
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
                                  onTap: () => _selectFechaInicio(context),
                                  decoration: InputDecoration(
                                    hintText: 'Fecha de Inicio de Garantía',
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () => _selectFechaInicio(context),
                                      child: const Icon(Icons.calendar_today),
                                    ),
                                  )),
                              const SizedBox(height: 20),
                              const Text(
                                '*Duración de Garantía (Meses):',
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
                                items: _duracionOpciones.map((int value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _duracion = newValue;
                                    _calcularFechaFin();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '*Duración de Garantía (Meses):',
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
                                  onPressed: actualizarReparacion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 80),
                                  ),
                                  child: const Text(
                                    'Modificar  Reparación',
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
