import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  /*
  List<Incidencia> buscar(String texto) {
    if (texto.trim().isEmpty) return incidencias;
    return incidencias.where((x) => x.titulo.contains(texto)).toList();
  }
  */
  List<Incidencia> buscar(String texto, String estado, String nivel) {
    // convertir el texto de búsqueda a minúsculas y eliminar espacios en blanco al inicio y al final
    final consulta = texto.trim().toLowerCase();

    // if (consulta.isEmpty) {
    //   return incidencias;
    // }
    
    // filtrar las incidencias que contengan el texto de búsqueda en el título o la descripción
    return incidencias.where((x) {
      // este para el titulo
      final titulo = x.titulo.toLowerCase();
      // este para la descripcion
      final descripcion = x.descripcion.toLowerCase();

      // para el texto, si está vacío, se consideran todas las incidencias.
      final textoCoincide = consulta.isEmpty ||
        titulo.contains(consulta) ||
        descripcion.contains(consulta);

      // para el estado, si no pone se consideran todos los estados
      final estadoCoincide = estado == 'Todos' || x.estado == estado;

      // para el nivel, si no pone se consideran todos los niveles
      final nivelCoincide = nivel == 'Todos' || x.nivel == nivel;

      // encontar coincidencias en el título o la descripción y que el estado y nivel coincidan
      return textoCoincide &&
          estadoCoincide &&
          nivelCoincide;
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    // if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        // guarda los cambios en el almacenamiento local, asi la funcion "crear" tambien lo hace
        await datos.guardar(incidencias);
        break;
      }
    }
  }

  Future<void> cambiarNivel(String id, String nivel) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].nivel = nivel;
        // guarda los cambios en el almacenamiento local, asi la funcion "crear" tambien lo hace
        await datos.guardar(incidencias);
        break;
      }
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, String nivel) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      nivel: nivel,
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
