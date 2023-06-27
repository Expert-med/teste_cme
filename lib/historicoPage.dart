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
  String searchTerm = '';

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
  final int idA = a['id'] as int? ?? 0; // Assign 0 as default value if 'id' is null or not of type int
  final int idB = b['id'] as int? ?? 0;
  return idA.compareTo(idB);
});

        // Sort by 'id' in ascending order, handling null values
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
  List<Map<String, dynamic>> filteredEmbalagens = embalagens;
  if (searchTerm.isEmpty) {
    filteredEmbalagens = embalagens;
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
                      'HISTÓRICO DE EMBALAGENS',
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
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
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
                  borderSide: BorderSide(color: Colors.grey), // Cor padrão do contorno
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF6C1BC8)), // Cor do contorno ao clicar
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmbalagens.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> embalagem = filteredEmbalagens.reversed.toList()[index];
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
