//clase para modificar y eliminar clientes
// ignore_for_file: unused_element, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use, unused_field

import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warranty_auto_manager/constants.dart';
import 'package:warranty_auto_manager/dialogos.dart';

class MecPage extends StatefulWidget {
  const MecPage({super.key});

  @override
  _MecPageState createState() => _MecPageState();
}

class _MecPageState extends State<MecPage> {
  File? _image;
  final TextEditingController _marcaControl = TextEditingController();
  final TextEditingController _modeloControl = TextEditingController();
  final TextEditingController _motorControl = TextEditingController();
  final TextEditingController _yearControl = TextEditingController();
  final TextEditingController _descripcionControl = TextEditingController();
  final TextEditingController _nombreClienteControl = TextEditingController();
  final TextEditingController _telefonoClienteControl = TextEditingController();
  final TextEditingController _vinControl = TextEditingController();
  bool _vinComboboxEnabled = true;
  bool _showMarcaTextField = false;
  bool _showModeloTextField = false;
  bool _showYearTextField = false;
  final picker = ImagePicker();
  List<String> _vinList = [];
  bool _showVinOptions = false;
  late String imageUrl;

//Maximo de fecha en los años
  final List<int> years = List.generate(76, (index) => 2024 - index);

   //Diccionario de marcas
  final List<String> marcas = [
    'Toyota', 'Ford', 'Chevrolet','Honda','Volkswagen','Nissan', 'BMW', 'Mercedes-Benz','Audi', 'Hyundai','Chrysler','Dodge','Saturn',
    'Kia', 'Subaru','Mazda','Jeep','Volvo','Tesla','Lexus','Porsche','Fiat','Renault'
  ];

  //Diccionarios de modelos
    final Map<String, List<String>> modelos = {
  'Toyota': [
    'Corolla', 'Camry', 'Rav4', 'Tacoma', 'Highlander', 'Prius', 'Sienna', 'Tundra',
    '4Runner', 'Yaris', 'Avalon', 'C-HR', 'Sequoia', 'Land Cruiser', 'Mirai', 'Supra',
    'Prius Prime', 'Prius c', 'Prius v'
  ],
  'Ford': [
    'Ka', 'F-150', 'F-250', 'F-350','EcoBoost', 'F-450', 'F-550', 'Escape', 'Explorer', 'Focus',
    'Fusion', 'Edge', 'Mustang', 'Ranger', 'Expedition', 'EcoSport', 'Transit', 'Bronco',
    'Flex', 'Fiesta', 'Taurus', 'Super Duty', 'GT'
  ],
  'Chevrolet': [
    'Chevy', 'Aveo', 'Silverado', 'Equinox', 'Malibu', 'Cruze', 'Traverse', 'Tahoe',
    'Tracker', 'Suburban', 'Camaro', 'Impala', 'Colorado', 'Blazer', 'Bolt EV',
    'Trailblazer', 'Sonic', 'Spark', 'Volt', 'Express', 'Corvette', 'Trax'
  ],
  'Nissan': [
    'Altima', 'Sentra', 'Rogue', 'Versa', 'Platina', 'Pathfinder', 'Murano', 'Maxima',
    'Frontier', 'Titan', 'NP300', 'Tsuru', 'Kicks', 'Armada', '370Z', 'Leaf', 'NV200',
    'GT-R', 'Juke', 'X-Trail'
  ],
  'Hyundai': [
    'Accent', 'Elantra', 'Sonata', 'Veloster', 'Tucson', 'Santa Fe', 'Kona', 'Palisade',
    'Venue', 'Ioniq', 'Genesis', 'Nexo', 'Azera', 'Equus', 'Veracruz', 'Tiburon', 'Getz',
    'Atos', 'Stellar', 'Pony', 'Lantra', 'Santro', 'Excel', 'Galopper', 'Grandeur', 'Lavita',
    'Matrix', 'Terracan', 'Trajet', 'Genesis Coupe', 'H1', 'H100', 'H200'
  ],
  'Dodge': [
    'Charger', 'Challenger', 'Durango', 'Journey', 'Grand Caravan', 'Viper',
    'Dart', 'Avenger', 'Neon', 'Intrepid', 'Magnum', 'Nitro', 'Stealth',
    'Caliber', 'Dakota', 'Ram 1500', 'Ram 2500', 'Ram 3500', 'Stratus', 'Omni'
],
'Acura': [
    'ILX', 'TLX', 'RLX', 'RDX', 'MDX', 'NSX', 'Integra', 'Legend',
    'Vigor', 'RSX', 'ZDX', 'SLX', 'TSX', 'EL', 'CL', 'RL', 'CSX'
],
'Chrysler': [
    '300', 'Pacifica', 'Voyager', 'Aspen', 'Sebring', 'Crossfire',
    '200', '300M', 'Town & Country', 'PT Cruiser', 'Concorde', 'LHS',
    'Neon', 'Cirrus', 'Imperial', 'LeBaron', 'New Yorker'
],
  'Fiat': [
    '500', 'Panda', 'Tipo', 'Punto', '500X', '500L', 'Doblo', 'Qubo', '500e', '124 Spider',
    'Freemont', 'Croma', 'Linea', 'Bravo', 'Uno', 'Mobi', 'Sedici', 'Tempra', 'Strada',
    'Stilo', 'Argenta', 'Ritmo', 'Regata', '127', '131', '850', '1100', '1200', '1500',
    '1800', '2100', '1300', '2300', 'Uno Turbo', 'Punto Evo', 'Grande Punto', 'Multipla',
    'X1/9'
  ],
  'Audi': [
    'A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8', 'TT', 'R8', 'e-tron',
    'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'RS3', 'RS4', 'RS5', 'RS6', 'RS7'
  ],
  'BMW': [
    '1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '6 Series', '7 Series', '8 Series',
    'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'Z4', 'i3', 'i4', 'i8', 'M2', 'M3', 'M4', 'M5', 'M6',
    'X3 M', 'X4 M', 'X5 M', 'X6 M'
  ],
  'Honda': [
    'Accord', 'Accord Hybrid', 'City', 'Civic', 'Civic Type R', 'CR-V', 'CR-V Hybrid', 'Fit', 'HR-V',
    'Insight', 'Odyssey', 'Passport', 'Pilot', 'Ridgeline', 'S2000', 'Element', 'Prelude', 'CR-Z',
    'Integra', 'Legend', 'NSX', 'Ridgeline Type R', 'Stream', 'FR-V', 'Avancier', 'Crosstour',
    'Shuttle', 'Orthia', 'Domani', 'Concerto', 'Ascot', 'Spike', 'Mobilio', 'Capa', 'Crossroad'
  ],
  'Jeep': [
    'Cherokee', 'Compass', 'Gladiator', 'Grand Cherokee', 'Grand Cherokee L', 'Renegade', 'Wrangler',
    'Wrangler 4xe', 'Wrangler Unlimited', 'Grand Wagoneer', 'Wagoneer', 'Commander', 'Patriot',
    'Liberty', 'Comanche', 'CJ-5', 'CJ-7', 'CJ-8 Scrambler', 'Jeepster', 'Scrambler', 'Willys',
    'J-Series', 'FC', 'Wagoneer Limited'
  ],
  'Kia': [
    'Cadenza', 'Forte', 'K5', 'K900', 'Optima', 'Rio', 'Stinger', 'Carnival', 'Sedona', 'Seltos',
    'Soul', 'Sportage', 'Sorento', 'Telluride', 'Mohave', 'Niro', 'Niro EV', 'Seltos', 'Sorento',
    'Soul EV', 'Stonic', 'Stonic EV', 'Carens', 'Rondo', 'Spectra', 'Magentis', 'Lotze', 'Potentia',
    'Quoris', 'Ray', 'Brisa', 'Picanto', 'Morning', 'Venga', 'Pride', 'Ceed', 'ProCeed', 'K3', 'K4',
    'K7', 'K9', 'KX3', 'KX5', 'KX7', 'KX9', 'Sportage R', 'Mohave', 'Bongo', 'Sephia'
  ],
  'Lexus': [
    'ES', 'GS', 'IS', 'LC', 'LS', 'LX', 'NX', 'RC', 'RX', 'UX', 'CT', 'LFA', 'HS', 'SC', 'GX', 'RC F',
    'LC 500h', 'LC F', 'ES Hybrid', 'GS F', 'IS F', 'LS Hybrid', 'LX Hybrid', 'NX Hybrid', 'RX Hybrid',
    'UX Hybrid'
  ],
  'Mazda': [
    '2', '3', '6', 'CX-3', 'CX-30', 'CX-4', 'CX-5', 'CX-8', 'CX-9', 'MX-5 Miata', 'MX-5 Miata RF',
    'RX-8', 'MPV', 'Tribute', 'Premacy', 'Atenza', 'Verisa', 'Axela', 'Atenza Sport', 'CX-7', 'Demio',
    'Carol', 'Scrum', 'Biante', 'Roadster', 'Flair', 'Titan', 'AZ-1', 'Proceed', 'Bongo', 'RX-7', 'Familia',
    'Cosmo', 'RX-3', 'RX-4', 'RX-5', 'RX-6'
  ],
  'Mercedes-Benz': [
    'A-Class', 'AMG GT', 'B-Class', 'C-Class', 'CLA-Class', 'CLS-Class', 'E-Class', 'G-Class', 'GLA-Class',
    'GLB-Class', 'GLC-Class', 'GLE-Class', 'GLS-Class', 'Metris', 'S-Class', 'SL-Class', 'SLC-Class', 'Sprinter',
    'Maybach S-Class', 'EQC', 'EQV', 'V-Class', 'X-Class', 'AMG A-Class', 'AMG C-Class', 'AMG CLA-Class', 'AMG CLS-Class',
    'AMG E-Class', 'AMG GLA-Class', 'AMG GLB-Class', 'AMG GLC-Class', 'AMG GLE-Class', 'AMG GLS-Class', 'AMG S-Class',
    'AMG GT 4-Door', 'AMG GT Black Series'
  ],
  'Porsche': [
    '911', '718 Cayman', '718 Boxster', 'Panamera', 'Macan', 'Cayenne', 'Taycan', '944', '928', '964', '993', '996',
    '997', '918 Spyder', 'Carrera GT', '918 Spyder Weissach Package', '918 Spyder', 'Panamera Sport Turismo', 'Cayman',
    'Boxster', 'Cayenne Coupe', '718 Cayman GT4', '718 Boxster Spyder', '911 GT3', '911 GT3 RS', '911 Turbo',
    '911 Turbo S', '911 Targa', '911 Speedster', '911 Carrera GTS', '911 Carrera 4S', '911 Carrera S', '911 Carrera',
    '911 Carrera 4'
  ],
  'Renault': [
    'Clio', 'Captur', 'Mégane', 'Kadjar', 'Scénic', 'Talisman', 'Twingo', 'Koleos', 'Zoe', 'Duster', 'Arkana',
    'Laguna', 'Espace', 'Kangoo', 'Fluence', 'Modus', 'Grand Scénic', 'Grand Modus', 'Wind', 'Safrane', 'Avantime',
    'Latitude', 'Thalia', 'Vel Satis', 'R5', 'R9', 'R11', 'R19', 'R21', 'R25', 'R30', 'Rapid', 'Super 5', 'Express',
    'Symbol', 'Fuego', 'Alliance', 'Encore', 'Medallion', 'Savanna', 'R18', 'R15', 'R16', 'R12', 'R14', 'R17', 'R20',
    'R4', 'R6', 'R8'
  ],
  'Subaru': [
    'Impreza', 'Legacy', 'Outback', 'Forester', 'Crosstrek', 'Ascent', 'BRZ', 'WRX', 'XV', 'Justy', 'R1', 'R2',
    'Vivio', 'Traviq', 'Libero', 'Leone', 'Alcyone', 'SVX', 'XT', 'Baja', 'Trezia', 'Exiga', 'Lucra', 'Sambar',
    'Stella', 'Domingo', 'Sumo', 'Dex', 'Pleo', 'Pleo Plus', 'Pleo II', 'Rex', 'Sambar Dias Wagon', 'Sambar Dias Van',
    'TransCare', '360', '1000', '1300', 'FF-1 Star', 'Levorg', 'Justy', 'Dex'
  ],
  'Tesla': [
    'Model S', 'Model 3', 'Model X', 'Model Y', 'Roadster', 'Cybertruck', 'Semi'
  ],
  'Saturn': [
    'Ion', 'Vue', 'Aura', 'Sky', 'S-Series', 'L-Series', 'Relay', 'Outlook', 'Astra'
  ],
  'Volkswagen': [
    'Golf', 'Passat', 'Jetta', 'Tiguan', 'Arteon', 'Atlas', 'Touareg', 'Polo', 'Up!', 'Beetle', 'ID.3',
    'ID.4', 'ID. Buzz', 'ID. Crozz', 'ID. Vizzion', 'Scirocco', 'Eos', 'Touran', 'Sharan', 'T-Roc', 'Amarok',
    'Caddy', 'Fox', 'Lupo', 'Corrado', 'Phaeton', 'Bora', 'Variant', 'CrossFox', 'Fox', 'Gol', 'Polo Classic',
    'Polo Sedan', 'Parati', 'Pointer', 'Saveiro', 'SpaceFox', 'Voyage', 'Buggy', 'Brasília', 'SP2', 'Kombi',
    'Fusca', 'TL', 'Apollo', 'Logus', 'Pointer', 'Golf Variant'
  ],
  'Volvo': [
    'S60', 'S90', 'V60', 'V90', 'XC40', 'XC60', 'XC90', 'C30', 'C70', 'V40', 'V40 Cross Country', 'V50',
    'V60 Cross Country', 'V70', 'V90 Cross Country', 'XC70', 'S40', 'S80', '240', '740', '850', '940', '960',
    'S70', 'S90', 'S40', 'S80', 'C70', 'XC90', 'XC70', 'S60 Cross Country', 'S60 R', 'S80 Executive', 'S90 Excellence',
    'V40', 'V90 Estate', 'V70 R', 'XC90 Excellence', 'XC40 Recharge', 'XC60 Recharge', 'XC90 Recharge', 'C30 R',
    'P1800', 'Amazon', 'Duett', 'PV', '140 Series', '240 Series', '740 Series', '850 Series', '940 Series', '960 Series'
  ],
};

  List<String> modelosActuales = [];


  @override
  void initState() {
    super.initState();
    _vinControl.text = '';
    _marcaControl.text = '';
    _modeloControl.text = '';
    _yearControl.text = '';
    _motorControl.text = '';
    _descripcionControl.text = '';
    _nombreClienteControl.text = '';
    _telefonoClienteControl.text = '';
    _obtenerVin();
    imageUrl = '';
    marcas.sort();
  }

  Future<String> _obtenerMarca(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Marca');
      } else {
        return 'Marca no encontrado';
      }
    } catch (e) {
      print('Error al obtener la marca: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerModelo(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Modelo');
      } else {
        return 'Modelo no encontrado';
      }
    } catch (e) {
      print('Error al obtener el modelo: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerYear(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Año');
      } else {
        return 'Año no encontrado';
      }
    } catch (e) {
      print('Error al obtener el Año: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerMotor(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Motor');
      } else {
        return 'Motor no encontrado';
      }
    } catch (e) {
      print('Error al obtener el Motor: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerDescrip(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Descripcion');
      } else {
        return 'Descripcion no encontrada';
      }
    } catch (e) {
      print('Error al obtener la Descripcion: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerNomCli(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Nombre_cliente');
      } else {
        return 'Nombre_cliente no encontrado';
      }
    } catch (e) {
      print('Error al obtener el Nombre_cliente: $e');
      return 'Error';
    }
  }

  Future<String> _obtenerTelCli(String vin) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('Telefono_cliente');
      } else {
        return 'Telefono_cliente no encontrado';
      }
    } catch (e) {
      print('Error al obtener el Telefono_cliente: $e');
      return 'Error';
    }
  }

Future<List<String>> _obtenerVin() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Informacion_Vehiculos')
        .get();
    List<String> vins = querySnapshot.docs.map((doc) => doc.id).toList();
    return vins;
  } catch (e) {
    print('Error al obtener los VINs: $e');
    return []; // Devuelve una lista vacía en caso de error
  }
}

Future<void> _mostrarvin(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return FutureBuilder<List<String>>(
        future: _obtenerVin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error al obtener los VINs: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          } else {
            final vins = snapshot.data;
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
                  items: vins?.map((vin) {
                    return DropdownMenuItem<String>(
                      value: vin,
                      child: Text(vin),
                    );
                  }).toList(),
                  onChanged: (String? value) async {
                    if (value != null) {
                      _vinControl.text = value;
                      String marca = await _obtenerMarca(value);
                      String modelo = await _obtenerModelo(value);
                      String year = await _obtenerYear(value);
                      String motor = await _obtenerMotor(value);
                      String descripcion = await _obtenerDescrip(value);
                      String nombre = await _obtenerNomCli(value);
                      String tel = await _obtenerTelCli(value);
                      setState(() {
                        _marcaControl.text = marca;
                        _modeloControl.text = modelo;
                        _yearControl.text = year;
                        _motorControl.text = motor;
                        _descripcionControl.text = descripcion;
                        _nombreClienteControl.text = nombre;
                        _telefonoClienteControl.text = tel;
                      });
                      await _obtenerimagen(value);
                      Navigator.of(context).pop();
                      _mostrarAccionesVIN(context, value);
                    }
                  },
                  hint: const Text('Selecciona un VIN'),
                ),
              ),
            );
          }
        },
      );
    },
  );
}

  Future<void> _mostrarmodelos(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un modelo'),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              value: _modeloControl.text.isEmpty ? null : _modeloControl.text,
              items: modelosActuales.map((model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _modeloControl.text = value ?? '';
                });
                Navigator.of(context).pop();
              },
              hint: const Text('Selecciona un modelo'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarmarcas(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una marca'),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              value: _marcaControl.text.isEmpty ? null : _marcaControl.text,
              items: marcas.map((brand) {
                return DropdownMenuItem<String>(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _marcaControl.text = value!;
                  modelosActuales = modelos[value] ?? [];
                  modelosActuales.sort();
                  _modeloControl.text = ''; // Resetea el modelo
                });
                Navigator.of(context).pop();
              },
              hint: const Text('Selecciona una marca'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _obtenerimagen(String vin) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('Imagenes_Vehiculos/$vin.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error al obtener la URL de la imagen: $e');
    }
  }

  void _mostrarAccionesVIN(BuildContext context, String selectedVin) {
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
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.help_outline,
                    color: Colors.black,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '¿Qué desea realizar con el VIN $selectedVin?',
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
                          _showMarcaTextField = true;
                          _showModeloTextField = true;
                          _showVinOptions = true;
                          _showYearTextField = true;
                          _vinComboboxEnabled =
                              false; // Bloquear el combobox del VIN
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
                        dialogos.Confirmacion(
                          context,
                          '¿Estás seguro de eliminar el VIN: $selectedVin?',
                          () async {
                            await _eliminarVIN(context, selectedVin);
                          },
                        );
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

  Future<void> _eliminarVIN(BuildContext context, String selectedVin) async {
    try {
      // Eliminar la información del VIN de Firestore
      await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(selectedVin)
          .delete();

      // Eliminar la imagen asociada al VIN del almacenamiento de Firebase
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Imagenes_Vehiculos/$selectedVin.jpg');
      await storageRef.delete();

      // Actualizar la lista de VINs
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .get();
      List<String> vins = querySnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _vinList = vins;
        _vinControl.clear();
        _modeloControl.clear();
        _marcaControl.clear();
        _yearControl.clear();
        _motorControl.clear();
        _descripcionControl.clear();
        _nombreClienteControl.clear();
        _telefonoClienteControl.clear();
      });

      // Cerrar el diálogo
      Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      dialogos.Exito(
          context, 'Información eliminada del VIN: $selectedVin con éxito.');
    } catch (e) {
      // Manejar errores
      print('Error al eliminar el VIN: $e');
      dialogos.Error(context,
          'No es posible eliminar la información del VIN: $selectedVin.');
    }
  }

  Future<void> obtenercamara() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        Navigator.of(context).pop();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> obtenergaleria() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        Navigator.of(context).pop();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _mostraryears(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un año'),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<int>(
              value: int.tryParse(_yearControl.text) ?? years.first,
              items: years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _yearControl.text = value.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _actualizarinformacion() async {
    // Obtener los valores de los controles y eliminar espacios en blanco alrededor
    final vin = _vinControl.text.trim();
    final marca = _marcaControl.text.trim();
    final modelo = _modeloControl.text.trim();
    final year = _yearControl.text.trim();
    final motor = _motorControl.text.trim();
    final descripcion = _descripcionControl.text.trim();
    final nombreCliente = _nombreClienteControl.text.trim();
    final telefonoCliente = _telefonoClienteControl.text.trim();

    // Lista para almacenar los mensajes de error
    List<String> errores = [];

    // Validar el VIN
    if (vin.isEmpty || vin.length != 17) {
      errores.add('El VIN debe tener 17 caracteres.');
    }

    // Validar la marca
    if (marca.isEmpty) {
      errores.add('El campo Marca no puede estar vacío.');
    }

    // Validar el modelo
    if (modelo.isEmpty) {
      errores.add('El campo Modelo no puede estar vacío.');
    }

    // Validar el año
    if (year.isEmpty) {
      errores.add('El campo Año no puede estar vacío.');
    }

    // Validar el motor
    if (motor.isEmpty) {
      errores.add('El campo Motor no puede estar vacío.');
    }

    // Validar el nombre del cliente
    if (nombreCliente.isEmpty) {
      errores.add('El campo Nombre del Cliente no puede estar vacío.');
    }

    // Validar el número de teléfono
    if (telefonoCliente.isEmpty || telefonoCliente.length != 10) {
      errores.add('El Número de Teléfono debe tener 10 caracteres.');
    }

    // Mostrar mensajes de error si los hay
    if (errores.isNotEmpty) {
      dialogos.Error(context,
          "Por favor, complete los siguientes campos:\n${errores.join('\n')}");
      return; // Salir de la función si hay errores
    }

    // Verificar si hay una imagen nueva para subir
    String? imageUrl;
    if (_image != null) {
      try {
        // Subir nueva imagen a la base de datos
        final storageRef =
            FirebaseStorage.instance.ref().child('Imagenes_Vehiculos/$vin.jpg');
        final uploadTask = storageRef.putFile(_image!);
        final TaskSnapshot downloadUrl = await uploadTask;

        // Obtener la URL de la nueva imagen
        imageUrl = await downloadUrl.ref.getDownloadURL();
      } catch (error) {
        dialogos.Error(context, 'Error al cargar la imagen: $error');
        return; // Salir de la función si ocurre un error al cargar la imagen
      }
    }

    try {
      // Crear un mapa con los datos a actualizar
      Map<String, dynamic> updatedData = {
        'Marca': marca,
        'Modelo': modelo,
        'Año': year,
        'Motor': motor,
        'Descripcion': descripcion,
        'Nombre_cliente': nombreCliente,
        'Telefono_cliente': telefonoCliente,
      };

      // Agregar imageUrl solo si se ha subido una nueva imagen
      if (imageUrl != null) {
        updatedData['image_url'] = imageUrl;
      }

      // Actualizar los datos en la base de datos
      await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .update(updatedData);

      // Mostrar un mensaje de éxito
      dialogos.Exito(context, 'Información Actualizada Con Éxito');

      // Limpiar los controladores después de actualizar
      _vinControl.clear();
      _marcaControl.clear();
      _modeloControl.clear();
      _motorControl.clear();
      _yearControl.clear();
      _descripcionControl.clear();
      _nombreClienteControl.clear();
      _telefonoClienteControl.clear();

      // Ocultar los campos después de actualizar
      setState(() {
        _showVinOptions = false;
      });
    } catch (error) {
      // Mostrar un mensaje de error
      dialogos.Error(context, 'Error Al Actualizar La Información: $error');
    }
  }

  Widget buildOption(String text, IconData icon, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 1),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 17.5,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
                top: 70,
                child: Image.asset(
                  'assets/images/editar.png',
                  width: 250,
                  height: 250,
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                child: Text(
                  '2',
                  style: TextStyle(
                    fontFamily: 'Sathosi',
                    fontSize: 247,
                    color: primaryTextColor.withOpacity(0.10),
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
                        "Modificar/Eliminar Cliente",
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(color: Colors.black38),
                    const SizedBox(height: 25),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '*VIN:',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: GestureDetector(
                        onTap: _vinComboboxEnabled
                            ? () => _mostrarvin(context)
                            : null,
                        child: AbsorbPointer(
                          absorbing: !_vinComboboxEnabled,
                          child: TextFormField(
                            controller: _vinControl,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Selecciona un VIN',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              prefixIcon: const Icon(Icons.directions_car),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Visibility(
                      visible: _showVinOptions,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Center(
                                      child: Text(
                                        "Seleccionar Imagen Del Vehículo",
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          buildOption(
                                            "Tomar Foto",
                                            Icons.camera_alt,
                                            obtenercamara,
                                          ),
                                          const SizedBox(height: 8),
                                          buildOption(
                                            "Seleccionar De La Galería",
                                            Icons.image,
                                            obtenergaleria,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  imageUrl.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'Seleccionar Imagen Del Vehículo',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '*Marca:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 15),
                          Visibility(
                            visible: _showMarcaTextField,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: GestureDetector(
                                onTap: () => _mostrarmarcas(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _marcaControl,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      hintText: 'Selecciona una marca',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      suffixIcon: const Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '*Modelo:',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Visibility(
                            visible: _showModeloTextField,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: GestureDetector(
                                onTap: () => _mostrarmodelos(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _modeloControl,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      hintText: 'Selecciona un modelo',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      suffixIcon: const Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '*Año:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 15),
                          Visibility(
                            visible: _showYearTextField,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: GestureDetector(
                                onTap: () => _mostraryears(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _yearControl,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      hintText: 'Selecciona un año',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      suffixIcon: const Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '*Motor:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: TextFormField(
                              controller: _motorControl,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9.]')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Introducir motor',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: const Icon(FontAwesomeIcons.cogs),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Descripciones Adicionales:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: TextFormField(
                                  controller: _descripcionControl,
                                  maxLength: 300,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Introducir descripciones adicionales',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: const Icon(Icons.description),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 14),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 45),
                            child: Text(
                              'Información Del Cliente:',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  '*Nombre del Cliente:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: TextFormField(
                                  controller: _nombreClienteControl,
                                  maxLength: 30,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z\sñÑ]'))
                                  ], // Permite letras y espacios
                                  decoration: InputDecoration(
                                    hintText: 'Introducir nombre del cliente',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  '*Número de Celular:',
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: TextFormField(
                                  controller: _telefonoClienteControl,
                                  maxLength: 10,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Introducir número de celular',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _actualizarinformacion();
                                setState(() {
                                  _vinComboboxEnabled =
                                      true; // Activar el combobox del VIN después de actualizar
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                              ),
                              child: const Text(
                                'Actualizar Información',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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
