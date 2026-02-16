//clase para la creación de la lista de opciones del menú principal
class Appinfo {
  final int position;
  final String name;
  final String iconImage;

  Appinfo(
    this.position, {
    required this.name,
    required this.iconImage,
  });
}

//lista de opciones del menú principal
List<Appinfo> opciones = [
  Appinfo(1,
      name: 'Registro de información', iconImage: 'assets/images/usuario.png'),
  Appinfo(2,
      name: 'Modificar/Eliminar Cliente',
      iconImage: 'assets/images/editar.png'),
  Appinfo(3,
      name: 'Registro Reparaciones Y Garantías',
      iconImage: 'assets/images/agregarhe.png'),
  Appinfo(4,
      name: 'Modificar/Eliminar Reparaciones Y Garantías',
      iconImage: 'assets/images/editarh.png'),
  Appinfo(5, name: 'Consulta Garantías', iconImage: 'assets/images/consul.png'),
  Appinfo(6, name: 'Salir', iconImage: 'assets/images/Salida.png'),
];
