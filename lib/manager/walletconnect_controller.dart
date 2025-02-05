import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'firebase_controller.dart';

class WalletConnect {
  static Future<bool> loginUsingMetamask(BuildContext context) async {
    final Web3App web3app = await Web3App.createInstance(
      projectId: '79d88517a3032f1cb467d5d642758156',
      metadata: const PairingMetadata(
        name: 'Flutter WalletConnect',
        description: 'Flutter WalletConnect Dapp Example',
        url: 'https://walletconnect.com/',
        icons: [
          'https://walletconnect.com/walletconnect-logo.png',
        ],
      ),
    );

    final ConnectResponse response = await web3app.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: [
            'eip155:1',
          ],
          methods: [
            'personal_sign',
            'eth_sign',
            'eth_signTransaction',
            'eth_signTypedData',
            'eth_sendTransaction',
          ],
          events: [
            'chainChanged',
            'accountsChanged',
          ],
        ),
      },
    );
    bool login = false;
    final Uri? uri = response.uri;
    if (uri != null) {
      final String encodedUri = Uri.encodeComponent('$uri');

      await launchUrlString(
        'metamask://wc?uri=$encodedUri',
        mode: LaunchMode.externalApplication,
      );

      SessionData session = await response.session.future;

      final String account = NamespaceUtils.getAccount(
        session!.namespaces.values.first.accounts[0],
      );
      print(account);
      MyFire.box.write('wallet', account);
      final doc = FirebaseFirestore.instance.collection('Users').doc(account);
      final result = await doc.get();
      if (result.exists) {
        //String userURL = await MyFire.getUserImage(session.account[0]);
        //box.write('userImg', userURL);
      }

      login = result.exists;
    }
    return login;
  }
}
