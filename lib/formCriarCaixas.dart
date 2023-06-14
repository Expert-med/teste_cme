import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tipoPage.dart';

class formCriarCaixas extends StatefulWidget {
  @override
  _formCriarCaixasState createState() => _formCriarCaixasState();
}

class _formCriarCaixasState extends State<formCriarCaixas> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _nomeCaixaController = TextEditingController();
  final _idCaixaController = TextEditingController();

  List<Map<String, dynamic>> caixas = [];

  @override
  void initState() {
    super.initState();
    buscarTipo(); // Call the method to fetch instrumentals
  }

  List<Map<String, dynamic>> instrumentaisList = [];

  void adicionarInstrumental(String instrumental) {
    setState(() {
      instrumentaisList.add({'nome': instrumental});
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

                  return InkWell(
                    onTap: () {
                      addInstrumental(instrumentalNome);
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

  void addInstrumental(String instrumentalNome) {
    setState(() {
      instrumentaisList.add({
        'nome': instrumentalNome,
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
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255),
          size: 32,
        ),
        elevation: 0,
        title: Text(
          'Criar Caixa',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                              shadowColor: Colors.black,
                              elevation: 10.0,
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
                  int quantity = 0; // Initialize the quantity to 0

                  // Obtém o nome do instrumental do mapa
                  String instrumentalNome = instrumentaisList[index]['nome'];

                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(instrumentalNome)),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (quantity > 0) {
                                quantity--;
                              }
                            });
                          },
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
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
                            onPressed: () {},
                            child: Text(
                              "Criar caixa",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.black,
                              elevation: 10.0,
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
