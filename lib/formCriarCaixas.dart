import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teste_catalogo/homePage.dart';
import 'tipoPage.dart';

class formCriarCaixas extends StatefulWidget {
  @override
  _formCriarCaixasState createState() => _formCriarCaixasState();
}

class _formCriarCaixasState extends State<formCriarCaixas> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late int idAtual = 0;
  final _nomeCaixaController = TextEditingController();
  final _idCaixaController = TextEditingController();

  List<Map<String, dynamic>> caixas = [];

  @override
  void initState() {
    super.initState();
    buscarTipo(); // Call the method to fetch instrumentals
  }

  List<Map<String, dynamic>> instrumentaisList = [];
  List<int> quantities = []; // List to store quantities

  void adicionarArrayCaixaInstrumental(List<dynamic> instrumentais) {
    db
        .collection("caixas")
        .orderBy("id", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      late int idAtual = 0;
      if (snapshot.docs.isNotEmpty) {
        int latestId = snapshot.docs[0]["id"] as int;
        idAtual = latestId + 1;
      } else {
        idAtual = 1;
      }

      Map<String, dynamic> novaCaixa = {
        "caixa": true,
        "id": idAtual,
        "nome": _nomeCaixaController.text,
        "instrumentais": []
      };

      // Adicione os instrumentais à lista conforme a quantidade especificada
      for (int i = 0; i < instrumentais.length; i++) {
        int quantidade = instrumentais[i]['quantidade'];
        String instrumentalNome = instrumentais[i]['nome'];
        int instrumentaid = instrumentais[i]['id'] ?? 0;
        print('id isnutrmental $instrumentaid');
        for (int j = 0; j < quantidade; j++) {
          novaCaixa["instrumentais"].add(instrumentaid);
        }
      }

      db.collection("caixas").doc(idAtual.toString()).set(novaCaixa).then((_) {
        print("Nova caixa criada com sucesso");
      }).catchError((error) {
        print("Erro ao criar nova caixa: $error");
      });
    }).catchError((error) {
      print('Erro ao obter a caixa mais recente: $error');
    });
  }

  void mostrarModalBar() {
    print("Entrou na modalBar");
    //listarDadosInstrumentais(); // Call the method to fetch instrumentals
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Center(
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
                          listarInstrumentais(idTipo: caixa['id']);
                          Navigator.pop(context);
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
        );
      },
    );
  }

  void buscarTipo() {
    db.collection("tipo_instrumental").get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          caixas = snapshot.docs
              .map((caixa) => caixa.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as caixas: $error');
    });
  }

  void listarInstrumentais({required int idTipo}) {
    print('Entrou em listarInstrumentais $idTipo');

    // Acessa a coleção "instrumentais" no Firestore
    FirebaseFirestore.instance
        .collection("instrumentais")
        .where("tipo", isEqualTo: idTipo)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> instrumentaisData = snapshot.docs.map((doc) {
          // Obtém os dados do instrumental do documento
          Map<String, dynamic> instrumentalData =
              doc.data() as Map<String, dynamic>;
          return instrumentalData;
        }).toList();

        // Exiba os instrumentais na tela
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              child: ListView(
                children: instrumentaisData.map((instrumental) {
                  String instrumentalNome = instrumental['nome'];
                  int instrumentalId = instrumental['id'];
                  return InkWell(
                    onTap: () {
                      addInstrumental(instrumentalNome, instrumentalId);
                      print(instrumentaisList);
                      Navigator.pop(context); // Fechar a modal
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        instrumentalNome,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      } else {
        print("A tabela Instrumentais está vazia.");
      }
    }).catchError((error) =>
            print('Erro ao obter os dados da tabela Instrumentais: $error'));
  }

  void addInstrumental(String instrumentalNome, int idInstrumental) {
    setState(() {
      instrumentaisList.add({
        'nome': instrumentalNome,
        'id': idInstrumental,
        'quantidade': 1,
      });
    });
  }

  /*void listarDadosInstrumentais() {
    print("Entrou na listarDadosInstrumentais");
    FirebaseFirestore.instance
        .collection("instrumentais")
        .get()
        .then((QuerySnapshot snapshot) {
      // print("Got snapshot: ${snapshot.docs.length} documents");
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          caixas = snapshot.docs
              .map((caixa) => caixa.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        print("A tabela Instrumentais está vazia.");
      }
    }).catchError((error) =>
            print('Erro ao obter os dados da tabela Instrumentais: $error'));
  }*/

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
                      'Criar Caixa',
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
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text("Nome da Caixa"),
            ),
            TextFormField(
              controller: _nomeCaixaController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                          child: ElevatedButton(
                            onPressed: mostrarModalBar,
                            child: Text(
                              "Adicionar Instrumentais",
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Instrumentais Adicionados:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: instrumentaisList.length,
                itemBuilder: (BuildContext context, int index) {
                  // Obtain the name of the instrumental from the map

                  Map<String, dynamic> instrumental = instrumentaisList[index];
                  String instrumentalNome = instrumental['nome'];
                  int quantidade = instrumental['quantidade'];

                  if (index >= quantities.length) {
                    // If the quantity for the current item doesn't exist in the list, initialize it to 1
                    quantities.add(1);
                  }

                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text('$instrumentalNome',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (quantidade > 1) {
                                // Se a quantidade for maior que 1, apenas diminua 1
                                instrumental['quantidade'] = quantidade - 1;
                              } else {
                                // Se a quantidade for igual a 1, remova o instrumental da lista
                                instrumentaisList.removeAt(index);
                              }
                            });
                          },
                        ),
                        Text(
                          '$quantidade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              // Aumente a quantidade em 1
                              instrumental['quantidade'] = quantidade + 1;
                            });
                            print('qtd: $instrumental[$quantities]');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
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
                          child: ElevatedButton(
                            onPressed: () {
                              if (_nomeCaixaController.text.isEmpty ||
                                  instrumentaisList.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          'Nome da caixa ou lista de instrumentais está vazia. Não é possível criar a caixa.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Continuar',style: TextStyle(color: Color.fromARGB(156, 0, 107, 57),)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              } else {
                                adicionarArrayCaixaInstrumental(
                                    instrumentaisList);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          Text('Caixa Adicionada com sucesso!'),
                                      actions: [
                                        TextButton(
                                           onPressed: () {
                                            Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
                                          },
                                          child: Text('Continuar',style: TextStyle(color: Color.fromARGB(156, 0, 107, 57),)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              "Criar caixa",
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
                          ),
                        ),
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
