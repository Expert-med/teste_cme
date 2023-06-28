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
  Uuid uuid = Uuid();

  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;
  bool uploading = false;
  double total = 0;
  final FirebaseStorage storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> tipo = [];

  String shortId = '';

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    generateId();
    buscarTiposInstrumentos();
    loadImages();
  }
  String generateId() {
  String uniqueId = uuid.v4();
  shortId = uniqueId.substring(0, 4).toUpperCase(); // Extrair os primeiros 4 caracteres
  return shortId;
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
    setState(() {});
  }

  Future<void> uploadImageToFirebaseStorage(
      File imageFile, String instrumentalId, String imagePath) async {
    try {
      String fileName =
          'img-$instrumentalId'; // Use the instrumental ID as the file name
      Reference storageRef =
          FirebaseStorage.instance.ref().child('instrumentais/$fileName');
      await storageRef.putFile(imageFile);

      // Update the Firestore document with the image path
      await FirebaseFirestore.instance
          .collection('instrumentais')
          .doc(instrumentalId)
          .update({
        'imagem': imagePath,
      });

      print('Image uploaded successfully. Image path: $imagePath');
    } catch (error) {
      print('Error uploading image to Firebase Storage: $error');
    }
  }

  Future<UploadTask> upload(String path, String instrumentalId) async {
    File file = File(path);
    try {
      String fileName =
          'img-$shortId'; // Usando o ID do instrumental como nome do arquivo
      String ref = 'instrumentais/$fileName.jpeg';
      final storageRef = FirebaseStorage.instance.ref();
      return storageRef.child(ref).putFile(
            file,
            SettableMetadata(
              cacheControl: "public, max-age=300",
              contentType: "instrumentais/jpeg",
              customMetadata: {
                "user": "123",
              },
            ),
          );
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future<XFile?> getGalleryImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  pickAndUploadImage() async {
    XFile? imageFile = await getGalleryImage();
    String instrumentalId = shortId;

    if (imageFile != null) {
      File file = File(imageFile.path);

      UploadTask task = await upload(file.path, shortId);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        } else if (snapshot.state == TaskState.success) {
          final photoRef = snapshot.ref;

          arquivos.add(await photoRef.getDownloadURL());
          refs.add(photoRef);

          setState(() => uploading = false);

          String filePath = photoRef.fullPath;

          // Update the text field with the image path
          setState(() {
            _fotoController.text = filePath;
            uploading = false;

            // Call the method to save the image path in Firestore
            uploadImageToFirebaseStorage(file, instrumentalId, filePath);
          });
        }
      });
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
    String imagemUrl =
        _fotoController.text; // Obter o caminho da imagem do campo de texto

    Map<String, dynamic> embalagem = {
      "id": shortId,
      "nome": _nomeController.text,
      "tipo": tipo,
      "imagem": imagemUrl, // Adicionar o caminho da imagem ao documento
    };

    DocumentReference documentRef = db.collection("instrumentais").doc(shortId);

    await documentRef.set(embalagem).catchError((error) {
      print('Erro ao adicionar dados: $error');
    });

    return shortId;
  }

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
                        'CADASTRAR INSTRUMENTAL',
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
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Foto"),
                  ),
                  TextFormField(
                    controller: _fotoController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    readOnly: true,
                    onTap: pickAndUploadImage,
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
                              child: ElevatedButton(
                                onPressed: () {
                                   cadastrarInstrumental();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Instrumental cadastrado com sucesso!'),
                            actions: [
                              
                              TextButton(
                                onPressed: () {
                                  
                                  Navigator.pushNamedAndRemoveUntil(
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
                                  backgroundColor:
                                       Color(0xFF6C1BC8),
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
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: arquivos.isEmpty
                        ? const Center(child: Text('Não há imagens ainda.'))
                        : ListView.builder(
                            itemBuilder: (BuildContext context, index) {
                              return ListTile(
                                leading: SizedBox(
                                  width: 60,
                                  height: 40,
                                  child: Image(
                                    image: CachedNetworkImageProvider(
                                        arquivos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text('Image $index'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteImage(index),
                                ),
                              );
                            },
                            itemCount: arquivos.length,
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
