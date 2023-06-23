import 'package:ecommerce/model/cartproduct.dart';
import 'package:flutter/material.dart';

class FinalCartData extends StatefulWidget {
  List<CartProduct> finalCartData = [];

  FinalCartData({super.key, required this.finalCartData});

  @override
  State<FinalCartData> createState() => _FinalCartDataState();
}

class _FinalCartDataState extends State<FinalCartData> {
  total() {
    if (widget.finalCartData.isNotEmpty) {
      return widget.finalCartData
          .map((e) => e.fakeStores.price * e.quantity)
          .reduce((value, element) => value + element);
    } else {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Purchase Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: const Text(
                'Your Purchase List',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Column(
                children: widget.finalCartData.map((e) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                    leading: Image.network(e.fakeStores.image),
                    title: Text(e.fakeStores.title),
                    subtitle: Row(
                      children: [
                        Text(
                          'quantity:${e.quantity.toString()}',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'price of ${e.quantity} is :${e.fakeStores.price * e.quantity}\$',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              );
            }).toList()),
            Text(
              'Your total price is ${total().toString()}\$',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
