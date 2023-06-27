import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class gerarEtiqueta extends StatefulWidget {
  final int idEmbalagem;

  gerarEtiqueta({required this.idEmbalagem});

  @override
  _gerarEtiquetaState createState() => _gerarEtiquetaState();
}

class _gerarEtiquetaState extends State<gerarEtiqueta> {
  List<Map<String, dynamic>> embalagem = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
     int _imprimiuController = 0;



  @override
  void initState() {
    super.initState();
    buscarDadosEmbalagem(widget.idEmbalagem);
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
    final String qrCode = '/historicoInfo';
    final int idEmbalagem =
        embalagem.isNotEmpty ? embalagem[0]['id'] : 0;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Color.fromARGB(156, 0, 107, 57),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0066e2),
                  Color(0xFF6C1BC8),
                ],
                stops: [0, 1],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 50, bottom: 30),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ETIQUETA GERADA',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
             showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Deseja Imprimir?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _imprimiuController = 1;
                                  processoImprimiu(_imprimiuController);

                                   Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Text('Sim',style:TextStyle(color: Color(0xFF6C1BC8),)),
                              ),
                              TextButton(
                                onPressed: () {
                                  _imprimiuController = 0;
                                  processoImprimiu(_imprimiuController);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Text('Não',style:TextStyle(color: Color(0xFF6C1BC8),)),
                              ),
                            ],
                          );
                        },
                      );
            },
          ),
        ),
        body: Container(
          color: Colors.purple, // Define the desired background color here
          child: PdfPreview(
            allowPrinting: true,
            allowSharing: false,
            canChangePageFormat: true,
            canChangeOrientation: false,
            build: (format) =>
                generatePdfWithDatabaseData(format, qrCode, idEmbalagem),
          ),
        ),
      ),
    );
  }

  Future<Uint8List> generatePdfWithDatabaseData(
      PdfPageFormat format, String qrCode, int idEmbalagem) async {

    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    if (embalagem.isNotEmpty) {
      final String qrCodeData =
          '$qrCode?route=/historicoInfo&idEmbalagem=$idEmbalagem';

      

      pdf.addPage(
        pw.Page(
          pageFormat: format.copyWith(
            width: format.height,
            height: format.width,
          ),
          build: (context) {
            final embalagemData = embalagem[0]['infoAdicionais'];
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Data Criação: ${embalagem[0]['infoAdicionais']['dataAtual']}',
                          style: pw.TextStyle(
                            fontSize: 50,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  child: pw.Text(
                    'Data validade: ${embalagem[0]['infoAdicionais']['dataValidade']}',
                    style: pw.TextStyle(
                      fontSize: 50,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  child: pw.Text(
                    'Funcionário: ${embalagem[0]['infoAdicionais']['nomeFuncionario']}',
                    style: pw.TextStyle(
                      fontSize: 50,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Id embalagem: $idEmbalagem',
                          style: pw.TextStyle(
                            fontSize: 50,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 30.0),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrCodeData,
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      print('Não encontrei a embalagem');
    }

    return pdf.save();
  }

  void processoImprimiu(int imprimiu) {
    db
        .collection("embalagem")
        .orderBy("id", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        int latestId = snapshot.docs[0]["id"];
        String documentId = snapshot.docs[0].id;

        DocumentReference documentRef =
            db.collection("embalagem").doc(documentId);

        documentRef.update({"imprimiu": imprimiu}).then((_) {
          print("imprimiu adicionado com sucesso");
        }).catchError((error) {
          print("Erro ao adicionar imprimiu: $error");
        });
      } else {
        print("A tabela Embalagem está vazia.");
      }
    }).catchError((error) {
      print('Erro ao obter a embalagem mais recente: $error');
    });
  }
}


