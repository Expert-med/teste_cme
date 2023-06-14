// Instrumentais contidos na caixa

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalogCaixasInstruInfo.dart';
import 'firebase/firebase_options.dart';
import 'observacaoPage.dart';

class Teste extends StatefulWidget {
  final int idCaixa;

  Teste({required this.idCaixa});

  @override
  _Teste createState() => _Teste();
}

class _Teste extends State<Teste> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> caixas = [];
  List<dynamic> instrumentaisList = [];
  List<bool> checkboxValues = [];
  String mensagem = '';

  bool todosMarcados = false;

  @override
  void initState() {
    super.initState();
    buscarInstrumentos(
        widget.idCaixa); // Pode ser alterado para outro ID de caixa desejado
  }

  String nomeCaixa = '';
  void verificarMarcados() {
    setState(() {
      todosMarcados = true;
      for (bool value in checkboxValues) {
        if (!value) {
          todosMarcados = false;
          break;
        }
      }

      if (todosMarcados) {
        adicionarArrayCaixaEmbalagem(instrumentaisList);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Instrumentais adicionados com sucesso!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddObservacoes(idCaixa: widget.idCaixa),
                      ),
                    );
                  },
                  child: Text('Finalizar Caixa'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alguns instrumentais não estão marcados.'),
              content: Text('Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Não'),
                ),
                TextButton(
                  onPressed: () {
                    /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddObservacoes(),
                    ),
                  ); */
                  },
                  child: Text('Sim'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void buscarInstrumentos(int idCaixa) {
    FirebaseFirestore.instance
        .collection("caixas")
        .where("id", isEqualTo: idCaixa)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          List<dynamic> instrumentos = snapshot.docs[0].get('instrumentais');
          if (instrumentos != null) {
            listarDadosInstrumentais(instrumentos);
            nomeCaixa = snapshot.docs[0].get(
                'nome'); // Atribui o valor do nome da caixa à variável nomeCaixa
          } else {
            print("A lista de instrumentos da caixa $idCaixa está vazia.");
          }
        });
      } else {
        print("A caixa com o ID fornecido não existe.");
      }
    }).catchError((error) =>
            print('Erro ao buscar instrumentos da caixa $idCaixa: $error'));
  }

  void listarDadosInstrumentais(List<dynamic> ids) {
    print('entrou em listarDadosInstrumentais $ids');
    List<List<dynamic>> batches = [];
    final batchSize = 10; // Tamanho do lote (batch)

    for (var i = 0; i < ids.length; i += batchSize) {
      var end = i + batchSize;
      var batchIds = ids.sublist(i, end < ids.length ? end : ids.length);
      batches.add(batchIds);
    }

    Future.forEach(batches, (batchIds) {
      return FirebaseFirestore.instance
          .collection("instrumentais")
          .where(FieldPath.documentId,
              whereIn: batchIds.map((id) => id.toString()).toList())
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            instrumentaisList
                .addAll(snapshot.docs.map((doc) => doc.data()).toList());
            checkboxValues = List<bool>.filled(instrumentaisList.length, false);
          });
        } else {
          print("A tabela Instrumentais está vazia.");
        }
      }).catchError((error) =>
              print('Erro ao obter os dados da tabela Instrumentais: $error'));
    });
  }

  void adicionarArrayCaixaEmbalagem(List<dynamic> instrumentais) {
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

        documentRef.update(
            {"instrumentais": FieldValue.arrayUnion(instrumentais)}).then((_) {
          print("instrumentais adicionados com sucesso");
        }).catchError((error) {
          print("Erro ao adicionar instrumentais: $error");
        });
      } else {
        print("A tabela Embalagem está vazia.");
      }
    }).catchError((error) {
      print('Erro ao obter a embalagem mais recente: $error');
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
                      '$nomeCaixa',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, top: 10, bottom: 10, right: 10),
                child: Text(
                  'Lista de Instrumentais:',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: instrumentaisList.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> dados = instrumentaisList[index];

                String nomeInstrumental = dados['nome'];
                String nomeCapitalizado = nomeInstrumental[0].toUpperCase() +
                    nomeInstrumental.substring(1);

                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$nomeCapitalizado',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID do instrumental: ${dados['id']}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            // Ação do botão instruInfo(idInstru: ${dados['id']})
                            //adicionarArrayCaixaEmbalagem(caixa['instrumentais']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      instruInfo(idInstru: dados['id'])),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black12,
                            ),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.help,
                              color: Colors.black54,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: Checkbox(
                    value: checkboxValues[index],
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxValues[index] = value ?? false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: ElevatedButton(
                onPressed: () {
                  verificarMarcados();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Finalizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 10.0,
                  backgroundColor: Color.fromARGB(222, 54, 185, 246),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
