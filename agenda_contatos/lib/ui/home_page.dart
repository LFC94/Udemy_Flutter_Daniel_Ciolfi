import 'dart:io';

import 'package:agenda_contatos/ui/contato_page.dart';
import 'package:flutter/material.dart';
import 'package:agenda_contatos/objetos/contatos.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions{orderAz, orderZa}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Contatos contatos = Contatos();
  List<Contato> listContatos = List();

  @override
  void initState() {
    super.initState();

    _getAllContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                  child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderAz,
              ),
              const PopupMenuItem(
                child: Text("Ordernar de Z-A"),
                value: OrderOptions.orderZa,
              )
            ],
            onSelected: _OrdenarLista,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContatoPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: listContatos.length,
          itemBuilder: (contaxt, index) {
            return _contatosCard(context, index);
          }),
    );
  }

  Widget _contatosCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: listContatos[index].img != null
                            ? FileImage(File(listContatos[index].img))
                            : AssetImage("images/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      listContatos[index].nome ?? "",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      listContatos[index].email ?? "",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      listContatos[index].fone ?? "",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOpcao(context, index);
      },
    );
  }

  void _showOpcao(BuildContext contex, int index) {
    showModalBottomSheet(
        context: contex,
        builder: (contex) {
          return BottomSheet(
              onClosing: () {},
              builder: (contex) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            launch("tel:${listContatos[index].fone}");
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showContatoPage(contato: listContatos[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          onPressed: () {
                            setState(() {
                              contatos.deleteContato(listContatos[index].id);
                              listContatos.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContatoPage({Contato contato}) async {
    final recContato = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContatoPage(
                  contato: contato,
                )));

    if (recContato != null) {
      if (contato != null) {
        await contatos.updateContato(recContato);
      } else {
        await contatos.salvarContato(recContato);
      }
      _getAllContatos();
    }
  }

  void _getAllContatos() {
    contatos.getAllContato().then((list) {
      setState(() {
        listContatos = list;
      });
    });
  }

  void _OrdenarLista(OrderOptions oo){
    switch(oo){
      case OrderOptions.orderAz:
        listContatos.sort((a,b){
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderZa:
        listContatos.sort((a,b){
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
