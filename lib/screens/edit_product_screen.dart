import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/add-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imgFocusNode = FocusNode();
  final _form = GlobalKey<FormState>(); //hooks form with an accessor
  var _editedProduct = Product(
    id: null,
    description: '',
    title: '',
    price: 0,
    imageUrl: '',
  ); // simila to rails new instance

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;

  @override
  void initState() {
    _imgFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // fetch product from passed route argument
    if (_isInit) {
      //didChangeDependencies runs multiple times, this if block only runs once
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct
            .imageUrl; // setting default url to controller instead of setting initial value
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override //clear focus nodes from memory to avoid memory leaks, dispose is a stateful widgets lifecycle function
  void dispose() {
    _imgFocusNode.removeListener(
        updateImageUrl); //remove listner as well just to be safe
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imgFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void updateImageUrl() {
    if (!_imgFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty) {
        // don't show a preview of incorrect url, can add more valid url checks
        return;
      }

      setState(() {}); //just rebuilds the screen to render the preview
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save(); //takes the value
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(
          _editedProduct); // _editedProduct is a complete valid Product object at this stage
    }
    Navigator.of(context).pop(); // go back to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editedProduct.id == null ? Text('Add Product') : Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form, //hooks form content with above defined accessor
          child: ListView(children: <Widget>[
            TextFormField(
              initialValue: _initValues['title'],
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Use your thumb dammit!';
                }
                if (value.length < 5) {
                  return 'You cheap potato! Title should be in the range of 5 to 15 chars.';
                }
                return null;
                // return null = correct input
              },
              onSaved: (value) {
                _editedProduct = Product(
                  title: value,
                  price: _editedProduct.price,
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  id: _editedProduct.id,
                  isFavourite: _editedProduct.isFavourite,
                );
              },
            ),
            TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(
                      _descFocusNode); //focusnode stores a pointer, kind of like css id
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Use your thumb dammit! Enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Was that valid number? Dum Dum!';
                  }
                  if (double.parse(value) < 0.5) {
                    return 'What are you selling? An atom?';
                  }
                  return null;
                  // return null = correct input
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: double.parse(value),
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    id: _editedProduct.id,
                    isFavourite: _editedProduct.isFavourite,
                  );
                }),
            TextFormField(
              initialValue: _initValues['description'],
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              focusNode: _descFocusNode,
              keyboardType: TextInputType
                  .multiline, //enter key used for next line, hence no cursor shift handled
              onSaved: (value) {
                _editedProduct = Product(
                  title: _editedProduct.title,
                  price: _editedProduct.price,
                  description: value,
                  imageUrl: _editedProduct.imageUrl,
                  id: _editedProduct.id,
                  isFavourite: _editedProduct.isFavourite,
                ); //overrides
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Use your thumb dammit!';
                }
                if (value.length < 20) {
                  return 'Description should be atleast 20 chrs. No life stories here please!';
                }
                return null;
                // return null = correct input
              },
            ),
            SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(top: 8, right: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: _imageUrlController.text.isEmpty //url validation skipped
                    ? Text('preview')
                    : FittedBox(
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Expanded(
                child: TextFormField(
                  //takes as much width, problem when used with row
                  // initialValue: _initValues['imageUrl'], set initValue to controller in this case where controller is defined
                  decoration: InputDecoration(labelText: 'Enter Image URL'),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  controller:
                      _imageUrlController, // to get catch the value of the field before submission for preview
                  focusNode: _imgFocusNode, //when focus changes
                  onFieldSubmitted: (_) {
                    _saveForm();
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Use your thumb dammit!';
                    }
                    return null;
                    // return null = correct input
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      imageUrl: value,
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
              )
            ]),
          ]),
        ),
      ),
    );
  }
}
