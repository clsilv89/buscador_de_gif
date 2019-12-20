import 'dart:convert';
import 'package:share/share.dart';
import 'package:buscador_de_gif/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  String query;
  int offset = 19;

  String trending =
      "https://api.giphy.com/v1/gifs/trending?api_key=kCZ22oKU83qjuQl6cWc0AWlkgXdnYxXN&limit=20&rating=R";
  String titleIcon =
      "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif";

  Future<Map> _searchGifs() async {
    http.Response response;
    if (query == null || query.isEmpty) {
      response = await http.get(trending);
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=kCZ22oKU83qjuQl6cWc0AWlkgXdnYxXN&q=$query&limit=25&offset=$offset&rating=R&lang=en");
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();

    _searchGifs().then((map) {
      print(map);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.network(titleIcon),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Pesquise Aqui!",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder()),
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                onChanged: (text) {
                  setState(() {
                    query = text;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _searchGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 150.0,
                          height: 150.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return _createContentTable(context, snapshot);
                    }
                  }),
            )
          ],
        ));
  }

  int _getCount(List data) {
    if (query == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _createContentTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (query == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: kTransparentImage,
                  image: snapshot
                      .data["data"][index]["images"]["fixed_height"]["url"]
              ),
          onTap: () {
          Navigator.push(context, MaterialPageRoute(
          builder: (context) => GifPage(snapshot.data["data"][index])
          ));
          },
          onLongPress: () {
          Share.share("Se liga nesse gif!!! ${snapshot.data["data"][index]["images"]["fixed_height"]["url"]}");
          },
          );
          } else
          return Container(
          child: GestureDetector(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Icon(
          Icons.add,
          color: Colors.white,
          size: 70.0,
          ),
          Text(
          "Carregar Mais",
          style: TextStyle(color: Colors.white, fontSize: 22.0),
          )
          ],
          ),
          onTap: () {
          setState(() {
          offset += 19;
          });
          },
          )
          ,
          );
        });
  }
}
