import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './helpers/custom_route.dart';

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
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // ProxyProvider depends on the Auth provider, hence Auth should be defined first
          //can also use value constructor without context
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            (previousProducts == null ? [] : previousProducts.items),
          ), // previousProducts ensures that the Products state isn't lost
        ),
        ChangeNotifierProvider(
          //can also use value constructor without context
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          //can also use value constructor without context
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            (previousOrders == null ? [] : previousOrders.orders),
          ),
        ),
      ], // creates an instance of products provider & makes it available to children widgets of MaterialApp
      child: Consumer<Auth>(
        //rebuilds whenever that auth state changes with notifylistener
        builder: (ctx, auth, _) => MaterialApp(
          // use value constructor only when attched widgets are recycled
          title: '.4pex',
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            primaryColor: Colors.cyan[300],
            accentColor: Colors.amber,
            fontFamily: 'Lato',
            visualDensity: VisualDensity.adaptivePlatformDensity,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authSnap) =>
                      authSnap.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
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
