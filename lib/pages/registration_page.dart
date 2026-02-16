//clase de la pagina de registros de vehiculos
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use, non_constant_identifier_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warranty_auto_manager/constants.dart';
import 'package:warranty_auto_manager/data.dart';
import 'package:warranty_auto_manager/dialogos.dart';

class DetailPage extends StatefulWidget {
  final Appinfo appinfo;

  const DetailPage({super.key, required this.appinfo});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  File? _imagen;
  final TextEditingController _vinControl = TextEditingController();
  final TextEditingController _marcaControl = TextEditingController();
  final TextEditingController _modeloControl = TextEditingController();
  final TextEditingController _motorControl = TextEditingController();
  final TextEditingController _yearControl = TextEditingController();
  final TextEditingController _descripcionControl = TextEditingController();
  final TextEditingController _nombreClienteControl = TextEditingController();
  final TextEditingController _telefonoClienteControl = TextEditingController();
  bool _VinValido = true;

  final picker = ImagePicker(); // Instancia de ImagePicker

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

  List<String> modelosActuales = []; // Modelos actuales para la marca seleccionada

  @override
  void initState() {
    super.initState();
    _vinControl.text = ''; // VIN inicialmente vacío
    _marcaControl.text = ''; // Marca inicialmente vacía
    _yearControl.text = ''; // Marca inicialmente vacía
    marcas.sort(); // Ordenar las marcas alfabéticamente
  }

  @override
  void dispose() {
    _vinControl.dispose();
    _marcaControl.dispose();
    _modeloControl.dispose(); // Dispose de los controladores
    _motorControl.dispose();
    _yearControl.dispose();
    _descripcionControl.dispose();
    _nombreClienteControl.dispose();
    _telefonoClienteControl.dispose();
    super.dispose();
  }

//Obtener imagen de la camara
  Future obtenerimagencamara() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imagen = File(pickedFile.path);
        Navigator.of(context).pop();
      } else {
        print('Imagen no seleccionada.');
      }
    });
  }

//Obtener imagen de la galeria
  Future obtenerimagengaleria() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagen = File(pickedFile.path);
        Navigator.of(context).pop();
      } else {
        print('Imagen no seleccionada.');
      }
    });
  }
//Opcion de imagen
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
              items: modelosActuales.map((modelo) {
                return DropdownMenuItem<String>(
                  value: modelo,
                  child: Text(modelo),
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
//Opcion de marca
  Future<void> _mostrarmarca(BuildContext context) async {
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
//Opcion de año
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
//Registrar la información
  Future<void> _registrarinformacion() async {
    // Obtener los valores de los controles y eliminar espacios en blanco alrededor
    final vin = _vinControl.text.toUpperCase().trim();
    final marca = _marcaControl.text.trim();
    final modelo = _modeloControl.text.trim();
    final year = _yearControl.text.trim();
    final motor = _motorControl.text.trim();
    final descripcion = _descripcionControl.text.trim();
    final nombreCliente = _nombreClienteControl.text.trim();
    final telefonoCliente = _telefonoClienteControl.text.trim();

    // Lista para almacenar los mensajes de error
    List<String> errores = [];

    // Verificar la longitud del VIN
    if (vin.length != 17) {
      errores.add('El VIN debe tener 17 caracteres.');
    }

    // Verificar la longitud del número de teléfono
    if (telefonoCliente.length != 10) {
      errores.add('El Número de Teléfono debe tener 10 caracteres.');
    }

    // Verificar si algún campo está vacío y agregar el mensaje de error correspondiente
    if (marca.isEmpty) {
      errores.add('El campo Marca no puede estar vacío.');
    }
    if (modelo.isEmpty) {
      errores.add('El campo Modelo no puede estar vacío.');
    }
    if (year.isEmpty) {
      errores.add('El campo Año no puede estar vacío.');
    }
    if (motor.isEmpty) {
      errores.add('El campo Motor no puede estar vacío.');
    }
    if (nombreCliente.isEmpty) {
      errores.add('El campo Nombre del Cliente no puede estar vacío.');
    }
    if (_imagen == null) {
      errores.add('Debe seleccionar una imagen.');
    }

    // Mostrar mensajes de error si los hay
    if (errores.isNotEmpty) {
      dialogos.Error(context,
          "Por favor, complete los siguientes campos:\n${errores.join('\n')}");
      return; // Salir de la función si hay errores
    }

    try {
      // Subir imagen a la base de datos
      final storageRef =
          FirebaseStorage.instance.ref().child('Imagenes_Vehiculos/$vin.jpg');
      final uploadTask = storageRef.putFile(_imagen!);
      final TaskSnapshot downloadUrl = await uploadTask;

      // Obtener la URL de la imagen
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      // Guardar los datos en la base de datos
      await FirebaseFirestore.instance
          .collection('Informacion_Vehiculos')
          .doc(vin)
          .set({
        'Marca': marca,
        'Modelo': modelo,
        'Año': year,
        'Motor': motor,
        'Descripcion': descripcion,
        'image_url': imageUrl,
        'Nombre_cliente': nombreCliente,
        'Telefono_cliente': telefonoCliente,
      });

      // Mostrar un mensaje de éxito
      dialogos.Exito(context, 'Información Registrada Con Éxito');

      // Limpiar todos los campos y restablecer la imagen seleccionada
      _vinControl.clear();
      _marcaControl.clear();
      _modeloControl.clear();
      _motorControl.clear();
      _yearControl.clear();
      _descripcionControl.clear();
      _nombreClienteControl.clear();
      _telefonoClienteControl.clear();
      _imagen = null;
      setState(() {});
    } catch (error) {
      // Mostrar un mensaje de error si ocurre un error
      dialogos.Error(context, 'Error Al Registrar La Información');
    }
  }
//Opcion de imagen
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
                  'assets/images/usuario.png',
                  width: 250,
                  height: 250,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 300),
                    Center(
                      child: Text(
                        widget.appinfo.name,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(color: Colors.black38),
                    const SizedBox(height: 32),
                    const SizedBox(height: 3),
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
                                      obtenerimagencamara,
                                    ),
                                    const SizedBox(height: 8),
                                    buildOption(
                                      "Seleccionar De La Galería",
                                      Icons.image,
                                      obtenerimagengaleria,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      // Contenedor de la imagen
                      child: Container(
                        key: ValueKey(_imagen),
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
                            _imagen == null // ¿La imagen es nula?
                                ? const Center(
                                    child: Text(
                                      '*Seleccionar Imagen Del Vehículo',
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Image.file(_imagen!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '*VIN:',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextFormField(
                        controller: _vinControl,
                        maxLength: 17,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Introducir VIN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _VinValido ? Colors.green : Colors.red,
                            ),
                          ),
                          suffixIcon: const Icon(Icons.directions_car),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _VinValido = value.length == 17;
                            _vinControl.value = _vinControl.value.copyWith(
                              text: value.toUpperCase(),
                              selection:
                                  TextSelection.collapsed(offset: value.length),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '*Marca:',
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: GestureDetector(
                        onTap: () => _mostrarmarca(context),
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
                    const SizedBox(height: 35),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
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
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: GestureDetector(
                        onTap: _marcaControl.text.isNotEmpty
                            ? () => _mostrarmodelos(context) // Mostrar modelos si la marca no está vacía
                            : null, // No hacer nada si la marca está vacía
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
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '*Año:',
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    const SizedBox(height: 35),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '*Motor:',
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextFormField(
                        controller: _motorControl,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9.]')), // Permite letras, números y puntos
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextFormField(
                        controller: _descripcionControl,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText: 'Introducir descripciones adicionales',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(Icons.description),
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
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
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextFormField(
                        controller: _telefonoClienteControl,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
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
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _registrarinformacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                        ),
                        child: const Text(
                          'Registrar Información',
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
              Positioned(
                top: 10,
                left: 5,
                child: Text(
                  "1",
                  style: TextStyle(
                    fontFamily: 'Sathosi',
                    fontSize: 247,
                    color: primaryTextColor.withOpacity(0.10),
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
}

class UpperCaseTextEditingController extends TextEditingController {
  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText.toUpperCase(),
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }
}
