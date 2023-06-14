
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase/firebase_options.dart';


class gerarEtiqueta extends StatefulWidget {
  final int idCaixa;

  gerarEtiqueta({required this.idCaixa});

  @override
  _gerarEtiqueta createState() => _gerarEtiqueta();
}

class _gerarEtiqueta extends State<gerarEtiqueta> {

  @override
  Widget build(BuildContext context) {

     return Scaffold(appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255),
          size: 32,
        ),
        elevation: 0,
        title: Text(
          'Etiqueta',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Text('teste'),);
  }

}