import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'historicoInfoPage.dart';

class historicoPage extends StatefulWidget {
  @override
  _historicoPage createState() => _historicoPage();
}

class _historicoPage extends State<historicoPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> embalagens = [];

  @override
  void initState() {
    super.initState();
    buscarCaixas();
  }

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
                      'Histórico de embalagens',
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
            children: embalagens.map((embalagem) {
              int id = embalagem['id'];
              int idCaixa = embalagem['idCaixa'] ??
                  0; // Provide a default value if 'idCaixa' is null
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topCenter,
                            child: IntrinsicHeight(
                              child: Text(
                                'Embalagem $id',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            child: IntrinsicHeight(
                              child: Text(
                                'Data de criação: ${embalagem['infoAdicionais'] ? ['dataAtual'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                            Container(
                            alignment: Alignment.topCenter,
                            child: IntrinsicHeight(
                              child: Text(
                                'Data de validade: ${embalagem['infoAdicionais'] ? ['dataValidade'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          //adicionarArrayCaixaEmbalagem(caixa['instrumentais']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  historicoInfo(idEmbalagem: embalagem['id']),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black26,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.info,
                            color: Colors.black54,
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
