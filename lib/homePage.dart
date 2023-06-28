import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:teste_catalogo/historicoInfoPage.dart';
import 'historicoPage.dart';

class homePage extends StatefulWidget {
  @override
  _homePage createState() => _homePage();
}

class _homePage extends State<homePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> embalagens = [];
  List<Map<String, dynamic>> instrumentais = [];

  @override
  void initState() {
    super.initState();
    buscarCaixas();
    buscarInstrumentais();
  }

  int result = 0;
  
  Future<void> abrirScanner() async {
    String? scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (scannedCode != null) {
      int parsedResult = int.tryParse(scannedCode) ?? 0;
      setState(() {
        result = parsedResult;
        irParaHistorico(result);
      });
    }
  }

  Future<void> irParaHistorico(int result) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => historicoInfo(idEmbalagem: result),
      ),
    );}

  void buscarCaixas() {
    db.collection("embalagem").get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          embalagens = snapshot.docs
              .map((caixa) => caixa.data() as Map<String, dynamic>)
              .toList();
          embalagens.sort((a, b) =>
              a['id'].compareTo(b['id'])); // Sort by 'id' in ascending order
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as caixas: $error');
    });
  }

   void buscarInstrumentais() {
    db.collection("instrumentais").get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          instrumentais = snapshot.docs
              .map((instrumentais) => instrumentais.data() as Map<String, dynamic>)
              .toList();
          instrumentais.sort((a, b) =>
              a['id'].compareTo(b['id'])); // Sort by 'id' in ascending order
        });
      } else {
        print("Não foram encontradas instrumentais no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar instrumentais: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        'HOMEPAGE - CME',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text('Bem Vindo(a)!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            Container(
                height: 150,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.0,
                children: [
                  Container(
                    child: Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF6C1BC8),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Quantidade de embalagens:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${embalagens.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
           Container(
                    child: Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF6C1BC8),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Quantidade de instrumentais:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${instrumentais.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Outras colunas da sua grid...
                ],
              ),
            ),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => historicoPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Historico de Embalagens',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 10.0,
                                  backgroundColor: Color(0xFF6C1BC8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: ElevatedButton(
                                onPressed: () async {
                                  abrirScanner();
                                },
                                child: Text(
                                  'Ler Etiqueta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 10.0,
                                  backgroundColor: Color(0xFF6C1BC8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
