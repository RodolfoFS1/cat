library config.globals;

enum estados { vacio, cruz, circulo }
estados inicial = estados.cruz;

List<estados> tablero = List.filled(9, estados.vacio);
Map<estados, bool> resultado = {estados.cruz: false, estados.circulo: false};