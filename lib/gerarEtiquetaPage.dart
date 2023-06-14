import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'firebase/firebase_options.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class gerarEtiqueta extends StatefulWidget {
  final int idCaixa;

  gerarEtiqueta({required this.idCaixa});

  @override
  _gerarEtiqueta createState() => _gerarEtiqueta();
}

class _gerarEtiqueta extends State<gerarEtiqueta> {
  List<Map<String, dynamic>> embalagem = [];
  @override
  void initState() {
    super.initState();
    buscarDadosEmbalagem(widget.idCaixa);
  }

  void buscarDadosEmbalagem(int idCaixa) {
    print(idCaixa);
    FirebaseFirestore.instance
        .collection("embalagem")
        .where("id", isEqualTo: idCaixa)
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
        appBar: AppBar(),
        body: PdfPreview(
          build: (format) => _generatePdf(format),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                  child: pw.Text('id embalagem',
                      style: pw.TextStyle(
                          fontSize: 55, fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  child: pw.Text('data Criacao',
                      style: pw.TextStyle(
                          fontSize: 55, fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  child: pw.Text('data validade',
                      style: pw.TextStyle(
                          fontSize: 55, fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  child: pw.Text('Funcioaniro',
                      style: pw.TextStyle(
                          fontSize: 55, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
