import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  List _toDoList = [];
  TextEditingController toDocontroller = TextEditingController();

  Map<String, dynamic> _lastRemover;
  int _postRemover;

  @override
  void initState() {
    super.initState();
    readDados().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void addToDO() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDocontroller.text;
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      toDocontroller.text = "";
      salvarDados();
    });
  }

  Future<File> getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/lista_tarefas.json");
  }

  Future<File> salvarDados() async {
    String data = json.encode(_toDoList);
    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<String> readDados() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a,b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      salvarDados();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de tarefa",
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                    controller: toDocontroller,
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: addToDO,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _toDoList.length,
                    itemBuilder: buidItem),
                onRefresh: _onRefresh),
          )
        ],
      ),
    );
  }

  Widget buidItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white)),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (ok) {
          setState(() {
            _toDoList[index]["ok"] = ok;
            salvarDados();
          });
        },
      ),
      onDismissed: (direcao) {
        setState(() {
          _lastRemover = Map.from(_toDoList[index]);
          _postRemover = index;
          _toDoList.removeAt(index);
          salvarDados();
          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemover["title"]}\"removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_postRemover, _lastRemover);
                    salvarDados();
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
