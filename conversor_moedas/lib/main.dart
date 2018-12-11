import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=303a537c";

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(primaryColor: Colors.white, hintColor: Colors.amber),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dollar, euro;

  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  void _realChanged(String texto) {
    double real = double.parse(texto);
    dolarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String texto) {
    double dollar = double.parse(texto);
    realController.text = (dollar*this.dollar).toStringAsFixed(2);
    euroController.text = ((dollar*this.dollar)/euro).toStringAsFixed(2);
  }

  void _euroChanged(String texto) {
    double euro = double.parse(texto);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = ((euro*this.euro)/dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          "\$Coversor de Moedas\$",
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                );
                break;
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar os Dados...",
                      style: TextStyle(color: Colors.amber),
                    ),
                  );
                } else {
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.attach_money,
                          size: 140,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dollar", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euro", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController controller, Function func) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: TextStyle(color: Colors.amber, fontSize: 18),
      controller: controller,
      onChanged: func,
      keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),

    );
  }
}
