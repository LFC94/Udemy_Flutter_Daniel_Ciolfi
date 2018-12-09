import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _alturaController = TextEditingController();
  String _textoInfo = "Informe seus dados";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Color colorInfo = Colors.black;

  void _resetFields() {
    _pesoController.text = "";
    _alturaController.text = "";
    setState(() {
      _textoInfo = "Informe seus dados";
    });
  }

  double calculaIMC(double altura, double peso) {
    return peso / (altura * altura);
  }

  void calcular() {
    setState(() {
      double imc = calculaIMC(double.parse(_alturaController.text),
          double.parse(_pesoController.text));
      if (imc < 18.6) {
        _textoInfo = "Abaixo do Peso (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.lightGreenAccent;
      } else if (imc >= 18.6 && imc < 24.9) {
        _textoInfo = "Peso Ideal (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.green;
      } else if (imc >= 24.9 && imc < 29.9) {
        _textoInfo = "Levemente Acima do Peso (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.green[900];
      } else if (imc >= 29.9 && imc < 34.9) {
        _textoInfo = "Obesidade Grau I (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.red[200];
      } else if (imc >= 34.9 && imc < 39.9) {
        _textoInfo = "Obesidade Grau II (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.red;
      } else if (imc >= 40) {
        _textoInfo = "Obesidade Grau III (${imc.toStringAsPrecision(4)})";
        colorInfo = Colors.red[900];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calculadora de IMC"),
          centerTitle: true,
          backgroundColor: Colors.lightGreen,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields,
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.person_pin,
                    size: 100.0,
                    color: Colors.green,
                  ),
                  TextFormField(
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: InputDecoration(
                          labelText: "Peso(KG)",
                          labelStyle: TextStyle(color: Colors.green[700])),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[900], fontSize: 20),
                      controller: _pesoController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Insira seu Peso!";
                        }
                      }),
                  TextFormField(
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: InputDecoration(
                          labelText: "Altura(m)",
                          labelStyle: TextStyle(color: Colors.green[700])),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[900], fontSize: 20),
                      controller: _alturaController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Insira sua Altura!";
                        }
                      }),
                  Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Container(
                        height: 50.0,
                        child: RaisedButton(
                          child: Text(
                            "Calcular",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                          color: Colors.lightGreen,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              calcular();
                            }
                          },
                        ),
                      )),
                  Text(
                    _textoInfo,
                    style: TextStyle(color: colorInfo, fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
        )
    );
  }
}
