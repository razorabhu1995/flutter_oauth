import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("WebAuth"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen()
              )
            );
          },
          child: Text("Login"),
        ),
      ),
    );
  }
}



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String token;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      print("onStateChanged: ${state.type} ${state.url}");
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("URL changed: ${url}");
      var uri = Uri.dataFromString(url); //converts string to a uri    
      Map<String, String> params = uri.queryParameters; // query parameters automatically populated
      var param = params['code']; // return value of parameter "param1" from uri
      print(jsonEncode(params));
      if (mounted) {
        setState(() {
          print("token $param");
          token = param;
          if(token != null){
            flutterWebviewPlugin.close();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()
                )
              );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = "https://b4b0580673ac.ngrok.io/oauth2/authorize?client_id=7e3637e8-723a-42d6-9d1d-5cb36128d6f1&response_type=code&redirect_uri=fusionauth.demo%3A%2Foauthredirect&fbclid=IwAR0QDEz-sDJQrJFMm7GzmB3iNelckfANvH1FoIR6HNwp0bxFhykDLFCxvzE";

    return new WebviewScaffold(
        url: loginUrl,
        appBar: new AppBar(
          title: new Text("Login to someservise..."),
        ));
  }
}
