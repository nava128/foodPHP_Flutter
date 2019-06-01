import 'package:flutter/material.dart';

//my own imports
import 'package:app_ipo/components/listview_foodCategories.dart';
import 'package:app_ipo/components/listview_restaurants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_ipo/model/restaurante_model.dart';
import 'package:app_ipo/model/user_model.dart';
import 'package:app_ipo/data/gestorBBDD.dart';
import 'package:app_ipo/pages/my_drawer.dart';

class RestaurantesPage extends StatefulWidget {
  //Variable estática que se utiliza en routes.dart
  static const nombreRuta = "/restaurantes";
  User user;
  RestaurantesPage(this.user);

  @override
  State<StatefulWidget> createState() => new _RestaurantesPageState();
}

class _RestaurantesPageState extends State<RestaurantesPage> {
  // I need something like this To determine if SliverAppBar is expanded or not.
  ScrollController _scrollController;
  bool isAppBarExpanded = false;

  //Listado de todos los restaurantes recuperados del servidor
  List<Restaurante> listTodosRestaurantes;
  //Listado de restaurantes con resultados de la búsqueda
  List<Restaurante> listFiltroRestaurantes;
  bool isLoading;

  void _fetchRestaurants() async {
    setState(() {
      isLoading = true;
    });

    listTodosRestaurantes = await ConectorBBDD.restaurantes();
    listFiltroRestaurantes = new List.from(listTodosRestaurantes);

    if (this.mounted) {
      /*Si no comprobamos esto, puede saltar excepción si cambiamos
       de página antes de que la descarga se haya completado*/
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _fetchRestaurants();
  }
/*
  bool get _changecolor {
    return _scrollController.hasClients &&
        _scrollController.offset >
            ((MediaQuery.of(context).size.height / 2.5) - kToolbarHeight);
  }
  */

  bool get _changecolor {
    if (_getAppBarCollapsePercent() == 1)
      return true;
    else {
      return false;
    }
  }

  double _getAppBarCollapsePercent() {
    if (!_scrollController.hasClients || _scrollController.positions.length > 1)
      return 0.0;

    return (_scrollController.offset /
            ((MediaQuery.of(context).size.height / 2.5) - kToolbarHeight))
        .clamp(0.0, 1.0);
  }

  Widget _panelBusqueda() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height / 3.5,
      decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.9), BlendMode.modulate),
              image: AssetImage(
                "images/customer-experience2.jpg",
              ),
              fit: BoxFit.cover)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Pide lo que te pida el cuerpo',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Comida a domicilio online cerca de ti',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      margin: EdgeInsets.only(left: 40, right: 40),
                      padding: EdgeInsets.only(
                          top: 4, left: 10, right: 4, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ]),
                      child: new Row(
                        children: <Widget>[
                          new Flexible(
                            child: new TextField(
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.black),
                              decoration: InputDecoration.collapsed(
                                hintText: "ej. Calle Alcalá, 48, Madrid",
                              ),
                            ),
                          ),
                          new FlatButton(
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold),
                            ),
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () {
                              print("Has presionado el botón de búsqueda");
                              Fluttertoast.showToast(
                                  msg: "Funcionalidad no implementada... :(");
                            },
                          ),
                        ],
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        //elevation: 0.0, //Quitar sombra de la appBar
        title: new Text('Food Finder'),
        centerTitle: true,
      ),
      drawer: MyDrawer(widget.user, index: MyDrawer.indexRestaurantes),
      body: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //Panel superior con cuadro de búsqueda por localización

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text('Tipos de cocinas populares'),
            ),
            //Scroll horizontal con categorías de restaurantes
            RestaurantTypeList(),
            //Listado de restaurantes según el filtro
            Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      )
                    : RestaurantsList(listTodosRestaurantes))
            //RestaurantsList(),
          ],
        ),
      ),
    );*/
    return Scaffold(
      drawer: MyDrawer(widget.user, index: MyDrawer.indexRestaurantes),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              iconTheme: IconThemeData(
                color: _changecolor
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).bottomAppBarColor,
              ),
              backgroundColor: Theme.of(context).bottomAppBarColor,
              expandedHeight: MediaQuery.of(context).size.height / 2.5,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _changecolor ? "Food Finder" : '',
                  ),
                  centerTitle: true,
                  background: _panelBusqueda()),
            ),
          ];
        },
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text('Tipos de cocinas populares'),
              ),
              //Scroll horizontal con categorías de restaurantes
              RestaurantTypeList(),
              //Listado de restaurantes según el filtro
              Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          ),
                        )
                      : RestaurantsList(listTodosRestaurantes))
              //RestaurantsList(),
            ],
          ),
        ),
      ),
    );
  }
}
