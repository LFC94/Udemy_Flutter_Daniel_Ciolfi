import 'dart:convert';

import 'package:buscador_gifs/ui/git_pag.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

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
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
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
              onSubmitted: (text) {
                setState(() {
                  _sSearch = text;
                  _iOffSet = 0;
                });
              },
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                      break;
                    default:
                      if (snapshot.hasError)
                        return Container(
                          child: Text(snapshot.error.toString()),
                        );
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
      sUrl =
          "https://api.giphy.com/v1/gifs/trending?api_key=F1fc11VpQBMPUjiyfCJIfle90gZdsS2z&limit=20&rating=G&lang=pt";
    } else {
      sUrl =
          "https://api.giphy.com/v1/gifs/search?api_key=F1fc11VpQBMPUjiyfCJIfle90gZdsS2z&q=$_sSearch&limit=19&offset=$_iOffSet&rating=G&lang=pt";
    }
    response = await http.get(sUrl);
    return json.decode(response.body);
  }

  int getCount(List data) {
    if (_sSearch == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: getCount(snapshot.data["data"]),
        itemBuilder: (contex, index) {
          if (_sSearch == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child:
              FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height_small"]["url"],
                height: 300.0,
                fit: BoxFit.none,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) =>
                            GifPages(
                                snapshot.data["data"][index]
                            )
                    )
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height_small"]["url"]);
              },
            );
          } else {
            return GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar Mais....",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _iOffSet += 19;
                });
              },
            );
          }
        });
  }
}
