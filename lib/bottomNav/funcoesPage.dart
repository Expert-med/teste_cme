import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'package:teste_catalogo/autenticacao/usuarios/login_page.dart';
import 'package:teste_catalogo/historicoInfoPage.dart';
import 'package:teste_catalogo/historicoPage.dart';


class FuncoesPage extends StatefulWidget {
  @override
  _FuncoesPage createState() => _FuncoesPage();
}

class _FuncoesPage extends State<FuncoesPage> {
   int result = 0;

  Future<void> abrirScanner() async {
    print('abri');
    String? scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    print(scannedCode);
    if (scannedCode != null) {
      int parsedResult = int.tryParse(scannedCode) ?? 0;
      setState(() {
        result = parsedResult;
        irParaHistorico(result);
      });
    }
  }

  Future<void> irParaHistorico(int result) async {
    print('cheguei');
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => historicoInfo(idEmbalagem: result),
      ),
    );}

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
            SizedBox(height: 50,),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginFunPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Pagina Login Fun',
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
           
          ],
        ),
      ),
    );
  }
}
