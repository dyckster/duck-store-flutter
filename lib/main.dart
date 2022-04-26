import 'package:duck_store/mapper/DuckUiModelMapper.dart';
import 'package:duck_store/models/DuckDTO.dart';
import 'package:duck_store/models/DuckUiModel.dart';
import 'package:duck_store/usecase/GetRandomDuckUseCase.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Duck Shop'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<DuckDTO> futureDuck;
  DuckUiModel duckUiModel = DuckUiModel.empty();
  bool isLoadingANewDuck = false;
  bool isFlyingAway = false;
  late Widget _image;
  Offset offset = const Offset(0, 0);

  @override
  void initState() {
    ShakeDetector.autoStart(onPhoneShake: () {
      setState(() {
        offset = const Offset(0, 500);
        isFlyingAway = true;
      });
    });
    super.initState();
  }

  void _getRandomDuck() {
    setState(() {
      futureDuck = GetRandomDuckUseCase().fetchDuck();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMerchantState = duckUiModel == DuckUiModel.empty();

    _image = imageWidgetPositioned(duckUiModel.url, isMerchantState);

    String dialogText = "Quack. I am a debug text";
    if (isFlyingAway) {
      dialogText = "Oh no! You scared the cute duck.\nIt's flying away!";
    } else if (duckUiModel.isRare) {
      dialogText = "Wow! A rare duck. Nice.";
    } else if (isMerchantState) {
      dialogText =
          "Welcome, traveler.\n\nPlease, take a look at my duck collection...";
    } else if (isLoadingANewDuck) {
      dialogText = "Searching for a compatible duck....";
    } else {
      dialogText = ([
        "Behold, a duck!",
        "Here's a duck",
        "Behold, another duck",
        "Quack quack, here's a duck",
        "Do you mind holding this duck",
        "Huh. Can't find the rare one?"
      ]..shuffle())
          .first;
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/shop_background.png"),
                      fit: BoxFit.cover))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 102, 16, 32),
            child: Center(
                child: Column(
              children: [
                Stack(
                  children: [
                    Visibility(
                      child: _image,
                      visible: true,
                    ),
                    Visibility(
                      child: Image.asset("assets/rare_gradient.png",
                          width: 256, height: 256, fit: BoxFit.fill),
                      visible: duckUiModel.isRare && !isLoadingANewDuck,
                    ),
                    Visibility(
                        child: Image.asset('assets/frame.png'),
                        visible: !isMerchantState)
                  ],
                ),
                Container(
                  constraints:
                      const BoxConstraints(minHeight: 200, maxHeight: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Text(dialogText,
                        style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            color: Colors.white,
                            fontSize: 20)),
                  ),
                ),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        textStyle: const TextStyle(
                            fontFamily: 'PressStart2P',
                            color: Colors.white,
                            fontSize: 16),
                        primary: Colors.white,
                        side: const BorderSide(
                            color: Colors.orangeAccent, width: 8),
                        backgroundColor: Colors.deepOrange),
                    onPressed: isLoadingANewDuck
                        ? null
                        : () {
                            setState(() {
                              isFlyingAway = false;
                              isLoadingANewDuck = true;
                            });
                            _getRandomDuck();
                            futureDuck.then((value) => {
                                  setState(() {
                                    offset = const Offset(0, 0);
                                    isLoadingANewDuck = false;
                                    duckUiModel =
                                        DuckUiModelMapper().map(value);
                                  })
                                });
                          },
                    child: Text("Show me the duck!".toUpperCase()))
              ],
            )),
          )
        ],
      ),
    );
  }

  Widget imageWidgetPositioned(String url, bool isMerchantState) {
    Duration duration;
    if (isFlyingAway) {
      duration = const Duration(milliseconds: 5000);
    } else {
      duration = const Duration(milliseconds: 1000);
    }
    Widget image = imageWidget(url, isMerchantState);
    if (isMerchantState) {
      return image;
    } else {
      return AnimatedPositioned(
          duration: duration, top: offset.dy, left: offset.dx, child: image);
    }
  }

  Widget imageWidget(String url, bool isMerchantState) {
    return Image.network(url, loadingBuilder:
        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null || isMerchantState) {
        return child;
      }
      return Container(
        width: 256,
        height: 256,
        color: Colors.white,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    }, width: 256, height: 256, fit: BoxFit.fill);
  }
}
