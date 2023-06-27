//observacoes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import 'gerarEtiquetaPage.dart';

class AddObservacoes extends StatefulWidget {
  final int idCaixa;

  AddObservacoes({required this.idCaixa});

  @override
  _AddObservacoes createState() => _AddObservacoes();
}

class _AddObservacoes extends State<AddObservacoes> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _idCaixaController = TextEditingController();
  TextEditingController _dataAtualController = TextEditingController();
  TextEditingController _dataValidadeController = TextEditingController();
  TextEditingController _nomeFuncionarioController = TextEditingController();
  TextEditingController _observacoesController = TextEditingController();
  TextEditingController _horaAtual = TextEditingController();
  List<Map<String, dynamic>> caixas = [];

  int _imprimiuController = 0;


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

  void adicionarArrayObservacoes() {
    print('entrou em adicionarArrayCaixaEmbalagem');
    String dataValidade = _dataValidadeController.text;
    String nomeFuncionario = _nomeFuncionarioController.text;
    String observacoes = _observacoesController.text;
    String dataAtual = _dataAtualController.text;
    String horaAtual = _horaAtual.text;

    if (dataValidade == '' ||
        nomeFuncionario == '' ||
        observacoes == '' ||
        dataAtual == '' ||
        horaAtual == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text('É necessário preencher todos os campos do formulário!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Continuar',
                    style: TextStyle(
                      color: Color(0xFF6C1BC8),
                    )),
              ),
            ],
          );
        },
      );
    } else {
      Map<String, dynamic> infoAdicionaisData = {
        'dataValidade': dataValidade,
        'nomeFuncionario': nomeFuncionario,
        'observacoes': observacoes,
        'dataAtual': dataAtual,
        'horaCriacao': horaAtual,
      };

      FirebaseFirestore.instance
          .collection('embalagem')
          .orderBy("id", descending: true)
          .limit(1)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String documentId = snapshot.docs[0].id;

          DocumentReference documentRef = FirebaseFirestore.instance
              .collection("embalagem")
              .doc(documentId);

          documentRef.update({"infoAdicionais": infoAdicionaisData}).then((_) {
            print("Dados adicionais da caixa atualizados com sucesso");
          }).catchError((error) {
            print("Erro ao atualizar os dados adicionais da caixa: $error");
          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Informações adicionadas com sucesso'),
                actions: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Deseja Imprimir?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _imprimiuController = 1;
                                  processoImprimiu(_imprimiuController);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => gerarEtiqueta(
                                          idEmbalagem: int.parse(documentId)),
                                    ),
                                  );
                                },
                                child: Text('Sim',style:TextStyle(color: Color(0xFF6C1BC8),)),
                              ),
                              TextButton(
                                onPressed: () {
                                  _imprimiuController = 0;
                                  processoImprimiu(_imprimiuController);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Text('Não',style:TextStyle(color: Color(0xFF6C1BC8),)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Continuar',
                        style: TextStyle(
                          color: Color(0xFF6C1BC8),
                        )),
                  ),
                ],
              );
            },
          );
        } else {
          print("A tabela Embalagem está vazia.");
        }
      }).catchError((error) {
        print('Erro ao obter a embalagem mais recente: $error');
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return formattedDate;
  }

  String formatDate(String text) {
    if (text.length >= 3 && text.substring(2, 3) != '/') {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }
    if (text.length >= 6 && text.substring(5, 6) != '/') {
      text = text.substring(0, 5) + '/' + text.substring(5);
    }
    return text;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    _dataAtualController.text = getCurrentDate();
    _horaAtual.text = getCurrentTime();
    String currentDate = getCurrentDate();

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
                        'OBSERVAÇÕES',
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
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Data de fabricação",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 25, left: 15, right: 15),
                child: Text("$currentDate"),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Data de validade",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  DateTime now = DateTime.now();
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: now,
                    maxTime: DateTime(2100),
                    onChanged: (date) {},
                    onConfirm: (date) {
                      setState(() {
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(date);
                        _dataValidadeController.text = formattedDate;
                      });
                    },
                    currentTime: now,
                    locale: LocaleType.pt,
                    theme: DatePickerTheme(
                      cancelStyle: TextStyle(
                        color: Color(0xFF6C1BC8),
                      ), // Cor do botão cancelar
                      doneStyle: TextStyle(
                        color: Color(0xFF6C1BC8),
                      ), // Cor do botão confirmar
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dataValidadeController,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'DD/MM/YYYY',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Funcionário que montou",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextField(
                controller: _nomeFuncionarioController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Observações",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextField(
                controller: _observacoesController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                                adicionarArrayObservacoes();
                              },
                              child: Text(
                                "Gerar Etiqueta",
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
      ),
    );
  }

  void processoImprimiu(int imprimiu) {
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

        documentRef.update({"imprimiu": imprimiu}).then((_) {
          print("imprimiu adicionado com sucesso");
        }).catchError((error) {
          print("Erro ao adicionar imprimiu: $error");
        });
      } else {
        print("A tabela Embalagem está vazia.");
      }
    }).catchError((error) {
      print('Erro ao obter a embalagem mais recente: $error');
    });
  }
}
