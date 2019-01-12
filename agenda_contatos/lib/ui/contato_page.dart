import 'dart:io';

import 'package:agenda_contatos/objetos/contatos.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _nomeControle = TextEditingController();
  final _emailControle = TextEditingController();
  final _foneControle = TextEditingController();

  final _nameFocus = FocusNode();

  Contato _editarContato;
  bool _userEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      _editarContato = Contato();
    } else {
      _editarContato = Contato.fromMap(widget.contato.toMap());

      _nomeControle.text = _editarContato.nome ?? "";
      _emailControle.text = _editarContato.email ?? "";
      _foneControle.text = _editarContato.fone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editarContato.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editarContato.nome != null && _editarContato.nome.isNotEmpty) {
              Navigator.pop(context, _editarContato);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editarContato.img != null
                              ? FileImage(File(_editarContato.img))
                              : AssetImage("images/person.png"))),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    if(file == null) return;
                    setState(() {
                      _editarContato.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdit = true;
                  setState(() {
                    _editarContato.nome = text;
                  });
                },
                controller: _nomeControle,
                focusNode: _nameFocus,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdit = true;
                  _editarContato.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                controller: _emailControle,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text) {
                  _userEdit = true;
                  _editarContato.fone = text;
                },
                keyboardType: TextInputType.phone,
                controller: _foneControle,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdit) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alteracao"),
              content: Text("Se sair as alteracoes serao perdidas"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sair"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
