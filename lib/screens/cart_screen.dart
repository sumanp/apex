import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderNowBtn(cart: cart)
                  ]),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: cart.items.length <= 0
                ? Center(
                    child: Text(
                        'Empty cart. Please add your items to your cart to order.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartItem(
                      id: cart.items.values.toList()[i].id,
                      productId: cart.items.keys.toList()[i],
                      price: cart.items.values.toList()[i].price,
                      title: cart.items.values.toList()[i].title,
                      quantity: cart.items.values.toList()[i].quantity,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class OrderNowBtn extends StatefulWidget {
  const OrderNowBtn({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderNowBtnState createState() => _OrderNowBtnState();
}

class _OrderNowBtnState extends State<OrderNowBtn> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              // if onPressed is set to null flutter automatically disables the button
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Yay! We received your order')));
            },
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      textColor: Theme.of(context).accentColor,
    );
  }
}
