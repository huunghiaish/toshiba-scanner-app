import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class HandleFile {
  // VARIABLE
  static final _scaffoldKey = GlobalKey<ScaffoldState>();

  // OVERRIDE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
    );
  }

  // FUNCTION
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFileProduct async {
    final path = await _localPath;
    return File('$path/products.txt');
  }

  Future<File> writeProducts(String productList) async {
    final file = await _localFileProduct;

    // Write the file
    return file.writeAsString(productList);
  }

  Future<List<String>> readProducts() async {
    try {
      List<String> productList = [];
      if (kIsWeb) {
        print("read file web");
      } else {
        print("read file mobile");
        final file = await _localFileProduct;

        // Read the file
        // final contents = await file.readAsString();
        // handle file
        await file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) => {productList.add(line)});
        // list product return
        return productList;
      }
    } catch (e) {
      // If encountering an error, return 0
      print(e);
      _scaffoldKey.currentState
          ?.showSnackBar(const SnackBar(content: Text('NOT PRODUCTS!')));
      return [];
    }
    return [];
  }

  Future<bool> pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform
        .pickFiles(withReadStream: true, withData: true);

    // if no file is picked
    if (result == null) return false;

    // we get the file from result object
    final file = result.files.single;
    Uint8List? fileBytes = file.bytes;

    String fileContent = utf8.decode(fileBytes!);
    await writeProducts(fileContent);
    // List<String> lines = fileContent.split('\n');
    return true;
  }
}
