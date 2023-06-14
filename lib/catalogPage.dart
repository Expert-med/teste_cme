// home -  Botao criar embalagem

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teste_catalogo/catalogTeste.dart';
import 'package:teste_catalogo/catalogTipoCaixa.dart';
import 'package:teste_catalogo/tipoPage.dart';

import 'catalogoCaixasTeste.dart';
import 'formCriarCaixas.dart';
import 'historicoPage.dart';

class catalogPage extends StatelessWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;

  late int idAtual = 0;
  List<Map<String, dynamic>> instrumentaisList = [];

  Future<int> adicionarEmbalagem() async {
    QuerySnapshot snapshot = await db
        .collection("embalagem")
        .orderBy("id", descending: true)
        .limit(1)
        .get()
        .catchError((error) => print('Erro ao obter ID: $error'));

    if (snapshot.docs.isNotEmpty) {
      int latestId = snapshot.docs[0]["id"];
      /*latestId=0;
      idAtual=0;*/

      idAtual = latestId + 1;
    } else {
      idAtual = 1; // Caso não exista nenhum documento, começa com ID 1
    }

    final embalagem = <String, dynamic>{
      "id": idAtual,
    };

    DocumentReference documentRef =
        db.collection("embalagem").doc(idAtual.toString());

    await documentRef
        .set(embalagem)
        .catchError((error) => print('Erro ao adicionar dados: $error'));

    return idAtual;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 300,
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
                    Text(
                      'CatalogPage - CME',
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              //Catalogo 1
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {

                               // int idEmb = await adicionarEmbalagem();

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'O que você deseja fazer?',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: Text(
                                        'Escolha uma das opções abaixo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          24,
                                          30,
                                          30,
                                          10), 
                                     
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            adicionarEmbalagem();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CatalogoCaixasTeste()),
                                            );
                                          },
                                          child: Text(
                                            'Buscar caixa',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(156, 0, 107, 57),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            adicionarEmbalagem();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      formCriarCaixas()),
                                            );
                                          },
                                          child: Text(
                                            
                                            'Criar caixa',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(156, 0, 107, 57),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            adicionarEmbalagem();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      catalogoTeste()),
                                            );
                                          },
                                          child: Text(
                                            'Apenas embalar',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(156, 0, 107, 57),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Iniciar embalagem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 10.0,
                                backgroundColor:
                                    Color.fromARGB(156, 0, 107, 57),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                child: Padding(padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                child: Text('O histórico não aparece caso algum dado de embalagem não esteja preenchido!'),),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
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
                                backgroundColor:
                                    Color.fromARGB(156, 0, 107, 57),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
