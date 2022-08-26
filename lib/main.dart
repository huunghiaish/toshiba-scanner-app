// ignore_for_file: use_build_context_synchronously

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:scanner_product_app/screens/productReturn.dart';
import 'package:scanner_product_app/screens/productScan.dart';
import 'package:intl/intl.dart';

// Defined Type
class Product {
  late final String? _barcode;
  late final String? _model;
  late final String? _serial;
  Product(this._barcode, this._model, this._serial);
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(const Duration(seconds: 1));
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
      title: 'Scanner product app',
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
  var textSerialReturnController = TextEditingController();

  FocusNode textDestinationNode = FocusNode();
  FocusNode textInvoiceNode = FocusNode();
  FocusNode textTruckIDNode = FocusNode();
  FocusNode dropdownModeNode = FocusNode();
  FocusNode textBarcodeNode = FocusNode();
  FocusNode textSerialNode = FocusNode();
  FocusNode textSerialReturnNode = FocusNode();

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
          children: <Widget>[_mainForm()],
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
        IconButton(
            icon: const Icon(Icons.assignment_return_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        ProductReturnScreen(handleFile: HandleFile())),
              );
            }),
        IconButton(
            icon: const Icon(Icons.clear_all_outlined),
            onPressed: () async {
              // set up the buttons
              Widget cancelButton = TextButton(
                child: const Text("Trở lại"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = TextButton(
                child: const Text("Đồng ý"),
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
                title: const Text("Xác nhận xoá dữ liệu!"),
                content: const Text(
                    "Bạn có muốn xóa tất cả dữ liệu sản phẩm đã quét không?"),
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
        IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              // set up the buttons
              Widget cancelButton = TextButton(
                child: const Text("Trở lại"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = TextButton(
                child: const Text("Tải xuống"),
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
                        title: 'Lỗi: PS404',
                        message: 'Danh sách Sản phẩm được quét trống!',
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
                        title: 'Lỗi: FV404',
                        message:
                            'Chưa nhập:${_destination == '' ? ' Destination,' : ''}${_invoice == '' ? ' Invoice,' : ''}${_truckID == '' ? ' Truck ID.' : ''}',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(DateTime.now());
                    String formattedDateHour =
                        DateFormat('dd-MM-yyyy--HH-mm-ss')
                            .format(DateTime.now());
                    String contentExport = getContentExportProduct();
                    String result = await widget.handleFile.saveFileStorage(
                        contentExport,
                        formattedDate,
                        '$_truckID--$formattedDateHour.txt');
                    if (result == "true") {
                      var snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Success',
                          message:
                              'Xuất ${_productScanList.length} sản phẩm đã quét thành công!',
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
                          title: 'Lỗi: EP400',
                          message: result,
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
                title: const Text("Xác nhận tải xuống!"),
                content: const Text("Bạn có muốn tải xuống?"),
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
                            title: 'Thành công',
                            message: 'Nhập danh sách sản phẩm thành công!',
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
                },
                onChanged: (String value) {
                  setState(() {
                    _destination = value;
                  });
                },
              ),
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
                },
                onChanged: (String value) {
                  setState(() {
                    _invoice = value;
                  });
                },
              ),
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
                },
                onChanged: (String value) {
                  setState(() {
                    _truckID = value;
                  });
                },
              ),
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
                          title: 'Lỗi: BC404',
                          message:
                              'Mã vạch của sản phẩm này không tồn tại trong danh mục sản phẩm đã nhập',
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
                onFieldSubmitted: (String value) async {
                  // check serial return
                  var productReturnList = [];
                  await widget.handleFile.readProductReturns().then((value) => {
                        if (value.isNotEmpty) {productReturnList = value}
                      });
                  var existedSerialReturn =
                      productReturnList.where((element) => element == value);
                  if (existedSerialReturn.isNotEmpty) {
                    var snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Lỗi: SR409',
                        message: 'Mã sê-ri này là một sản phẩm trả lại!',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                  // load current list from file
                  await widget.handleFile.readProductScans().then((value) => {
                        if (value.isNotEmpty)
                          {
                            setState(() {
                              _productScanList = [];
                            }),
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
                      _productScanList
                          .sort((a, b) => a._barcode!.compareTo(b._barcode!));
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
                        title: 'Lỗi: SE409',
                        message: 'Mã sê-ri của sản phẩm này đã được quét!',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    FocusScope.of(context).requestFocus(textSerialNode);
                  }
                },
              ),
              TextFormField(
                controller: textSerialReturnController,
                decoration: InputDecoration(
                    labelText: "Return Product Serial",
                    suffixIcon: IconButton(
                      onPressed: () async {
                        textSerialReturnController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )),
                focusNode: textSerialReturnNode,
                onFieldSubmitted: (String value) async {
                  var productReturnList = [];
                  await widget.handleFile.readProductReturns().then((value) => {
                        if (value.isNotEmpty) {productReturnList = value}
                      });
                  productReturnList.add(value);
                  String contentProductReturn = '';
                  for (var item in productReturnList) {
                    contentProductReturn = '$contentProductReturn$item\n';
                  }
                  await widget.handleFile
                      .writeProductReturns(contentProductReturn);
                  textSerialReturnController.clear();
                },
              ),
            ])),
      );
}
