import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatito_manoso/widget/celda.dart';
import '../config/config.dart';

class Controles extends StatefulWidget {
  final Function(estados) actualizarEstadisticas;
  const Controles({required this.actualizarEstadisticas, Key? key}) : super(key: key);

  @override
  ControlesState createState() => ControlesState();
}

class ControlesState extends State<Controles> {
  estados inicial = estados.cruz;
  int contador = 0;
  List<estados> tablero = List.filled(9, estados.vacio);

  void actualizarTurno(estados nuevoTurno) {
    setState(() {
      inicial = nuevoTurno; // Actualiza el turno inicial
    });
  }

  @override
  Widget build(BuildContext context) {
    double tamanoTablero = MediaQuery.of(context).size.shortestSide * 0.9;

    return SizedBox(
      width: tamanoTablero,
      height: tamanoTablero,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Celda(
                    inicial: tablero[0],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(0),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[1],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(1),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[2],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Celda(
                    inicial: tablero[3],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(3),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[4],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(4),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[5],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Celda(
                    inicial: tablero[6],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(6),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[7],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(7),
                  ),
                ),
                Expanded(
                  child: Celda(
                    inicial: tablero[8],
                    alto: tamanoTablero / 3,
                    ancho: tamanoTablero / 3,
                    press: () => press(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void press(int index) {
    if (tablero[index] == estados.vacio) {
      tablero[index] = inicial;
      inicial = inicial == estados.cruz ? estados.circulo : estados.cruz;
      setState(() {});
      if (++contador >= 5) {
        estados? ganador = verificarGanador();
        if (ganador != null) {
          mostrarDialogoFin(ganador);
        } else if (contador == 9) {
          mostrarDialogoFin(estados.vacio); // Empate
        }
      }
    }
  }

  estados? verificarGanador() {
    for (int i = 0; i < 9; i += 3) {
      if (iguales(i, i + 1, i + 2)) return tablero[i];
    }
    for (int i = 0; i < 3; i++) {
      if (iguales(i, i + 3, i + 6)) return tablero[i];
    }
    if (iguales(0, 4, 8)) return tablero[0];
    if (iguales(2, 4, 6)) return tablero[2];
    return null;
  }

  bool iguales(int a, int b, int c) {
    if (tablero[a] != estados.vacio) {
      if (tablero[a] == tablero[b] && tablero[b] == tablero[c]) {
        return true;
      }
    }
    return false;
  }

  void mostrarDialogoFin(estados ganador) {
    String mensaje;
    if (ganador == estados.cruz) {
      mensaje = "¡Las X ganaron!";
    } else if (ganador == estados.circulo) {
      mensaje = "¡Los O ganaron!";
    } else {
      mensaje = "¡Es un empate!";
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Juego Terminado'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.actualizarEstadisticas(ganador);
                reiniciarTablero();
              },
            ),
            TextButton(
              child: Text('Salir'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.actualizarEstadisticas(ganador);
                salirJuego();
              },
            ),
          ],
        );
      },
    );
  }

  void reiniciarTablero() {
    setState(() {
      tablero = List.filled(9, estados.vacio);
      contador = 0;
    });
  }

  void salirJuego() {
    SystemNavigator.pop();
  }

  void actualizarTablero(List<String> nuevoTablero, estados nuevoTurno) {
    setState(() {
      tablero = nuevoTablero.map((e) => estados.values.firstWhere((element) => element.toString() == e)).toList();
      contador = tablero.where((estado) => estado != estados.vacio).length; // Actualizar el contador
      inicial = nuevoTurno; // Actualizar el turno
    });
  }
}