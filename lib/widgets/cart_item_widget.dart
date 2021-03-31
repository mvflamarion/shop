import 'package:flutter/material.dart';
import 'package:shop/providers/cart.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  CartItemWidget(this.cartItem);
  @override
  Widget build(BuildContext context) {
    var subTotal = cartItem.price * cartItem.quantity;
    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 35,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => Provider.of<Cart>(context, listen: false)
          .removeItem(cartItem.productId),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('${cartItem.price.toStringAsFixed(2)}'),
                ),
              ),
            ),
            title: Text(cartItem.title),
            subtitle: Text('Total: R\$ ${subTotal.toStringAsFixed(2)}'),
            trailing: Text('${cartItem.quantity}x'),
          ),
        ),
      ),
    );
  }
}
