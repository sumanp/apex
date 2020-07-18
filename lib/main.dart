import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';


import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          //can also use value constructor without context
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          //can also use value constructor without context
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          //can also use value constructor without context
          create: (ctx) => Orders(),
        ),
      ], // creates an instance of products provider & makes it available to children widgets of MaterialApp
      child: MaterialApp(
        // use value constructor only when attched widgets are recycled
        title: '.4pex',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          primaryColor: Colors.cyan[300],
          accentColor: Colors.amber,
          fontFamily: 'Lato',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Apex fitness',
            )
          ],
        ),
      ),
    );
  }
}
