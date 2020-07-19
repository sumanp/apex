import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context); // Will create infinte loop of data fetch, replacing with consumer

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnap) {
          if (dataSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (dataSnap.error != null) {
            return Center(child: Text('An Error occured'));
          } else {
            return Consumer<Orders>(
              builder: (ctx, orderData, _) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
              ),
            );
          }
        },
      ),
    );
  }
}
