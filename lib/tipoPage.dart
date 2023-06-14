//Tipos de instrumentais

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'InstrumentalPage.dart';
class tipoPage extends StatefulWidget {
  
  @override
  _tipoPage createState() => _tipoPage();
}



class _tipoPage extends State<tipoPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> caixas = [];

@override
  void initState() {
    super.initState();
    buscarTipo();
  }

  
void buscarTipo() {
  db.collection("tipo_instrumental").get().then((QuerySnapshot snapshot) {
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
      appBar: AppBar(
        toolbarHeight: 300,
        backgroundColor: Color.fromARGB(156, 59, 57, 172),
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
                      'Tipo Instrumental',
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
                          '${nome[0].toUpperCase()}${nome.substring(1)}',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => instrumentalPage(idTipo: caixa['id'],)),
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