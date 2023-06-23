import 'package:dio/dio.dart';
import 'package:ecommerce/final_cart_data.dart';
import 'package:ecommerce/model/fakestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/model/cartproduct.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Buy Goods'),
    );
  }
}

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

  fakeStoreData() async {
    Dio dio = Dio();
    final response = await dio.get('https://fakestoreapi.com/products/');
    responseDatas = response.data
        .map((e) {
          return FakeStore.fromJson(e);
        })
        .toList()
        .cast<FakeStore>();
    return responseDatas;
  }

  void getByCategory() async {
    Dio dio = Dio();
    final categoryResponse =
        await dio.get('https://fakestoreapi.com/products/categories');
    categoryData = categoryResponse.data;
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
    fakeStoreData();
  }

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  List<CartProduct> carts = [];
  TextEditingController quantityUpdate = TextEditingController();
  TextEditingController searchProduct = TextEditingController();
  List<CartProduct> searchProducts = [];

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
                                        return AlertDialog(
                                          title: const Text(
                                              'update your quantity'),
                                          actions: [
                                            TextField(
                                              decoration: const InputDecoration(
                                                  hintText: 'update quantity'),
                                              controller: quantityUpdate,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  final values =
                                                      quantityUpdate.text;

                                                  setState(() {
                                                    cart.quantity =
                                                        int.parse(values);
                                                  });
                                                  quantityUpdate.clear();
                                                },
                                                icon: const Icon(Icons.update)),
                                          ],
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return FinalCartData(
                            finalCartData: carts,
                          );
                        },
                      ));
                    },
                    child: const Text('Click to purchase'),
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
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.all(20),
                      child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchProducts = carts
                                  .where((element) => element
                                      .fakeStores.category
                                      .contains(value))
                                  .toList();
                            });
                          },
                          controller: searchProduct,
                          decoration: InputDecoration(
                              hintText: "Search for Product",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                    )),
                    IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                      children: categoryData.map((e) {
                    return Column(
                      children: [
                        Text(
                          e[0].toString().toUpperCase() +
                              e.toString().substring(1).toLowerCase(),
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                        FutureBuilder<List<FakeStore>>(
                          future: getByCategoryName(e),
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
                                                          element
                                                              .fakeStores.id ==
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
                                                        .resolveWith((states) =>
                                                            Colors.black),
                                              ),
                                              child: const Text('Add to cart'),
                                            )
                                          ],
                                        ),
                                      ));
                                }).toList()),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      ],
                    );
                  }).toList()),
                ),
              ],
            ),
          )),
    );
  }
}
