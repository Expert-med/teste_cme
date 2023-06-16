import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class instruInfo extends StatefulWidget {
  final int idInstru;

  instruInfo({required this.idInstru});

  @override
  _instruInfo createState() => _instruInfo();
}

class _instruInfo extends State<instruInfo> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> caixas = [];
  List<Map<String, dynamic>> tipos = [];
 
 
final storage = FirebaseStorage.instanceFor(bucket: "gs://teste-teste-a8d80.appspot.com");

final storageRef = FirebaseStorage.instance.ref();

int get idInstru => widget.idInstru;

  @override
  void initState() {
    super.initState();
  
    buscarInstrumentais(widget.idInstru);
   
  }
  
  

 Future<String> buscarPathImagem(int idInstru) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("instrumentais")
      .where("id", isEqualTo: idInstru)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs[0].data();
    if (data.containsKey("img")) {
      return data["img"];
    }
  }
  throw Exception('Image path not found.');
}


  Future<String> buscarImagem(int idInstru) async {
  String imagePath = await buscarPathImagem(idInstru);
  final ref = storageRef.child(imagePath);
  return await ref.getDownloadURL();
}

  void buscarInstrumentais(int idInstru) {
    print(idInstru);

   
    FirebaseFirestore.instance
        .collection("instrumentais")
        .where("id", isEqualTo: idInstru)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          caixas = snapshot.docs
              .map((caixa) => caixa.data() as Map<String, dynamic>)
              .toList();
          int idTipo = caixas[0]['tipo'];
          buscarTipoInstrumental(idTipo);
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as caixas: $error');
    });
  }

  void buscarTipoInstrumental(int idTipo) {
 
    FirebaseFirestore.instance
        .collection("tipo_instrumental")
        .where("id", isEqualTo: idTipo)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          tipos = snapshot.docs
              .map((tipo) => tipo.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        print(
            "Não foram encontrados tipos de instrumentais no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar os tipos de instrumentais: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        toolbarHeight: 300,
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
              padding: EdgeInsets.only(left: 30, bottom: 30),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'INFORMAÇÕES ADICIONAIS',
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: caixas.map((caixa) {
              int id = caixa['id'];
              String nome = caixa['nome'];
              int idTipo = caixa['tipo'];

              return Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$id',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome do Instrumental: ',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ': ${nome[0].toUpperCase()}${nome.substring(1)}',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imagem: ',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: FutureBuilder(
                          future: buscarImagem(idInstru),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(snapshot.data!);
                            } else if (snapshot.hasError) {
                              return Text('Erro ao carregar a imagem');
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
              ..addAll(tipos.map((tipo) {
                int idTipo = tipo['id'];
                String nomeTipo = tipo['nome'];
                // Restante do código para renderizar os dados do tipo

                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo Instrumental: ',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                ': ${nomeTipo[0].toUpperCase()}${nomeTipo.substring(1)} (Id: $idTipo)',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Restante do código para renderizar os dados do tipo
                      ],
                    ),
                  ),
                );
              }).toList()),
          ),
        ),
      ),
    );
  }
}
