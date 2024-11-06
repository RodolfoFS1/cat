import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/config.dart';
import '../database/database.dart';
import 'controles.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ControlesState> _controlesKey = GlobalKey<ControlesState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<String> partidasGuardadas = [];
  String? partidaSeleccionada;
  bool mostrarPartidas = false;

  int victoriasX = 0;
  int victoriasO = 0;
  int empates = 0;
  List<String> tablero = List.filled(9, estados.vacio.toString());
  estados turnoActual = estados.cruz; // Almacena el turno actual

  @override
  void initState() {
    super.initState();
    cargarPartidasGuardadas();
  }

  Future<void> cargarPartidasGuardadas() async {
    List<String> partidas = await _dbHelper.getPartidasGuardadas();
    setState(() {
      partidasGuardadas = partidas;
    });
  }

  Future<void> cargarEstadisticas(String partida) async {
    Map<String, dynamic> datos = await _dbHelper.obtenerEstadisticas(partida);
    setState(() {
      victoriasX = datos['victoriasX'] ?? 0;
      victoriasO = datos['victoriasO'] ?? 0;
      empates = datos['empates'] ?? 0;
      tablero = List<String>.from(datos['tablero'] ?? List.filled(9, estados.vacio.toString()));
      turnoActual = estados.values.firstWhere((element) => element.toString() == datos['turno']); // Cargar el turno
    });
    _controlesKey.currentState?.actualizarTurno(turnoActual); // Actualizar el turno en Controles
  }

  Future<void> guardarPartida(String nombrePartida) async {
    try {
      await _dbHelper.guardarPartida(nombrePartida, victoriasX, victoriasO, empates, tablero, turnoActual.toString());
      await cargarPartidasGuardadas();
    } catch (e) {
      print("Error al guardar la partida: $e");
    }
  }

  void actualizarEstadisticas(estados ganador) {
    setState(() {
      if (ganador == estados.cruz) {
        victoriasX++;
      } else if (ganador == estados.circulo) {
        victoriasO++;
      } else {
        empates++;
      }
      // Actualiza el turno actual
      turnoActual = ganador == estados.cruz ? estados.circulo : estados.cruz; // Alterna el turno
    });
  }

  void reiniciarJuego() {
    setState(() {
      tablero = List.filled(9, estados.vacio.toString());
      _controlesKey.currentState?.reiniciarTablero();
      victoriasX = 0;
      victoriasO = 0;
      empates = 0;
    });
  }

  void nuevoJuego() {
    setState(() {
      tablero = List.filled(9, estados.vacio.toString());
      victoriasX = 0;
      victoriasO = 0;
      empates = 0;
      _controlesKey.currentState?.reiniciarTablero();
      turnoActual = estados.cruz; // Reinicia el turno
    });
  }

  void mostrarDialogoGuardar() {
    TextEditingController nombreController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guardar Partida'),
          content: TextField(
            controller: nombreController,
            decoration: InputDecoration(hintText: 'Nombre de la partida'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (nombreController.text.isNotEmpty) {
                  await guardarPartida(nombreController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoCargarPartida() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog (
          title: Text('Cargar Partida'),
          content: DropdownButton<String>(
            hint: Text('Partida'),
            value: partidaSeleccionada,
            items: partidasGuardadas.map((String partida) {
              return DropdownMenuItem<String>(
                value: partida,
                child: Text(partida),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                partidaSeleccionada = newValue;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cargar'),
              onPressed: () {
                if (partidaSeleccionada != null) {
                  cargarEstadisticas(partidaSeleccionada!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoConfirmacion(String accion, Function() callback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Desea $accion?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop();
                callback();
              },
            ),
          ],
        );
      },
    );
  }

  void salirJuego() {
    SystemNavigator.pop();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Por mi pierna rota'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'nuevo') {
                mostrarDialogoConfirmacion('empezar un juego nuevo', nuevoJuego);
              } else if (result == 'reiniciar') {
                mostrarDialogoConfirmacion('reiniciar la partida', reiniciarJuego);
              } else if (result == 'cargar') {
                mostrarDialogoCargarPartida();
              } else if (result == 'salir') {
                mostrarDialogoConfirmacion('salir', salirJuego);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'nuevo',
                child: Text('Juego Nuevo'),
              ),
              const PopupMenuItem<String>(
                value: 'reiniciar',
                child: Text('Reiniciar partida'),
              ),
              const PopupMenuItem<String>(
                value: 'cargar',
                child: Text('Cargar partida'),
              ),
              const PopupMenuItem<String>(
                value: 'salir',
                child: Text('Salir'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "images/board.png",
                  fit: BoxFit.cover,
                ),
                Controles(
                  key: _controlesKey,
                  actualizarEstadisticas: actualizarEstadisticas,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Victorias X: $victoriasX'),
              Text('  Victorias O: $victoriasO'),
              Text('  Empates: $empates'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  mostrarDialogoConfirmacion('guardar la partida', mostrarDialogoGuardar);
                },
              ),
              IconButton(
                icon: Icon(Icons.folder_open),
                onPressed: () {
                  mostrarDialogoCargarPartida();
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  mostrarDialogoConfirmacion('reiniciar el juego', reiniciarJuego);
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  mostrarDialogoConfirmacion('empezar un juego nuevo', nuevoJuego);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}