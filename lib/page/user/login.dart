import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/user/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/src/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../animation/FadeAnimation.dart';
import '../home.dart';
import 'package:get_storage/get_storage.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _session = null;
  final box = GetStorage();

  Future loginUsingMetamask(BuildContext context) async {
    final Web3App web3app = await Web3App.createInstance(
      projectId: '..',
      metadata: const PairingMetadata(
        name: 'Flutter WalletConnect',
        description: 'Flutter WalletConnect Dapp Example',
        url: '..',
        icons: [
          '/assets/logo.png',
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
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text("Account verifed"),
                  content: Text("Would you like to log in?"),
                  actions: [
                    TextButton(
                      onPressed: () => {
                        setState(() {
                          _session = session;
                        }),
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => {
                        setState(() {
                          _session = session;
                        }),
                        Navigator.pop(context),
                      },
                      child: Text("Done"),
                    ),
                  ],
                ));
        /* setState(() {
            _session = session;
          });*/
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Account"),
            content: Text(
                "This is an unregistered account. Would you like to proceed with the integration?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignupPage()),
                ),
                child: Text("Done"),
              ),
              TextButton(
                onPressed: () => {
                  setState(() {
                    _session = null;
                  }),
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ),
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /* connector.on(
        'connect',
        (session) => setState(
              () {
                _session = _session;
              },
            ));
    connector.on(
        'session_update',
        (payload) => setState(() {
              _session = payload;
              print(_session.accounts[0]);
              print(_session.chainId);
            }));
    connector.on
        'disconnect',
        (payload) => setState(() {
              _session = null;
            }));*/

    return (_session == null)
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
            body: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            FadeAnimation(
                                1,
                                Text(
                                  "Log in",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            FadeAnimation(
                                1.2,
                                Text(
                                  "Start using the service through your wallet!",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[700]),
                                ))
                          ],
                        ),
                        /*Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: <Widget>[
                              FadeAnimation(1.2, makeInput(label: "아이디")),
                              FadeAnimation(1.3,
                                  makeInput(label: "비밀번호", obscureText: true)),
                            ],
                          ),
                        ),*/
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                          2.2,
                          Image.asset(
                            'assets/undraw_happy_feeling.png', // PNG 이미지 파일 경로
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                            1.4,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                padding: EdgeInsets.only(top: 3, left: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: const Border(
                                      bottom: BorderSide(color: Colors.black),
                                      top: BorderSide(color: Colors.black),
                                      left: BorderSide(color: Colors.black),
                                      right: BorderSide(color: Colors.black),
                                    )),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color.fromARGB(255, 255, 166, 1),
                                        Color.fromARGB(255, 255, 179, 0),
                                        Color.fromARGB(255, 255, 219, 151),
                                      ],
                                    ),
                                  ),
                                  child: MaterialButton(
                                    minWidth: double.infinity,
                                    height: 65,
                                    onPressed: () =>
                                        loginUsingMetamask(context),
                                    //{},
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Text(
                                      "Log in with MetaMask",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 73, 48, 0)),
                                    ),
                                  ),
                                ),
                              ),
                            )),

                        /*FadeAnimation(
                            1.4,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                padding: EdgeInsets.only(top: 3, left: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black),
                                      top: BorderSide(color: Colors.black),
                                      left: BorderSide(color: Colors.black),
                                      right: BorderSide(color: Colors.black),
                                    )),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height: 65,
                                  onPressed: () {},
                                  color: Color.fromARGB(255, 153, 218, 255),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            )),*/
                        FadeAnimation(
                            1.5,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Don't have an account?"),
                                InkWell(
                                  child: Text(
                                    " Sign up",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  onTap: () {
                                    /*  loginUsingMetamask(context);*/
                                  },
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  /* FadeAnimation(
                1.2,
                Container(
                  height: MediaQuery.of(context).size.height / 0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.cover)),
                ))*/
                ],
              ),
            ))
        : HomeScreen(
            walletaddress: box.read('wallet' ?? ''),
          );
  }

  Widget makeInput({label, obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(
          height: 5,
        ),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            //안에 입력 패딩
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!)),
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
