import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/auth.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Hello World!'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            title: Text('Shop'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            onTap: () {
              Navigator.pushReplacementNamed(context, OrderScreen.routeName);
            },
            title: Text('Orders'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            onTap: () {
              Navigator.pushReplacementNamed(context, UserProducts.routeName);
            },
            title: Text('Manage Products'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
