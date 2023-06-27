import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teste_catalogo/homePage.dart';
import 'catalogCaixasInstruInfo.dart';
import 'observacaoPage.dart';
import 'tipoPage.dart';
class CriaPeronalizada extends StatefulWidget {
  final List<dynamic> instrumentaisListParametro;

  CriaPeronalizada({required this.instrumentaisListParametro});

  @override
  _CriaPeronalizadaState createState() => _CriaPeronalizadaState();
}

class _CriaPeronalizadaState extends State<CriaPeronalizada> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  int idAtual = 0;
  final _nomeCaixaController = TextEditingController();
  List<Map<String, dynamic>> instrumentaisList = [];

  List<Map<String, dynamic>> caixas = [];

  @override
  void initState() {
    super.initState();
    adicionarIdCaixaEmbalagem();
    buscarTipo(); // Call the method to fetch instrumentals
   instrumentaisList.clear(); // Clear the list before adding items
  instrumentaisList.addAll(
      widget.instrumentaisListParametro.map((dynamic item) => item as Map<String, dynamic>).toList());
  }
  

  List<int> quantities = []; // List to store quantities
 


  void adicionarIdCaixaEmbalagem() {
  db.collection("embalagem")
      .orderBy("id", descending: true)
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      int latestId = snapshot.docs[0]["id"] as int;
      String documentId = snapshot.docs[0].id;

      DocumentReference documentRef =
          db.collection("embalagem").doc(documentId);

      documentRef.update({"idCaixa": 0}).then((_) {
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
void adicionarArrayCaixaEmbalagem(List<dynamic> instrumentais) {
  String nomeCaixa = _nomeCaixaController.text;

  if (nomeCaixa.isEmpty) {
    print("O campo nome está vazio.");
    return;
  }

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
        
        for (var instrumental in instrumentais) {
          int quantidade = instrumental["quantidade"] ?? 1;
        
            for (int i = 0; i < quantidade; i++) {
            existingInstrumentais.add({
              "tipo": instrumental["tipo"],
              "nome": instrumental["nome"],
              "id": instrumental["id"],
            });
          }
         
          
        }
        
        documentRef.update({
          "instrumentais": existingInstrumentais,
          "nome": nomeCaixa,
          "caixa": false
        }).then((_) {
          print("Instrumentais adicionados com sucesso");
        }).catchError((error) {
          print("Erro ao adicionar instrumentais: $error");
        });
      }).catchError((error) {
        print("Erro ao obter o documento: $error");
      });
    } else {
      print("A tabela Embalagem está vazia.");
      int idAtual = 0; // Fornecer o valor apropriado para idAtual

      Map<String, dynamic> novaCaixa = {
        "caixa": false,
        "id": idAtual,
        "nome": nomeCaixa,
        "idCaixa": 0,
        "instrumentais": instrumentais,
      };

      db.collection("embalagem").add(novaCaixa).then((DocumentReference documentRef) {
        print("Nova caixa adicionada com sucesso");
      }).catchError((error) {
        print("Erro ao adicionar nova caixa: $error");
      });
    }
  }).catchError((error) {
    print('Erro ao obter a embalagem mais recente: $error');
  });
}



    void mostrarModalBar() {
    List<Map<String, dynamic>> filteredCaixas = List.from(caixas);
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              filteredCaixas = List.from(caixas);
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCaixas = caixas
                              .where((caixa) =>
                                  caixa['nome']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  caixa['id'].toString().contains(value))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: filteredCaixas.map((caixa) {
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
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black26,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.arrow_forward,
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
                ],
              ),
            );
          },
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
    List<Map<String, dynamic>> filteredInstrumentais = [];
    TextEditingController searchController = TextEditingController();

    FirebaseFirestore.instance
        .collection("instrumentais")
        .where("tipo", isEqualTo: idTipo)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> instrumentaisData = snapshot.docs.map((doc) {
          Map<String, dynamic> instrumentalData = doc.data() as Map<String, dynamic>;
          return instrumentalData;
        }).toList();

        filteredInstrumentais = List.from(instrumentaisData);

        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        filteredInstrumentais = List.from(instrumentaisData);
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    filteredInstrumentais = instrumentaisData
                                        .where((instrumental) =>
                                            instrumental['nome']
                                                .toString()
                                                .toLowerCase()
                                                .contains(value.toLowerCase()) ||
                                            instrumental['id'].toString().contains(value))
                                        .toList();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
  child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: filteredInstrumentais.map((instrumental) {
        String instrumentalNome = instrumental['nome'].toString();
        String instrumentalId = instrumental['id'].toString();
        int instrumentalTipo = instrumental['tipo'];
        return InkWell(
          onTap: () {
            addInstrumental(instrumentalNome, instrumentalId, instrumentalTipo);
            print(instrumentaisList);
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    instrumentalNome,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => instruInfo(idInstru: instrumentalId.toString()),
                      ),
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
        );
      }).toList(),
    ),
  ),
),

                    ],
                  ),
                );
              },
            );
          },
        );
      } else {
        print("A tabela Instrumentais está vazia.");
      }
    }).catchError((error) => print('Erro ao obter os dados da tabela Instrumentais: $error'));
  }



void fetchFilteredInstrumentais(int idTipo, String searchTerm) {
  print('Entrou em listarInstrumentais $idTipo');

  // Acessa a coleção "instrumentais" no Firestore
  FirebaseFirestore.instance
      .collection("instrumentais")
      .where("tipo", isEqualTo: idTipo)
      .get()
      .then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> instrumentaisData = snapshot.docs
          .map((doc) {
            // Obtém os dados do instrumental do documento
            Map<String, dynamic> instrumentalData =
                doc.data() as Map<String, dynamic>;
            return instrumentalData;
          })
          .where((instrumental) {
            final instrumentalNome = instrumental['nome']?.toString() ?? '';
            return instrumentalNome.contains(searchTerm);
          })
          .toList();

      // Exiba os instrumentais na tela
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                children: instrumentaisData.map((instrumental) {
                  String instrumentalNome = instrumental['nome'].toString();
                  String instrumentalId = instrumental['id'].toString();
                  int instrumentalTipo = instrumental['tipo'];
                  return GestureDetector(
                    onTap: () {
                      addInstrumental(
                          instrumentalNome, instrumentalId,instrumentalTipo);
                      print(instrumentaisList);
                      Navigator.pop(context); // Fechar a modal
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        instrumentalNome,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      print("A tabela Instrumentais está vazia.");
    }
  }).catchError(
      (error) => print('Erro ao obter os dados da tabela Instrumentais: $error'));
}


  void addInstrumental(String instrumentalNome, String idInstrumental, int instrumentalTipo) {
  // Verifica se o instrumental já existe na lista
  bool instrumentalExists = instrumentaisList.any((instrumental) =>
      instrumental['nome'] == instrumentalNome &&
      instrumental['id'] == idInstrumental);

  // Se o instrumental não existir na lista, adicione-o
  if (!instrumentalExists) {
    setState(() {
      instrumentaisList.add({
        'nome': instrumentalNome,
        'id': idInstrumental,
        'tipo': instrumentalTipo,
        'quantidade': 1,
      });
    });
  }
}


  /*void instrumentaisListParametro(String instrumentalNome, String idInstrumental) {
  widget.instrumentaisListParametro.add({
    'nome': instrumentalNome,
    'id': idInstrumental,
    'quantidade': 1,
  });
}*/

@override
Widget build(BuildContext context) {
  List<int> quantities = [];

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
                      'CAIXA PERSONALIZADA',
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
    body: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text("Nome da Embalagem"),
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
    Map<String, dynamic> instrumental = instrumentaisList[index];
    String instrumentalNome = instrumental['nome'];
    int quantidade = instrumental['quantidade'] ?? 1;

    if (index >= quantities.length) {
      quantities.add(1);
    }

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              '$instrumentalNome',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (quantidade > 1) {
                  instrumental['quantidade'] = quantidade - 1;
                } else {
                  // Create a temporary list to store the remaining instrumentals
                 List<Map<String, dynamic>> updatedList = List.from(instrumentaisList);
updatedList.removeAt(index);
instrumentaisList = updatedList;

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
                instrumental['quantidade'] = quantidade + 1;
              });
              print('qtd: $quantidade');
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
                                        child: Text('Continuar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            } else {
                              print(instrumentaisList);
                              adicionarArrayCaixaEmbalagem(
                                  instrumentaisList);
                                
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Embalagem Adicionada com sucesso!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddObservacoes(
                                                      idCaixa: 0),
                                            ),
                                          );
                                        },
                                        child: Text('Continuar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(
                            "Criar embalagem",
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
