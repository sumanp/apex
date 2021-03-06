import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(
        context); //only rebuilds this widget when data changes, not the entire widget tree, listens for any data updates
    final products = showFavs ? productsData.favItems : productsData.items;

    return products.length <= 0
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'You don\'t have any favourites yet. Go ahead, tap the heart icon on the products you like!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(
                10.0), //use of const avoid rebuild call on the called function
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 5 / 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              //value constructor fixed the widget recycle use when used with listview or gridview
              //adds producer to each product
              value: products[
                  i], // dispose data fetched via provider after pages are popped, ChangeNotifierProvider auto handles this
              child: ProductItem(),
              // update: ChangeNotifierProvider is defined hence data passing as arguments is not required
              //non-forward data or data used in the widget should be passed as an argument
              // passing data to widgets as arguments is normal
            ),
          );
  }
}
