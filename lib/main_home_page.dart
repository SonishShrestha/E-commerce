import 'package:dio/dio.dart';
import 'package:ecommerce/final_cart_data.dart';
import 'package:ecommerce/model/cartproduct.dart';
import 'package:ecommerce/model/fakestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FakeStore> responseDatas = [];
  List categoryData = [];
  List<FakeStore> getDataByCategoryName = [];

  Future<List<FakeStore>> fakeStoreData() async {
    Dio dio = Dio();
    final response = await dio.get('https://fakestoreapi.com/products/');
    responseDatas = response.data;

    return responseDatas;
  }

  Future<void> getByCategory() async {
    Dio dio = Dio();
    final categoryResponse =
        await dio.get('https://fakestoreapi.com/products/categories');

    setState(() {
      categoryData = categoryResponse.data;
    });
  }

  Future<List<FakeStore>> getByCategoryName(String name) async {
    Dio dio = Dio();
    final dataByCategoryName =
        await dio.get('https://fakestoreapi.com/products/category/$name');
    getDataByCategoryName = dataByCategoryName.data
        .map((categorydata) {
          return FakeStore.fromJson(categorydata);
        })
        .toList()
        .cast<FakeStore>();

    return getDataByCategoryName;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getByCategory();
  }

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  List<CartProduct> carts = [];
  TextEditingController quantityUpdate = TextEditingController();
  TextEditingController searchProduct = TextEditingController();
  List<CartProduct> searchProducts = [];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldkey,
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
            actions: [
              IconButton(
                  onPressed: () {
                    scaffoldkey.currentState!.openEndDrawer();
                  },
                  icon: const Icon(Icons.shopping_cart))
            ],
          ),
          endDrawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                      children: carts.map((cart) {
                    return Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(cart.fakeStores.image)),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cart.fakeStores.title),
                            Text('${cart.fakeStores.price * cart.quantity}\$')
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (cart.quantity > 1) {
                                      cart.quantity--;
                                    }
                                  });
                                },
                                icon: const Icon(Icons.remove)),
                            Text(cart.quantity.toString()),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    cart.quantity++;
                                  });
                                },
                                icon: const Icon(Icons.add)),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Form(
                                          key: _formKey,
                                          child: AlertDialog(
                                            title: const Text(
                                                'update your quantity'),
                                            actions: [
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Enter data';
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            'update quantity'),
                                                controller: quantityUpdate,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    final values =
                                                        quantityUpdate.text;
                                                    // if (_formKey.currentState ==
                                                    //     null) {
                                                    //   print(
                                                    //       "_formKey.currentState is null!");
                                                    // } else if (_formKey
                                                    //     .currentState!
                                                    //     .validate()) {
                                                    //   print(
                                                    //       "Form input is valid");
                                                    // }
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      setState(() {
                                                        if (values.isNotEmpty) {
                                                          cart.quantity =
                                                              int.parse(values);
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                      quantityUpdate.clear();
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Please fill up all the required field.")));
                                                    }
                                                  },
                                                  icon:
                                                      const Icon(Icons.update)),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Update'),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        carts.removeWhere((element) =>
                                            cart.fakeStores.id ==
                                            element.fakeStores.id);
                                      });
                                    },
                                    child: const Text('Delete'))
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList()),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        carts.removeWhere((element) => true);
                      });
                    },
                    child: Text('Delete all'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return FinalCartData(
                            finalCartData: carts,
                          );
                        },
                      ));
                    },
                    child: Text('Click to purchase'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.green)),
                  )
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: categoryData.map((e) {
                    return Column(
                      children: [
                        Text(
                          e.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<List<FakeStore>>(
                          future: getByCategoryName(e.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      snapshot.data!.map((byCategoryName) {
                                    return Card(
                                        margin: const EdgeInsets.all(20),
                                        elevation: 10,
                                        shadowColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Colors.grey,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 20),
                                          child: Column(
                                            children: [
                                              Image.network(
                                                byCategoryName.image,
                                                width: 50,
                                              ),
                                              Text(byCategoryName.title),
                                              Text(
                                                  '${byCategoryName.price.toString()}\$'),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    final data = carts.where(
                                                        (element) =>
                                                            element.fakeStores
                                                                .id ==
                                                            byCategoryName.id);
                                                    if (data.isEmpty) {
                                                      carts.add(CartProduct(
                                                          1, byCategoryName));
                                                    } else {
                                                      data.first.quantity++;
                                                    }
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              (states) =>
                                                                  Colors.black),
                                                ),
                                                child:
                                                    const Text('Add to cart'),
                                              )
                                            ],
                                          ),
                                        ));
                                  }).toList(),
                                ),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          )),
    );
  }
}
