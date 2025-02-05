import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class metaNextscreenui extends StatelessWidget {
  final String walletaddress;
  const metaNextscreenui({Key? key, required this.walletaddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Wallet address is'),
          Text(walletaddress),
        ],
      ),
    );
  }
}
