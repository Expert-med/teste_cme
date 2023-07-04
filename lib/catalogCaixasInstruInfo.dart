import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class instruInfo extends StatefulWidget {
  final String idInstru;

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

  String get idInstru => widget.idInstru;

  @override
  void initState() {
    super.initState();
    buscarInstrumentais(idInstru);
   
  }


  Future<List<String>> searchImages(String idInstru) async {
    final ListResult result = await storage.ref('instrumentais').listAll();

    final List<String> imageUrls = [];

    for (final Reference ref in result.items) {
      final String fileName = ref.name;

      if (fileName.contains('$idInstru')) {
        final String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
        print(downloadUrl);
      }
    }

    return imageUrls;
  }



  void buscarTipoInstrumental(String idTipo) {
    print('entrou em buscarTipoInstrumental ');
    FirebaseFirestore.instance
        .collection("tipo_instrumental")
        .where("id", isEqualTo: idTipo)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          tipos = snapshot.docs.map((tipo) => tipo.data() as Map<String, dynamic>).toList();
        });
      } else {
        print("Não foram encontrados tipos de instrumentais no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar os tipos de instrumentais: $error');
    });
  }

    void buscarInstrumentais(String idInstru) {
    FirebaseFirestore.instance
        .collection("instrumentais")
        .where("id", isEqualTo: idInstru)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          caixas = snapshot.docs.map((caixa) => caixa.data() as Map<String, dynamic>).toList();
          if (caixas.isNotEmpty) {
            String idTipo = caixas[0]['tipo'].toString(); // Convert idTipo to String
            buscarTipoInstrumental(idTipo); // Pass idTipoString to buscarTipoInstrumental
          } else {
            print("A lista de caixas está vazia.");
          }
        });
      } else {
        print("Não foram encontradas caixas no banco de dados");
      }
    }).catchError((error) {
      print('Erro ao buscar os instrumentais: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,
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
                          fontSize: 20,
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
              String idTipo = caixas[0]['tipo'].toString();
              String nome = caixa['nome'];

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
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              idTipo != null ? '$idTipo' : 'N/A',
                              style: TextStyle(
                                fontSize: 20,
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
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ': ${nome[0].toUpperCase()}${nome.substring(1)}',
                              style: TextStyle(
                                fontSize: 20,
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
                              fontSize: 20,
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
                        child: FutureBuilder<List<String>>(
                          future: searchImages(idInstru),
                          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                            if (snapshot.hasData) {
                              List<String> imageUrls = snapshot.data!;
                              // Render the images using ListView.builder
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(), // Disable scrolling of the ListView.builder
                                itemCount: imageUrls.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String imageUrl = imageUrls[index];
                                  return Image.network(imageUrl);
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error loading image');
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
                String idTipo = tipo['id'] as String;
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
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                ': ${nomeTipo[0].toUpperCase()}${nomeTipo.substring(1)} (Id: ${idTipo ?? 'N/A'})',
                                style: TextStyle(
                                  fontSize: 20,
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
