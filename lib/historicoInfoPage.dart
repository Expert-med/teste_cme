import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  List<dynamic> instrumentaisList = [];

  @override
  void initState() {
    super.initState();
    buscarDadosEmbalagem(widget.idEmbalagem);
  }

  void buscarDadosEmbalagem(int idEmbalagem) {
    print(idEmbalagem);
    FirebaseFirestore.instance
        .collection("embalagem")
        .where("id", isEqualTo: idEmbalagem)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          embalagem.add(snapshot.docs[0].data() as Map<String, dynamic>);
          int idCaixa = embalagem[0]['idCaixa'];
          buscarCaixaEmb(idCaixa);
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as embalagens: $error');
    });
  }

  void buscarCaixaEmb(int idCaixa) {
    FirebaseFirestore.instance
        .collection("caixas")
        .where("id", isEqualTo: idCaixa)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<dynamic> instrumentos = snapshot.docs[0].get('instrumentais');
        setState(() {
          listarDadosInstrumentais(instrumentos);
          caixa.add(snapshot.docs[0].data() as Map<String, dynamic>);
        });
      } else {
        print(
            "Não foram encontrados tipos de instrumentais no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar os tipos de instrumentais: $error');
    });
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
                      'Informações adicionais',
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
            children: embalagem.map((embalagem) {
              int id = embalagem['id'];
              int idCaixa = embalagem['idCaixa'];
              // Restante do código para renderizar os dados do caixa

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
                              fontSize: 30,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$id',
                              style: TextStyle(
                                fontSize: 30,
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
                          fontSize: 30,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
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
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ' ${embalagem['infoAdicionais'] ? ['dataAtual'] ?? 0}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
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
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ' ${embalagem['infoAdicionais'] ? ['dataValidade'] ?? 0}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Nome do Funcionário: ',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${embalagem['infoAdicionais'] ? ['nomeFuncionario'] ?? 0}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
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
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ' ${embalagem['infoAdicionais']?['observacoes'] ?? ''}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
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
                            Text(
                              'Nome Caixa: ',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                ': ${nomeCaixa[0].toUpperCase()}${nomeCaixa.substring(1)} (Id: $idCaixa)',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black54,
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
                                fontSize: 30,
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
                              // Renderizar os dados do instrumental aqui
                              return ListTile(
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
                                    ],
                                  ),
                                ),
                              );
                            },
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
