import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sSearch;
  int _iOffSet = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquisa",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                      break;
                    default:
                      if (snapshot.hasError)
                        return Container(child: Text(snapshot.error.toString()),);
                      else
                       return createGifTable(context, snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  Future<Map> _getGifs() async {
    http.Response response;
    String sUrl;
    if (_sSearch == null) {
      sUrl = "https://api.giphy.com/v1/gifs/trending?api_key=F1fc11VpQBMPUjiyfCJIfle90gZdsS2z&limit=20&rating=G&lang=pt";
    } else {
      sUrl = "https://api.giphy.com/v1/gifs/search?api_key=F1fc11VpQBMPUjiyfCJIfle90gZdsS2z&q=$_sSearch&limit=25&offset=$_iOffSet&rating=G&lang=pt";
    }
    response = await http.get(sUrl);
    return json.decode(response.body);
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {

    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0),
        itemCount: snapshot.data["data"].length,
        itemBuilder: (contex, index){
          return GestureDetector(
            child: Column(
              children: <Widget>[
                Image.network(
                  snapshot.data["data"][index]["images"]["fixed_height_small"]["url"],
                  height:  double.parse(snapshot.data["data"][index]["images"]["fixed_height_small"]["height"]),
                  width: double.parse(snapshot.data["data"][index]["images"]["fixed_height_small"]["width"]),
                  fit: BoxFit.none,
                ),
                Text(
                  snapshot.data["data"][index]["title"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 7,
                      color: Colors.white,
                  ),
                ),
              ],
            )
            ,
          );
        });
  }
}
