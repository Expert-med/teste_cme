import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'catalogCaixasInstruInfo.dart';
import 'gerarEtiquetaPage.dart';

class historicoInfo extends StatefulWidget {
  final int idEmbalagem;

  historicoInfo({required this.idEmbalagem});

  @override
  _historicoInfo createState() => _historicoInfo();
}

class _historicoInfo extends State<historicoInfo> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> embalagem = [];
  List<Map<String, dynamic>> caixa = [];
  List<Map<String, dynamic>> instrumentaisList = [];
  int imprimiuTeste = 0;

  @override
  void initState() {
    super.initState();
    print('inicializador');
    print(widget.idEmbalagem);
    buscarDadosEmbalagem(widget.idEmbalagem);
    caixa = [];
  }

  void buscarDadosEmbalagem(int idEmbalagem) {
    FirebaseFirestore.instance
        .collection("embalagem")
        .where("id", isEqualTo: idEmbalagem)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          embalagem.add(snapshot.docs[0].data() as Map<String, dynamic>);
          int idCaixa = embalagem[0]['idCaixa'];
          buscarCaixaEmb(idCaixa, idEmbalagem);
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as embalagens: $error');
    });
  }

  Future<void> buscarCaixaEmb(int idCaixa, int idEmbalagem) async {
    print(idEmbalagem);
    if (idCaixa != 0) {
      await FirebaseFirestore.instance
          .collection("caixas")
          .where("id", isEqualTo: idCaixa)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var document = snapshot.docs[0];
          if (document.exists) {
            var data = document.data();
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('instrumentais')) {
              List<dynamic> instrumentos = document.get('instrumentais');
              setState(() {
                listarDadosInstrumentais(instrumentos);
                caixa.add(data as Map<String, dynamic>);
              });
            } else {
              print(
                  "O campo 'instrumentais' não existe no documento: ${document.id}");
            }
          } else {
            print("Documento não encontrado: ${document.id}");
          }
        } else {
          print(
              "Não foram encontrados tipos de instrumentais no banco de dados.");
        }
      }).catchError((error) {
        print('Erro ao buscar os tipos de instrumentais: $error');
      });
    } else {
      FirebaseFirestore.instance
          .collection("embalagem")
          .where("id",
              isEqualTo:
                  idEmbalagem) // Replace idembalagem with the actual ID value you want to query
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var document = snapshot.docs[0];
          if (document.exists) {
            var data = document.data();
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('instrumentais')) {
              List<dynamic> instrumentos = [];
              List<dynamic> instrumentaisData = document.get('instrumentais');
              for (var instrumento in instrumentaisData) {
                instrumentos.add(instrumento['id']);
              }
              setState(() {
                listarDadosInstrumentais(instrumentos);
                print(instrumentos);
                caixa.add(data as Map<String, dynamic>);
              });
            } else {
              print("O campo 'instrumentais' não existe no documento: ");
            }
          } else {
            print("Documento não encontrado: ${document.id}");
          }
        } else {
          print(
              "Não foram encontrados tipos de instrumentais no banco de dados.");
        }
      }).catchError((error) {
        print('Erro ao buscar os tipos de instrumentais: $error');
      });
    }
  }

  Future<void> listarDadosInstrumentais(List<dynamic> ids) async {
    print('print 6');
    print('entrou em listarDadosInstrumentais $ids');
    List<List<String>> batches = [];
    final batchSize = 10; // Tamanho do lote (batch)

    for (var i = 0; i < ids.length; i += batchSize) {
      var end = i + batchSize;
      var batchIds = ids.sublist(i, end < ids.length ? end : ids.length);

      // Filter out null values before adding to the batch
      batchIds = batchIds.where((id) => id != null).toList();

      batches.add(batchIds.map((id) => id.toString()).toList());
    }

    await Future.forEach(batches, (batchIds) {
      return FirebaseFirestore.instance
          .collection("instrumentais")
          .where(FieldPath.documentId, whereIn: batchIds)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            instrumentaisList.addAll(snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id.toString();
              return data;
            }).toList());
            print('add a lista $ids');
          });
        } else {
          print("A tabela Instrumentais está vazia.");
        }
      }).catchError((error) =>
              print('Erro ao obter os dados da tabela Instrumentais: $error'));
    });
  }

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
                        'INFORMAÇÕES ADICIONADAS',
                        style: TextStyle(
                          fontSize: 20,
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
            children: embalagem.map((embalagem) {
              int id = embalagem['id'];
              int idCaixa = embalagem['idCaixa'];
              // Restante do código para renderizar os dados do caixa
              imprimiuTeste = embalagem['imprimiu'];
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID embalagem: ',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$id',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Informações adicionais:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Padding(
         padding: const EdgeInsets.only(left: 20),
        child: Text(
          'Data de Criação: ',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          ' ${embalagem['infoAdicionais'] != null ? embalagem['infoAdicionais']['dataAtual'] ?? '0' : '0'}  | ${embalagem['infoAdicionais'] != null ? embalagem['infoAdicionais']['horaCriacao'] ?? '0' : '0'}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ),
    ),
  ],
),

                      SizedBox(height: 20),
                    Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          'Data de Validade:',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          ' ${embalagem['infoAdicionais']?['dataValidade'] ?? 0}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ),
    ),
  ],
),

                      SizedBox(height: 20),
                     Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          'Nome do Funcionário: ',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          '${embalagem['infoAdicionais']?['nomeFuncionario'] ?? ''}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ),
    ),
  ],
),

                      SizedBox(height: 20),
                     Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          'Observações:',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.topLeft,
        child: Flexible(
          child: Text(
            '${embalagem['infoAdicionais']?['observacoes'] ?? ''}',
            style: TextStyle(
              fontSize:  20,
              color: Colors.black54,
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
              );
            }).toList()
              ..addAll(caixa.map((caixa) {
                int idCaixa = caixa['id'];
                String nomeCaixa = caixa['nome'];

                // Restante do código para renderizar os dados do tipo

                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Text(
        'Nome Caixa: ',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          '${nomeCaixa[0].toUpperCase()}${nomeCaixa.substring(1)} (Id: $idCaixa)',
          style: TextStyle(
            fontSize:  20,
            color: Colors.black54,
          ),
        ),
      ),
    ),
  ],
),

                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instrumentais contidos na caixa: ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 300, // Defina a largura desejada aqui
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: instrumentaisList.length,
                            itemBuilder: (context, index) {
                              var instrumental = instrumentaisList[index];
                              if (instrumental != null &&
                                  instrumental['nome'] != null) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => instruInfo(
                                              idInstru: instrumental['id'])),
                                    );
                                  },
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '- ${instrumental['nome']}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${instrumental['id']}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                // Handle null values or missing data
                                return Container();
                              }
                            },
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
                                      child: Visibility(
                                        visible: imprimiuTeste ==
                                            0, // Mostra o botão somente quando imprimiuTeste for igual a 0
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    gerarEtiqueta(
                                                        idEmbalagem:
                                                            widget.idEmbalagem),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Gerar etiqueta",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 10.0,
                                            backgroundColor: Color(0xFF6C1BC8),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 20.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                      ],
                    ),
                  ),
                );
              }).toList()),
          ),
        ),
      ),
    );
  }
}
