//import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'firebase/firebase_options.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class gerarEtiqueta extends StatefulWidget {
  final int idEmbalagem;

  gerarEtiqueta({required this.idEmbalagem});

  @override
  _gerarEtiquetaState createState() => _gerarEtiquetaState();
}

class _gerarEtiquetaState extends State<gerarEtiqueta> {
  List<Map<String, dynamic>> embalagem = [];

  @override
  void initState() {
    super.initState();
    buscarDadosEmbalagem(widget.idEmbalagem as int);
  }

  void buscarDadosEmbalagem(int id) {
    print(id);
    FirebaseFirestore.instance
        .collection("embalagem")
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          embalagem.add(snapshot.docs[0].data() as Map<String, dynamic>);
          int idCaixa = embalagem[0]['idCaixa'];
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as embalagens: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Color.fromARGB(156, 0, 107, 57),
          flexibleSpace: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30, bottom: 30),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          'Etiqueta gerada',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
            },
          ),
        ),
        body: PdfPreview(
          build: (format) => generatePdfWithDatabaseData(format),
        ),
      ),
    );
  }

  Future<Uint8List> generatePdfWithDatabaseData(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    print(embalagem);
    if (embalagem.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  
                  child: pw.Text(
                    'Id embalagem: ${embalagem[0]['id']}',
                    style: pw.TextStyle(
                        fontSize: 50, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  child: pw.Text(
                    'Data Criação: ${embalagem[0]['infoAdicionais']['dataAtual']}',
                    style: pw.TextStyle(
                        fontSize: 50, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  child: pw.Text(
                    'Data validade: ${embalagem[0]['infoAdicionais']['dataValidade']}',
                    style: pw.TextStyle(
                        fontSize: 50, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Container(
                  child: pw.Text(
                    'Funcionário: ${embalagem[0]['infoAdicionais']['nomeFuncionario']}',
                    style: pw.TextStyle(
                        fontSize: 50, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    } else {
      print('Nao achei');
    }

    return pdf.save();
  }
}
