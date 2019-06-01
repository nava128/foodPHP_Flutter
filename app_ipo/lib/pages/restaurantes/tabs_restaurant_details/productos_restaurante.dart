import 'package:flutter/material.dart';
import 'package:app_ipo/model/producto_model.dart';
import 'package:app_ipo/model/pedido_model.dart';
import 'package:app_ipo/components/item_producto_list.dart';

class RestaurantMenus extends StatefulWidget {
  final List<Producto> productos;

  Pedido pedidoActual;

  RestaurantMenus({this.productos, this.pedidoActual});

  @override
  State<StatefulWidget> createState() {
    return _RestaurantMenuState();
  }
}

class _RestaurantMenuState extends State<RestaurantMenus> {
  @override
  Widget build(BuildContext context) {
    if ((widget.productos == null) || widget.productos.length == 0) {
      return new Container(
        child: new Center(
          child: new Text("No hay productos disponibles"),
        ),
      );
    } else {
      return new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.productos.length,
          itemBuilder: (context, int item) => new ItemProductoList(
              widget.productos[item], widget.pedidoActual));
    }
  }
}
