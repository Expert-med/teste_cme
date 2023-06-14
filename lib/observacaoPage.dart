//observacoes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter/services.dart';

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
  List<Map<String, dynamic>> caixas = [];

  void adicionarArrayObservacoes() {
    print('entrou em adicionarArrayCaixaEmbalagem');
    String dataValidade = _dataValidadeController.text;
    String nomeFuncionario = _nomeFuncionarioController.text;
    String observacoes = _observacoesController.text;
    String dataAtual = _dataAtualController.text;
    
    if (dataValidade == '' || nomeFuncionario == '' || observacoes == '' || dataAtual=='') {
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
                child: Text('Continuar'),
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
        } else {
          print("A tabela Embalagem está vazia.");
        }
      }).catchError((error) {
        print('Erro ao obter a embalagem mais recente: $error');
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text('Informações adicionadas com sucesso'),
           actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => gerarEtiqueta(idCaixa: widget.idCaixa),
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

  @override
  Widget build(BuildContext context) {
    _dataAtualController.text = getCurrentDate();
    String currentDate = getCurrentDate();
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
          'Informações Adicionais',
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
              child: Text("$currentDate "),
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
            TextField(
      controller: _dataValidadeController,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.singleLineFormatter,
      ],
      onChanged: (text) {
        setState(() {
          _dataValidadeController.text = formatDate(text);
          _dataValidadeController.selection =
              TextSelection.fromPosition(TextPosition(offset: _dataValidadeController.text.length));
        });
      },
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
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "Funcionário que montou a caixa",
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