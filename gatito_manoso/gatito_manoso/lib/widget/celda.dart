import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gatito_manoso/config/config.dart';

class Celda extends StatelessWidget {
  final estados inicial;
  final double ancho, alto;
  final Function() press;
  const Celda(
      {required this.inicial,
        required this.ancho,
        required this.press,
        required this.alto,
        super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: alto,
      width: ancho,
      child: CupertinoButton(
        onPressed: press,
        child: mostrar(),
      ),
    );
  }

  Widget mostrar() {
    if (inicial == estados.vacio) {
      return SizedBox(height: alto, width: ancho);
    }
    if (inicial == estados.circulo) {
      return Image.asset("images/o.png");
    } else {
      return Image.asset("images/x.png");
    }
  }
}