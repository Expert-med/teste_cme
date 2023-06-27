import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste_catalogo/catalogTeste.dart';
import 'package:teste_catalogo/catalogoCaixas.dart';

class CatalogoCaixasTeste extends StatefulWidget {
  @override
  _CatalogoCaixasTesteState createState() => _CatalogoCaixasTesteState();
}

class _CatalogoCaixasTesteState extends State<CatalogoCaixasTeste> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> caixas = [];
  List<Map<String, dynamic>> filteredCaixas = [];

  @override
  void initState() {
    super.initState();
    buscarCaixas();
  }

  Future<void> removeLastDocument() async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Get the reference to the last document in the collection
  QuerySnapshot snapshot = await db
      .collection("embalagem")
      .orderBy("id", descending: true)
      .limit(1)
      .get();
  
  if (snapshot.docs.isNotEmpty) {
    DocumentSnapshot document = snapshot.docs[0];
    DocumentReference documentRef = document.reference;

    // Delete the document
    await documentRef.delete();

    print("Last document removed successfully.");
  } else {
    print("The collection 'embalagem' is empty.");
  }
}

  void buscarCaixas() {
    db.collection("caixas").get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          caixas = snapshot.docs
              .map((caixa) => caixa.data() as Map<String, dynamic>)
              .where((caixa) => caixa['id'] > 0)
              .toList();
          filteredCaixas = List.from(caixas);
        });
      } else {
        print("Não foram encontradas caixas no banco de dados.");
      }
    }).catchError((error) {
      print('Erro ao buscar as caixas: $error');
    });
  }

  void filterCaixas(String searchQuery) {
  setState(() {
    filteredCaixas = caixas.where((caixa) {
      final nome = caixa['nome'].toString().toLowerCase();
      final id = caixa['id'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return nome.contains(query) || id == query;
    }).toList();
  });
}


  void adicionarIdCaixaEmbalagem(int idCaixa) {
  db.collection("embalagem")
      .orderBy("id", descending: true)
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      int latestId = snapshot.docs[0]["id"];
      String documentId = snapshot.docs[0].id;

      DocumentReference documentRef =
          db.collection("embalagem").doc(documentId);

      documentRef.update({"idCaixa": idCaixa}).then((_) {
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
                        'CATÁLOGO DE CAIXAS',
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
        leading: IconButton(
  icon: Icon(Icons.home),
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deseja continuar?'),
          content: Text('Se sim, todas as informações serão perdidas.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',style:TextStyle(color: Color(0xFF6C1BC8),)),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Continuar',style:TextStyle(color: Color(0xFF6C1BC8),)),
              onPressed: () {
                removeLastDocument();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  },
),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => filterCaixas(value),
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  labelStyle: TextStyle(
                                    color: Color(
                                        0xFF6C1BC8), // Cor do texto "Procurar"
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Color(0xFF6C1BC8), // Cor da lupa
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .grey), // Cor padrão do contorno
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Color(
                                            0xFF6C1BC8)), // Cor do contorno ao clicar
                                  ),
                  
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCaixas.length,
              itemBuilder: (context, index) {
                final caixa = filteredCaixas[index];
                int id = caixa['id'];
                String nome = caixa['nome'] ?? '';

                return ListTile(
                  leading: Container(
                    alignment: Alignment.center,
                    width: 80,
                    height: 80,
                    child: Text(
                      '$id',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    nome,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: Container(
                    width: 80,
                    height: 80,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        adicionarIdCaixaEmbalagem(caixa['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Teste(idCaixa: caixa['id']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
