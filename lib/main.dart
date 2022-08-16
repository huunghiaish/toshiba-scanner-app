import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';

// Defined Type
class Product {
  late final String? _barcode;
  late final String? _model;
  late final String? _serial;
  Product(this._barcode, this._model, this._serial);
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
  final _listMode = ['Single', 'Multiple'];
  String _type = 'Transfer';
  String _mode = 'Single';

  List<String> _productList = [
    // '8858730365089,GR-A13VT(H)',
    // '8858730365096,GR-A13VPT(SX)',
    // '8858730365102,GR-A13VPT(LB)',
    // '8858730365119,GR-A13VPT(BX)',
    // '8858730365256,GR-W21VPB(C)',
    // '8858730365263,GR-W21VPB(DS)',
    // '8858730365249,GR-W21VPB(S)',
    // '8858730365294,GR-W21VUB(BS)',
    // '8858730365300,GR-W21VUB(TS)'
  ];
  late List<Product> _productScanList = [];

  late String? _destination = '';
  late String? _invoice = '';
  late String? _truckID = '';

  late String? _barcode = '';
  late String? _model = '';
  late String? _serial = '';

  // Form
  var textDestinationController = TextEditingController();
  var textInvoiceController = TextEditingController();
  var textTruckIDController = TextEditingController();

  var textBarcodeController = TextEditingController();
  var textModelController = TextEditingController();
  var textSerialController = TextEditingController();

  FocusNode textBarcodeNode = FocusNode();
  FocusNode textSerialNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // widget.handleFile.readProducts().then((value) => {
    //       // print('init: $value'),
    //       if (mounted)
    //         {
    //           setState(() => {_productList = value}),
    //         },
    //     });
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
                  controller: textDestinationController,
                  decoration: const InputDecoration(labelText: "Destination"),
                  onChanged: (value) => {
                        setState(() {
                          _destination = value.trim();
                        })
                      }),
              TextFormField(
                  controller: textInvoiceController,
                  decoration: const InputDecoration(labelText: "Invoice"),
                  onChanged: (value) => {
                        setState(() {
                          _invoice = value.trim();
                        })
                      }),
              TextFormField(
                  controller: textTruckIDController,
                  decoration: const InputDecoration(labelText: "Truck ID"),
                  onChanged: (value) => {
                        setState(() {
                          _truckID = value.trim();
                        })
                      }),
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
                  controller: textBarcodeController,
                  decoration: const InputDecoration(labelText: "Barcode"),
                  focusNode: textBarcodeNode,
                  onEditingComplete: () {
                    int index = _productList.indexWhere(
                        (element) => element.contains('$_barcode,'));
                    if (index < 0) {
                      // notification
                    } else {
                      String model = _productList[index].split(',')[1];
                      setState(() {
                        _model = model.trim();
                      });

                      textModelController.text = model;
                      FocusScope.of(context).requestFocus(textSerialNode);
                    }
                  },
                  onChanged: (value) => {
                        setState(() {
                          _barcode = value.trim();
                        })
                      }),
              TextField(
                controller: textModelController,
                enabled: false,
                decoration: const InputDecoration(labelText: "Model"),
              ),
              TextFormField(
                controller: textSerialController,
                decoration: const InputDecoration(labelText: "Serial"),
                focusNode: textSerialNode,
                onFieldSubmitted: (String value) {
                  setState(() {
                    _serial = value.trim();
                  });
                  if (_barcode != '' && _model != '' && _serial != '') {
                    // save list product scan
                    setState(() {
                      _productScanList.add(Product(_barcode, _model, _serial));
                    });
                    if (_mode == 'Single') {
                      textBarcodeController.clear();
                      textModelController.clear();
                      textSerialController.clear();
                      setState(() {
                        _barcode = '';
                        _model = '';
                        _serial = '';
                      });
                      FocusScope.of(context).requestFocus(textBarcodeNode);
                    } else {
                      // Multiple
                      textSerialController.clear();
                      setState(() {
                        _serial = '';
                      });
                      FocusScope.of(context).requestFocus(textSerialNode);
                    }
                  } else {
                    if (_serial == '') {
                      FocusScope.of(context).requestFocus(textSerialNode);
                    } else {
                      FocusScope.of(context).requestFocus(textBarcodeNode);
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Reset',
                onPressed: () {
                  setState(() {
                    _type = 'Transfer';
                    _mode = 'Single';
                    _destination = '';
                    _invoice = '';
                    _truckID = '';
                    _barcode = '';
                    _model = '';
                    _serial = '';
                    _productScanList = [];
                  });
                  textDestinationController.clear();
                  textInvoiceController.clear();
                  textTruckIDController.clear();
                  textBarcodeController.clear();
                  textModelController.clear();
                  textSerialController.clear();
                },
              ),
              // 8858730365089
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var item in _productScanList)
                    Text((' - Model: ${item._model}, Serial: ${item._serial}'))
                ],
              ),
            ])),
      );

  _scanForm() => Container();
}
