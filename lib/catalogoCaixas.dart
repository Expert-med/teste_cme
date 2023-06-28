// Instrumentais contidos na caixa

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste_catalogo/criarCaixaPersonal.dart';
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
    List<Map<String, dynamic>> selectedInstrumentais = [];
    todosMarcados = true;
    
    for (int i = 0; i < checkboxValues.length; i++) {
      if (checkboxValues[i]) {
        selectedInstrumentais.add(instrumentaisList[i]);
      } else {
        todosMarcados = false;
      }
    }

    if (todosMarcados) {
      adicionarArrayCaixaEmbalagem(selectedInstrumentais);
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
                      builder: (context) => AddObservacoes(idCaixa: widget.idCaixa),
                    ),
                  );
                },
                child: Text(
                  'Finalizar Caixa',
                  style: TextStyle(color: Color(0xFF6C1BC8)),
                ),
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
                child: Text(
                  'Não',
                  style: TextStyle(color: Color(0xFF6C1BC8)),
                ),
              ),
              TextButton(
                onPressed: () {
                  //adicionarArrayCaixaEmbalagem(selectedInstrumentais);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CriaPeronalizada(
                        instrumentaisListParametro: selectedInstrumentais,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Sim',
                  style: TextStyle(color: Color(0xFF6C1BC8)),
                ),
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
    instrumentaisList = []; // Limpar a lista antes de adicioná-los novamente
    checkboxValues = []; // Limpar a lista dos valores do checkbox

    Future.forEach(ids, (id) {
      return FirebaseFirestore.instance
          .collection("instrumentais")
          .doc(id.toString())
          .get()
          .then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          setState(() {
            instrumentaisList
                .add(snapshot.data()); // Adicionar o instrumental à lista
            checkboxValues
                .add(false); // Adicionar o valor do checkbox correspondente
          });
        } else {
          print("O instrumental com o ID $id não foi encontrado.");
        }
      }).catchError((error) => print(
              'Erro ao obter o dado do instrumental com o ID $id: $error'));
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
        int latestId = snapshot.docs[0]["id"] as int;
        String documentId = snapshot.docs[0].id;

        DocumentReference documentRef =
            db.collection("embalagem").doc(documentId);

        documentRef.get().then((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          List<dynamic> existingInstrumentais = data["instrumentais"] ?? [];
          List<dynamic> updatedInstrumentais = List.from(existingInstrumentais)
            ..addAll(instrumentais);

          documentRef.update({"instrumentais": updatedInstrumentais}).then((_) {
            print("Instrumentais adicionados com sucesso");
          }).catchError((error) {
            print("Erro ao adicionar instrumentais: $error");
          });
        }).catchError((error) {
          print("Erro ao obter o documento: $error");
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
                                      instruInfo(idInstru: dados['id'].toString())),
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
                    activeColor: Color(0xFF6C1BC8), // Definir a cor aqui
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                              backgroundColor: Color(0xFF6C1BC8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
