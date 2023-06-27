import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qlevar_router/qlevar_router.dart';

import 'gerarEtiquetaPage.dart';
import 'historicoInfoPage.dart';

class Scanner extends StatefulWidget {
  @override
  _Scanner createState() => _Scanner();
}

class _Scanner extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanSuccess = false;
  String teste = "";
  
  
  void onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        scanSuccess = true;
      });

      final qrRoute = scanData.code; // Get the scanned QR code value
      teste = qrRoute ?? ""; // Assign the value to teste, handling null case
      print("onQRViewCreated");
      print(scanData.code);

      if (qrRoute != null && qrRoute.length >= 2) {
        // Extract the last two digits from qrRoute
        final lastTwoDigits = qrRoute.substring(qrRoute.length - 2);

        // Convert lastTwoDigits to int
        final idEmbalagemInt = int.tryParse(lastTwoDigits) ?? 0;
        print(idEmbalagemInt);
        getIdEmbalagemFromFirebase(idEmbalagemInt);
        controller.dispose();//fecha a camera
        
        // Navigate to the linked page (historicoInfo) passing the ID
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => historicoInfo(idEmbalagem: idEmbalagemInt),
          ),
        );*/
      } else {
        // Handle the case when qrRoute is null or has length less than 2
        // Show an error message or take appropriate action
      }
    });
  }


  Future<void> getIdEmbalagemFromFirebase(int idEmbalagemInt) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('embalagem')
        .where('id', isEqualTo: idEmbalagemInt)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      
      final document = snapshot.docs.first;
      final idEmbalagem = document.data()['id'];
  print('entrei');
  print(idEmbalagemInt);
  print('id getEmbalagem');
  print(idEmbalagem);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => historicoInfo(idEmbalagem: idEmbalagem),
        ),
      );
    } else {
      print('nao deu ${idEmbalagemInt}');
      // Handle the case when the ID is not found or there is an error
      // Show an error message or take appropriate action
    }
  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
                        'Leitura de Etiquetas',
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
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scanSuccess
                  ? Text('${teste}')
                  : Text('Scan QR Code'),
            ),
          ),
        ],
      ),
    );
  }
}
