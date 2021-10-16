import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/orders.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({Key? key, required this.orderItem}) : super(key: key);
  final OrderItems orderItem;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded
          ? min(widget.orderItem.products.length * 20.0 + 110, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: ListTile(
                title: Text('\$${widget.orderItem.price}'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm')
                      .format(widget.orderItem.dateTime),
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon:
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              height: _isExpanded
                  ? min(
                      widget.orderItem.products.length * 20.0 + 10,
                      100,
                    )
                  : 0,
              child: ListView.builder(
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.orderItem.products[index].title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.orderItem.products[index].quantity}x \$${widget.orderItem.products[index].price}',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                itemCount: widget.orderItem.products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
