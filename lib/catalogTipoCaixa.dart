//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste_catalogo/catalogTeste.dart';
import 'package:teste_catalogo/catalogoCaixas.dart';
import 'catalogoCaixasTeste.dart';

class catalogoTipoCaixa extends StatefulWidget {
  @override
  _catalogoTipoCaixa createState() => _catalogoTipoCaixa();
}

class _catalogoTipoCaixa extends State<catalogoTipoCaixa> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> caixas = [];

  @override
  void initState() {
    super.initState();
    buscarCaixas();
  }


void adicionarIdCaixaTipo(int idTipo) {
  db.collection("embalagem")
      .orderBy("id", descending: true)
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      int latestId = snapshot.docs[0]["id"];
      String documentId = snapshot.docs[0].id;

      DocumentReference documentRef =
          db.collection("embalagem").doc(documentId);

      documentRef.update({"idTipo": idTipo}).then((_) {
        print("idCaixa adicionado com sucesso");


      }).catchError((error) {
        print("Erro ao adicionar idCaixa: $error");
      });
    } else {
      print("A tabela Embalagem está vazia.");
    }
  }).catchError((error) {
    print('Erro ao obter a embalagem mais recente: $error');
  });
}
  
void buscarCaixas() {
  print('entrou em buscar caixas');
  db.collection("tipo_caixa").get().then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        caixas = snapshot.docs.map((caixa) => caixa.data() as Map<String, dynamic>).toList();
      });
    } else {
      print("Não foram encontradas caixas no banco de dados.");
    }
  }).catchError((error) {
    print('Erro ao buscar as caixas: $error');
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
                        'CATÁLOGO DE CAIXAS',
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
                          child: Text(
                            '$id',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                        width: 10,
                      ),
                         Expanded(
                        child: Text(
                          '$nome',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          adicionarIdCaixaTipo(caixa['id']);
                          //adicionarArrayCaixaEmbalagem(caixa['instrumentais']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Teste(idCaixa:caixa['id'])),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(
                                10), // Define o borderRadius desejado

                            color: Colors
                                .black26, // Define a cor de fundo desejada
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.black54, // Define a cor do ícone
                            size: 30,
                          ),
                        ),
                      ),
                     
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  }