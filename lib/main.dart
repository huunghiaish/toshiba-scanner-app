import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:scanner_product_app/screens/productScan.dart';
import 'package:intl/intl.dart';

// Defined Type
class Product {
  late final String? _barcode;
  late final String? _model;
  late final String? _serial;
  Product(this._barcode, this._model, this._serial);
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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

  late List<String> _productList = [];

  late List<Product> _productScanList = [];
  late final List<String> _productSerialReturn = [];

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

  FocusNode textDestinationNode = FocusNode();
  FocusNode textInvoiceNode = FocusNode();
  FocusNode textTruckIDNode = FocusNode();
  FocusNode dropdownModeNode = FocusNode();
  FocusNode textBarcodeNode = FocusNode();
  FocusNode textSerialNode = FocusNode();

  // Function
  String getContentExportProduct() {
    String result = '';
    for (var item in _productScanList) {
      result =
          '$result$_type,$_destination,$_invoice,$_truckID,${item._model},${item._serial}\n';
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    widget.handleFile.readProducts().then((value) => {
          if (mounted)
            {
              setState(() => {_productList = value}),
            },
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: Text(widget.title),
      )),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_mainForm(), _scanForm()],
        ),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        ProductScanScreen(handleFile: HandleFile())),
              );
            }),
        const Spacer(),
        const Spacer(),
        IconButton(
            icon: const Icon(Icons.clear_all_outlined),
            onPressed: () async {
              // set up the buttons
              Widget cancelButton = TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  setState(() => {
                        _type = 'Transfer',
                        _mode = 'Single',
                        _destination = '',
                        _invoice = '',
                        _truckID = '',
                        _barcode = '',
                        _model = '',
                        _serial = '',
                        _productScanList = []
                      });
                  widget.handleFile.writeProductScans('');
                  textDestinationController.clear();
                  textInvoiceController.clear();
                  textTruckIDController.clear();
                  textBarcodeController.clear();
                  textModelController.clear();
                  textSerialController.clear();
                  Navigator.pop(context);
                },
              );

              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: const Text("Confirm clear data!"),
                content: const Text(
                    "Do you want to delete all scanned product data?"),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );

              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            }),
        const Spacer(),
        const Spacer(),
        IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              // set up the buttons
              Widget cancelButton = TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = TextButton(
                child: const Text("Download"),
                onPressed: () async {
                  // get product scan
                  setState(() {
                    _productScanList = [];
                  });
                  await widget.handleFile.readProductScans().then((value) => {
                        if (value.isNotEmpty)
                          {
                            for (var item in value)
                              {
                                setState(() {
                                  _productScanList.add(Product(
                                      item.split(',')[0],
                                      item.split(',')[1],
                                      item.split(',')[2]));
                                })
                              }
                          }
                      });
                  // validate
                  if (_productScanList.isEmpty) {
                    var snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error: PS404',
                        message: 'Product scan list empty!',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (_destination == '' ||
                      _invoice == '' ||
                      _truckID == '') {
                    var snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error: FV404',
                        message:
                            'Required value:${_destination == '' ? ' Destination,' : ''}${_invoice == '' ? ' Invoice,' : ''}${_truckID == '' ? ' Truck ID.' : ''}',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  //
                  else {
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(DateTime.now());
                    String contentExport = getContentExportProduct();
                    bool result = await widget.handleFile.saveFileStorage(
                        contentExport,
                        formattedDate,
                        '$formattedDate-$_truckID.txt');
                    if (result == true) {
                      var snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Success',
                          message: 'Export product scan success!',
                          contentType: ContentType.success,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      var snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Error: EP400',
                          message:
                              'Export ${_productScanList.length} product scan failed!',
                          contentType: ContentType.failure,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                  Navigator.pop(context);
                },
              );

              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: const Text("Confirm download!"),
                content: const Text("Do you want to download?"),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            }),
      ],
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
                        var snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Success',
                            message: 'Import product list success!',
                            contentType: ContentType.success,
                          ),
                        );
                        widget.handleFile.importProductFile().then((value) => {
                              if (value == true)
                                {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar)
                                },
                              widget.handleFile.readProducts().then((value) => {
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
                  FocusScope.of(context).requestFocus(textDestinationNode);
                },
              ),
              TextFormField(
                  controller: textDestinationController,
                  decoration: InputDecoration(
                      labelText: "Destination",
                      suffixIcon: IconButton(
                        onPressed: () {
                          textDestinationController.clear();
                          setState(() => {_destination = ''});
                        },
                        icon: const Icon(Icons.clear),
                      )),
                  focusNode: textDestinationNode,
                  onFieldSubmitted: (String value) {
                    setState(() {
                      _destination = value.trim();
                    });
                    FocusScope.of(context).requestFocus(textInvoiceNode);
                  }),
              TextFormField(
                  controller: textInvoiceController,
                  decoration: InputDecoration(
                      labelText: "Invoice",
                      suffixIcon: IconButton(
                        onPressed: () {
                          textInvoiceController.clear();
                          setState(() => {_invoice = ''});
                        },
                        icon: const Icon(Icons.clear),
                      )),
                  focusNode: textInvoiceNode,
                  onFieldSubmitted: (String value) {
                    setState(() => {_invoice = value.trim()});
                    FocusScope.of(context).requestFocus(textTruckIDNode);
                  }),
              TextFormField(
                  controller: textTruckIDController,
                  decoration: InputDecoration(
                      labelText: "Truck ID",
                      suffixIcon: IconButton(
                        onPressed: () {
                          textTruckIDController.clear();
                          setState(() => {_truckID = ''});
                        },
                        icon: const Icon(Icons.clear),
                      )),
                  focusNode: textTruckIDNode,
                  onFieldSubmitted: (String value) {
                    setState(() {
                      _truckID = value.trim();
                    });
                    // FocusScope.of(context).requestFocus(dropdownModeNode);
                  }),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Mode"),
                value: _mode,
                focusNode: dropdownModeNode,
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
                  FocusScope.of(context).requestFocus(textBarcodeNode);
                },
              ),
              TextFormField(
                  controller: textBarcodeController,
                  decoration: InputDecoration(
                      labelText: "Barcode",
                      suffixIcon: IconButton(
                        onPressed: () {
                          textBarcodeController.clear();
                          textModelController.clear();
                          setState(() => {_barcode = '', _model = ''});
                        },
                        icon: const Icon(Icons.clear),
                      )),
                  focusNode: textBarcodeNode,
                  onEditingComplete: () {
                    int index = _productList.indexWhere(
                        (element) => element.split(',')[0] == _barcode);
                    if (index < 0) {
                      // notification
                      var snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Error: BC404',
                          message:
                              'The barcode of this product does not exist in the list of imported products',
                          contentType: ContentType.failure,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      FocusScope.of(context).requestFocus(textBarcodeNode);
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
                decoration: InputDecoration(
                    labelText: "Serial",
                    suffixIcon: IconButton(
                      onPressed: () {
                        textSerialController.clear();
                        setState(() => {_serial = ''});
                      },
                      icon: const Icon(Icons.clear),
                    )),
                focusNode: textSerialNode,
                onFieldSubmitted: (String value) {
                  var contain = _productScanList
                      .where((element) => element._serial == value);
                  if (contain.isEmpty) {
                    setState(() {
                      _serial = value.trim();
                    });
                    if (_barcode != '' && _model != '' && _serial != '') {
                      // save list product scan
                      setState(() {
                        _productScanList
                            .add(Product(_barcode, _model, _serial));
                      });
                      String contentProductScan = '';
                      for (var item in _productScanList) {
                        contentProductScan =
                            '$contentProductScan${item._barcode},${item._model},${item._serial}\n';
                      }
                      widget.handleFile.writeProductScans(contentProductScan);
                      if (_mode == 'Single') {
                        textBarcodeController.clear();
                        textModelController.clear();
                        textSerialController.clear();
                        setState(() => {
                              _barcode = '',
                              _model = '',
                              _serial = '',
                            });
                        FocusScope.of(context).requestFocus(textBarcodeNode);
                      } else {
                        // Multiple
                        textSerialController.clear();
                        setState(() => {_serial = ''});
                        FocusScope.of(context).requestFocus(textSerialNode);
                      }
                    } else {
                      if (_serial == '') {
                        FocusScope.of(context).requestFocus(textSerialNode);
                      } else {
                        FocusScope.of(context).requestFocus(textBarcodeNode);
                      }
                    }
                  } else {
                    // notification existed serial
                    var snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error: SE409',
                        message:
                            'The serial code of this product has been scanned!',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    FocusScope.of(context).requestFocus(textSerialNode);
                  }
                },
              ),
            ])),
      );

  _scanForm() => Container();
}
