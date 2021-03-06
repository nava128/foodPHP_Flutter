import 'package:flutter/material.dart';

//my own imports
import 'package:app_ipo/model/restaurante_model.dart';
import 'package:app_ipo/model/opinionRest_model.dart';
import 'package:app_ipo/model/producto_model.dart';
import 'package:app_ipo/model/pedido_model.dart';
import 'package:app_ipo/components/star_rating.dart';
import 'package:app_ipo/pages/cart_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_ipo/model/user_model.dart';

//tabs imports
import 'package:app_ipo/pages/restaurantes/tabs_restaurant_details/info_restaurante.dart';
import 'package:app_ipo/pages/restaurantes/tabs_restaurant_details/productos_restaurante.dart';
import 'package:app_ipo/pages/restaurantes/tabs_restaurant_details/opiniones.dart';

//bbdd
import 'package:app_ipo/data/gestorBBDD.dart';

class RestaurantDetailsPage extends StatefulWidget {
  //Propiedad inmutable
  final Restaurante _restaurante;
  final User _user;

  RestaurantDetailsPage(this._restaurante, this._user);

  @override
  State<StatefulWidget> createState() {
    return _RestaurantDetailsState();
  }
}

class _RestaurantDetailsState extends State<RestaurantDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController _controladorTabs;
  bool _isLoadingOpinions = false;
  bool _isLoadingProducts = false;
  bool _isFavorito;
  Pedido _pedidoActual;

  void initState() {
    super.initState();
    _isFavorito = widget._user.isRestauranteFavorito(widget._restaurante);
    _controladorTabs = new TabController(vsync: this, length: 3);
    _fetchOpiniones();
    _fetchProductos();

    _pedidoActual = new Pedido(
        envio: widget._restaurante.envio,
        numPedido: 123456,
        estado:1,
        descuento: widget._restaurante.descuento,
        restaurante: widget._restaurante);
  }

  @override
  void dispose() {
    super.dispose();
    _controladorTabs.dispose();
  }

  void _toggleFavoriteStatus() {
    if (_isFavorito) {
      setState(() {
        _isFavorito = false;
      });
      widget._user.quitarRestaurante(widget._restaurante);
      Fluttertoast.showToast(msg: "Eliminado de restaurantes favoritos");
    } else {
      setState(() {
        _isFavorito = true;
      });
      widget._user.insertarRestauranteFav(widget._restaurante);
      Fluttertoast.showToast(msg: "A??adido a restaurantes favoritos");
    }
  }

  void _fetchOpiniones() async {
    setState(() {
      _isLoadingOpinions = true;
    });

    List<OpinionRestaurante> opiniones =
        await ConectorBBDD.opiniones(widget._restaurante.id);
    widget._restaurante.opiniones = opiniones;

    setState(() {
      _isLoadingOpinions = false;
    });
  }

  void _fetchProductos() async {
    setState(() {
      _isLoadingProducts = true;
    });

    List<Producto> productos =
        await ConectorBBDD.productos(widget._restaurante.id);
    widget._restaurante.productos = productos;

    setState(() {
      _isLoadingProducts = false;
    });
  }

  Widget _backDialog() {
    return new AlertDialog(
      title: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '??Est??s seguro de que quieres volver?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            'Perder??s los datos del pedido seleccionado y todo lo que hayas a??adido al carrito',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          ),
          SizedBox(height: 30),
          new MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Container(
              height: MediaQuery.of(context).size.height / 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              // width: double.infinity,
              child: Center(
                child: Text(
                  "Cancelar".toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          new MaterialButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Container(
              height: MediaQuery.of(context).size.height / 14,
              // width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  border: new Border.all(
                      width: 2.5, color: Theme.of(context).primaryColor)),
              child: Center(
                child: Text(
                  "Estoy seguro".toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() {
    if (_pedidoActual.numProductos() > 0) {
      return showDialog(
              context: context, builder: (context) => _backDialog()) ??
          false;
    } else {
      return Future.value(true);
    }
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    return new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAppBar(Pedido pedido) {
    return new AppBar(
      title: new Text(widget._restaurante.nombre),
      // centerTitle: true,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).bottomAppBarColor,
      actions: <Widget>[
        _btnFavorito(),
        CartPage.cestaCompraBar(context, pedido, widget._user)
      ],
    );
  }

  Widget _btnFavorito() {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent, // makes highlight invisible to
      onPressed: () {
        _toggleFavoriteStatus();
      },
      icon: new Icon(
        _isFavorito ? Icons.favorite : Icons.favorite_border,
        color: Theme.of(context).primaryColor,
        size: 34,
      ),
    );
  }

  Widget _infoRestaurante() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.modulate),
              image: NetworkImage(
                  ConectorBBDD.endpointBBDD + widget._restaurante.imagenFondo),
              fit: BoxFit.cover)),
      child: new Row(children: <Widget>[
        //Informaci??n sobre la imagen del fondo
        Container(
          //Logo del restaurante
          margin: const EdgeInsets.only(left: 25),
          height: MediaQuery.of(context).size.width / 5,
          width: MediaQuery.of(context).size.width / 5,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: new Border.all(color: Colors.white),
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: NetworkImage(ConectorBBDD.endpointBBDD +
                      widget._restaurante.imagenLogo))),
        ),
        Container(
            padding: const EdgeInsets.only(left: 10.0),
            child: new Column(
              //Valoraci??n y categor??a
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
                new Text(
                  widget._restaurante.nombre,
                  style: new TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 18),
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget._restaurante.categoria,
                        style: new TextStyle(color: Colors.white)),
                    new Row(
                      children: <Widget>[
                        StarDisplayWidget(
                          value: widget._restaurante.valoracion,
                          filledStar:
                              Icon(Icons.star, color: Colors.white, size: 13.5),
                          unfilledStar:
                              Icon(Icons.star, color: Colors.grey, size: 13.5),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: new Text(
                              '(' +
                                  widget._restaurante.numValoraciones
                                      .toString() +
                                  ')',
                              style: new TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ))
      ]),
    );
  }

  Widget _tabBar() {
    return Container(
      child: TabBar(
        indicatorColor: Theme.of(context).primaryColor,
        tabs: <Widget>[
          new Tab(
            text: "Men??s",
          ),
          new Tab(
            text: "Opiniones",
          ),
          new Tab(
            text: "Informaci??n",
          )
        ],
        controller: _controladorTabs,
      ),
    );
  }

  Widget _tabBarView() {
    return Expanded(
      child: new TabBarView(
        controller: _controladorTabs,
        children: <Widget>[
          _isLoadingProducts
              ? new Center(
                  child: CircularProgressIndicator(),
                )
              : new RestaurantMenus(
                  widget._restaurante.productos,
                  _pedidoActual,
                  widget._user,
                  descuento: widget._restaurante.descuento,
                ),
          _isLoadingOpinions
              ? new Center(
                  child: CircularProgressIndicator(),
                )
              : new RestaurantOpiniones(
                  opiniones: widget._restaurante.opiniones),
          new RestaurantInfo(widget._restaurante),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: _buildAppBar(_pedidoActual),
        body: new Container(
          child: new Column(
            children: <Widget>[
              //Barra superior con imagen de fondo e informacion del restaurante
              _infoRestaurante(),
              _tabBar(),
              _tabBarView(),
            ],
          ),
        ),
      ),
    );
  }
}
