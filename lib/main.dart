import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';

// Defined Type
class Product {
  late String? barcode;
  late String? model;
  late String? serial;
}

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: Scaffold(
          body:
              MyHomePage(title: 'Toshiba logistics', handleFile: HandleFile())),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.handleFile})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final HandleFile handleFile;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _fromKey = GlobalKey<FormState>();

  final _listType = ['Transfer', 'Sales'];
  final _listMode = ['Single', 'Multi'];
  String _type = 'Transfer';
  String _mode = 'Single';

  List<String> _productList = [];
  final List<Product> _productScanList = [];

  // late Product? _productScan;

  late String? barcode;
  late String? model;
  late String? serial;

  @override
  void initState() {
    super.initState();
    widget.handleFile.readProducts().then((value) => {
          // print('init: $value'),
          if (mounted)
            {
              setState(() => {_productList = value}),
            },
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Center(
        child: Text(widget.title),
      )),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_mainForm(), _scanForm()],
        ),
      ),
    );
  }

  _mainForm() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
            key: _fromKey,
            child: Column(children: <Widget>[
              Row(
                children: [
                  Flexible(
                      flex: 1,
                      child: Text(
                        'List Product: ${_productList.length}',
                        style: TextStyle(
                            color: _productList.isEmpty
                                ? Colors.red
                                : Colors.green,
                            fontSize: 16),
                      )),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.upload_file_outlined),
                      tooltip: 'Upload products',
                      onPressed: () {
                        widget.handleFile.pickFile().then((value) => {
                              if (value == true) {print("Import thanh cong")},
                              widget.handleFile.readProducts().then((value) => {
                                    print(value),
                                    {
                                      setState(() => {_productList = value}),
                                    },
                                  })
                            });
                      },
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Type"),
                value: _type,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _listType.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _type = newValue!;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Destination"),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Invoice"),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Truck ID"),
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Mode"),
                value: _mode,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _listMode.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _mode = newValue!;
                  });
                },
              ),
              TextFormField(
                  decoration: const InputDecoration(labelText: "Barcode"),
                  onEditingComplete: () {
                    int index = _productList
                        .indexWhere((element) => element.contains('$barcode,'));
                    if (index < 0) {
                      // notification
                    }
                    String model = _productList[index].split(',')[1];
                    setState(() {
                      model = model;
                    });
                  },
                  onChanged: (value) => {
                        setState(() {
                          barcode = value.trim();
                        })
                      }),
              // TextField(
              //   controller: TextEditingController(text: model ?? ''),
              // ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Serial"),
              ),
              IconButton(
                icon: const Icon(Icons.upload_file_outlined),
                tooltip: 'Upload products',
                onPressed: () {
                  print('_productScan : $barcode');
                },
              ),
            ])),
      );

  _scanForm() => Container();
}
