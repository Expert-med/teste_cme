import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:teste_catalogo/bottomNav/catalogPage.dart';
import 'package:teste_catalogo/bottomNav/funcoesPage.dart';
import 'package:teste_catalogo/catalogoCaixas.dart';
import 'package:teste_catalogo/homePage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:qlevar_router/qlevar_router.dart';

import 'historicoInfoPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> embalagens = [];

 
      

  
  
  @override
  Widget build(BuildContext context) {


    return GetMaterialApp(
      title: 'Catalog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomePage(),
        ),
        GetPage(
          name: '/historicoInfo',
          page: () => historicoInfo(idEmbalagem: 1),
        ),
      ],
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [
    homePage(),
     FuncoesPage(),
    catalogPage(),
  
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor:   Color(0xFF6C1BC8),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Funções',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Catálogos',
          ),
         
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
