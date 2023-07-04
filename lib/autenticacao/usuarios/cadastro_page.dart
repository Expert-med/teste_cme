import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:teste_catalogo/homePage.dart';

class CadastroFunPage extends StatefulWidget {
  @override
  _CadastroFunPage createState() => _CadastroFunPage();
}

class _CadastroFunPage extends State<CadastroFunPage> {
  @override
  Widget build(BuildContext context) {
     final _nomeController = TextEditingController();
     final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
 // final _firebaseAuth = FirebaseAuth.instance;

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
                    'CADASTRO DE FUNCIONÁRIOS',
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
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15), //apply padding to all four sides
              child: Text("Nome Completo"),
            ),
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20))),
            ),
            Padding(
              padding: EdgeInsets.all(15), //apply padding to all four sides
              child: Text("Email"),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20))),
            ),
            Padding(
              padding: EdgeInsets.all(15), //apply padding to all four sides
              child: Text("Senha"),
            ),
            TextFormField(
              controller: _passwordController,
               obscureText: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(height: 16.0),
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
                      //login();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.black,
                      elevation: 10.0,
                      backgroundColor: Color(0xFF6C1BC8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => homePage(),
                        ),
                      );
                    },
                    child: Text(
                      "Criar conta",
                      style: TextStyle(
                        color: Color(0xFF6C1BC8),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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