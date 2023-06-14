//pagina de testes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:teste_catalogo/catalogoCaixas.dart';

class catalogoTeste extends StatefulWidget {



  @override
  _catalogoTeste createState() => _catalogoTeste();
}

class _catalogoTeste extends State<catalogoTeste> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  late int idAtual = 0;
  List<Map<String, dynamic>> instrumentaisList = [];

  int adicionarEmbalagem() {
    db
        .collection("embalagem")
        .orderBy("id", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        int latestId = snapshot.docs[0]["id"];
        /*latestId=0;
      idAtual=0;*/
        idAtual = latestId + 1;
      }
    }).catchError((error) => print('Erro ao obter ID: $error'));

    final embalagem = <String, dynamic>{
      "id": idAtual,
    };

    DocumentReference documentRef =
        db.collection("embalagem").doc(idAtual.toString());

    documentRef
        .set(embalagem)
        .catchError((error) => print('Erro ao adicionar dados: $error'));

    return idAtual;
  }

  void obterDados(String documentId) {
    db
        .collection("instrumentais")
        .doc(documentId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Dados Encontrados'),
              content: Text(
                  'ID da Embalagem: ${dados['idEmbalagem']}, Instrumento: ${dados['instrumental']}'),
              actions: [
                TextButton(
                  child: Text('Fechar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Documento não encontrado');
      }
    }).catchError((error) => print('Erro ao obter dados: $error'));
  }

  String documentId = '';
  void removerDados(String documentId) {
    db
        .collection("embalagem")
        .doc(documentId)
        .delete()
        .then((_) => print('Documento removido com sucesso'))
        .catchError((error) => print('Erro ao remover documento: $error'));
  }

/*
void listarDadosInstrumentais() {
  FirebaseFirestore.instance
      .collection("instrumentais")
      .get()
      .then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
       instrumentaisList = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      // Agora você pode usar os dadosInstrumentais da maneira que desejar
      for (var dados in instrumentaisList) {
        print("ID da Embalagem: ${dados['idEmbalagem']}, Instrumento: ${dados['instrumental']}");
      }
    } else {
      print("A tabela Instrumentais está vazia.");
    }
  }).catchError((error) => print('Erro ao obter os dados da tabela Instrumentais: $error'));
}
*/

  void adicionarDados(String nomeInstrumento) {
    db
        .collection("embalagem")
        .orderBy("id", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        int latestId = snapshot.docs[0]["id"];
        /*latestId=0;
      idAtual=0;*/
        idAtual = latestId + 1;
      }
    }).catchError((error) => print('Erro ao obter ID: $error'));


    final instrumentais = <String, dynamic>{
      "instrumental": nomeInstrumento,
      "idEmbalagem": idAtual,
    };

    DocumentReference documentRef = db.collection("instrumentais").doc(idAtual
        .toString()); // Criar uma referência para um novo documento com ID automático

    documentRef
        .set(instrumentais)
        .catchError((error) => print('Erro ao adicionar dados: $error'));
  }

  String nomeInstrumento = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo 1'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: Text('Obter Dados'),
            onPressed: () {
              //listarDadosInstrumentais();
            },
          ),
          ElevatedButton(
            child: Text('Teste'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Teste(idCaixa: 1,)),
              );
            },
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text('Remover dados'),
            onPressed: () {
              removerDados('22');
            },
          ),
          Text(
            'Digite o nome do instrumento:',
          ),
          SizedBox(height: 10),
          TextFormField(
            onChanged: (value) {
              setState(() {
                nomeInstrumento = value;
              });
            },
          ),
          ElevatedButton(
            child: Text('Adicionar Dados'),
            onPressed: () {
              adicionarDados(nomeInstrumento);
            },
          ),
          TextFormField(
            onChanged: (value) {
              setState(() {
                documentId = value;
              });
            },
          ),
          ElevatedButton(
            child: Text('Apagar Dados'),
            onPressed: () {
              removerDados(documentId);
            },
          ),
          SizedBox(height: 20),
          Column(
            children: instrumentaisList.map((dados) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: IntrinsicHeight(
                          child: Checkbox(
                            value: dados['isChecked'],
                            onChanged: (bool? value) {
                              setState(() {
                                dados['isChecked'] = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dados['instrumento'],
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Descrição: ${dados['descricao']}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Lista de Documentos (IDs de 3 a 5):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
