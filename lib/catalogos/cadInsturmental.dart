import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class cadInstrumental extends StatefulWidget {
  @override
  _CadInstrumentalState createState() => _CadInstrumentalState();
}

class _CadInstrumentalState extends State<cadInstrumental> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _tipoControllerAux = TextEditingController();
  final _fotoController = TextEditingController();
  final _fotoControllers = <TextEditingController>[];
  final _imagePaths = <String>[];
  Uuid uuid = Uuid();

  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;
  bool uploading = false;
  double total = 0;
  final FirebaseStorage storage = FirebaseStorage.instance;

  int currentImageIndex = 0;

  List<Map<String, dynamic>> tipo = [];

  String shortId = '';

  File? _selectedImage;
  
 String idInstruAtual = '';

  @override
  void initState() {
    super.initState();
    idInstruAtual = generateShortId();
    buscarTiposInstrumentos();
    loadImages();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoControllerAux.dispose();
    for (var controller in _fotoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String generateId() {
    String uniqueId = uuid.v4();
    shortId = uniqueId
        .substring(0, 4)
        .toUpperCase(); // Extrair os primeiros 4 caracteres
    return shortId;
  }
  
  

    
  Widget buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _fotoControllers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(
                _imagePaths[index],
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  deleteImage(index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  loadImages() async {
    // final SharedPreferences prefs = await _prefs;
    // arquivos = prefs.getStringList('images') ?? [];

    // if (arquivos.isEmpty) {
      
    refs = (await storage.ref('images').listAll()).items;
    for (var ref in refs) {
      final arquivo = await ref.getDownloadURL();
      arquivos.add(arquivo);
    }
    
    // prefs.setStringList('images', arquivos);
    // }
    setState(() => loading = false);
  }

  deleteImage(int index) async {
    await storage.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    _imagePaths.removeAt(index);
    setState(() {});
  }


Future<UploadTask> upload(String path, String instrumentalId, int index) async {
  File file = File(path);
  try {
    String fileName = 'img-$instrumentalId-${index + 1}.jpeg';
    String ref = 'instrumentais/$fileName';
    final storageRef = FirebaseStorage.instance.ref();
    UploadTask task = storageRef.child(ref).putFile(
      file,
      SettableMetadata(
        cacheControl: "public, max-age=300",
        contentType: "instrumentais/jpeg",
        customMetadata: {
          "user": "123",
        },
      ),
    );

    task.snapshotEvents.listen((TaskSnapshot snapshot) async {
      if (snapshot.state == TaskState.success) {
        String imagePath = await storageRef.child(ref).getDownloadURL();
        setState(() {
          _imagePaths.add(imagePath); // Adicionar o caminho da imagem à lista
        });
      }
    });

    return task;
  } on FirebaseException catch (e) {
    throw Exception('Erro no upload: ${e.code}');
  }
}



  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<XFile?> getGalleryImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  String generateShortId() {
    String uniqueId = Uuid().v4();
    String shortId = uniqueId.substring(0, 4).toUpperCase();
    return shortId;
  }
  
 Future<void> pickAndUploadImage() async {
  XFile? imageFile = await getImage();

  if (imageFile != null) {
    File file = File(imageFile.path);

    bool imageExists = _imagePaths.contains(file.path);
    if (!imageExists) {
      int index = currentImageIndex; // Use the current index

      UploadTask task = await upload(file.path, idInstruAtual, index);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        }
      });

      // Increment the current index
      currentImageIndex++;
    }
  }
}





  Future<void> buscarTiposInstrumentos() async {
    try {
      QuerySnapshot querySnapshot =
          await db.collection('tipo_instrumental').get();

      setState(() {
        tipo = querySnapshot.docs
            .map<Map<String, dynamic>>(
                (doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (error) {
      print('Erro ao buscar os tipos de instrumentos: $error');
    }
  }

  Future<String> cadastrarInstrumental() async {
  
  int tipo = int.parse(_tipoControllerAux.text);
  String imagemUrl = _fotoController.text; // Obtenha o caminho da imagem do campo de texto

  Map<String, dynamic> instrumentalData = {
    "id": idInstruAtual,
    "nome": _nomeController.text,
    "tipo": tipo,
    "imagemUrl": imagemUrl, // Adicione o caminho da imagem ao documento
  };

  DocumentReference documentRef = db.collection("instrumentais").doc(idInstruAtual);

  await documentRef.set(instrumentalData).catchError((error) {
    print('Erro ao adicionar dados: $error');
  });

  return idInstruAtual;
}

Future<void> removeImages() async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ListResult result = await storage.ref('instrumentais').listAll();

  for (final Reference ref in result.items) {
    final String fileName = ref.name;

    if (fileName.contains('$idInstruAtual')) {
      await ref.delete();
    }
  }
}

// Chame a função removeImages() para remover as imagens

  void mostrarModalBar() {
    List<Map<String, dynamic>> filteredCaixas = List.from(tipo);
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              // ...
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: filteredCaixas.map((caixa) {
                    // ...
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ...
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${caixa['nome'][0].toUpperCase()}${caixa['nome'].substring(1)}',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${caixa['id']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),

                            InkWell(
                              onTap: () {
                                setState(() {
                                  _tipoControllerAux.text =
                                      caixa['id'].toString();
                                  ;
                                  _tipoController.text = caixa['nome']
                                      .toString(); // Adicionar o ID do tipo ao campo de texto "Tipo"
                                });
                                Navigator.pop(
                                    context); // Fechar a ModalBottomSheet
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
                removeImages();
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
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Nome do Instrumental"),
                  ),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Tipo"),
                  ),
                  TextFormField(
                    controller: _tipoController,
                    readOnly: true, // Set readOnly to true
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          mostrarModalBar(); // Chamar a função mostrarModalBar()
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo obrigatório";
                      }
                      return null;
                    },
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
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Flexible(
                  child: ElevatedButton(
                    child: Text('Adicionar Imagem'),
                    onPressed: () {
                      pickAndUploadImage();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 10.0,
                      backgroundColor: Color(0xFF6C1BC8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
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


                  SizedBox(
                    height: 20,
                  ),
                 
                  Text(
                    'Imagens Inseridas:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _imagePaths.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(
                        _imagePaths[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  SizedBox(height: 20,),
                   Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 60,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cadastrarInstrumental();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Instrumental cadastrado com sucesso!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                    context,
                                                    '/',
                                                    (route) => false,
                                                  );
                                                },
                                                child: Text('Finalizar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Cadastrar",
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
      }),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
