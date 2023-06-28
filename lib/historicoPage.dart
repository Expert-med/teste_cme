import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'historicoInfoPage.dart';

class historicoPage extends StatefulWidget {
  @override
  _historicoPageState createState() => _historicoPageState();
}

class _historicoPageState extends State<historicoPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> embalagens = [];
  List<Map<String, dynamic>> embalagensFiltradas = [];
  String searchTerm = '';
  bool showFiltradas = false;

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
          embalagens.sort((a, b) {
            final int idA = a['id'] as int? ?? 0;
            final int idB = b['id'] as int? ?? 0;
            return idA.compareTo(idB);
          });
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as caixas: $error');
    });
  }

  

  List<Map<String, dynamic>> filterEmbalagens(
      List<Map<String, dynamic>> embalagens, int imprimiuValue) {
    return embalagens.where((embalagem) {
      return embalagem['imprimiu'] == imprimiuValue;
    }).toList();
  }

  void filtrarEmbalagens(int imprimiuValue) {
    setState(() {
      showFiltradas = true;
      embalagensFiltradas = filterEmbalagens(embalagens, imprimiuValue);
    });
  }

  void mostrarTodasEmbalagens() {
    setState(() {
      showFiltradas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   List<Map<String, dynamic>> filteredEmbalagens = embalagens;
if (searchTerm.isEmpty) {
  filteredEmbalagens = showFiltradas ? embalagensFiltradas : embalagens;
} else {
  filteredEmbalagens = embalagens
      .where((embalagem) {
        final id = embalagem['id']?.toString() ?? '';
        return id == searchTerm;
      })
      .toList();
}


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
          child: Padding(
            padding: EdgeInsets.only(left: 30, bottom: 30),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'HISTÓRICO DE EMBALAGENS',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Procurar',
                        labelStyle: TextStyle(
                          color: Color(0xFF6C1BC8), // Cor do texto "Procurar"
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF6C1BC8), // Cor da lupa
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey), // Cor padrão do contorno
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color(0xFF6C1BC8)), // Cor do contorno ao clicar
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    filtrarEmbalagens(1);
                                    Navigator.pop(
                                        context); // Fechar a ModalBottomSheet
                                  },
                                  child: Text('Mostrar Embalagens impressas'),
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
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    filtrarEmbalagens(0);
                                    Navigator.pop(
                                        context); // Fechar a ModalBottomSheet
                                  },
                                  child:
                                      Text('Mostrar Embalagens não impressas'),
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
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    mostrarTodasEmbalagens();
                                    Navigator.pop(
                                        context); // Fechar a ModalBottomSheet
                                  },
                                  child: Text('Mostrar Todas as Embalagens'),
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
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Filtros'),
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
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEmbalagens.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> embalagem =
                      filteredEmbalagens.reversed.toList()[index];
                  int id = embalagem['id'];
                  int idCaixa = embalagem['idCaixa'] ?? 0;
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.all(20),
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
                                    'Data de criação: ${embalagem['infoAdicionais']?['dataAtual'] ?? ''}',
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
                                    'Data de validade: ${embalagem['infoAdicionais']?['dataValidade'] ?? ''}',
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => historicoInfo(
                                    idEmbalagem: embalagem['id'],
                                  ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
