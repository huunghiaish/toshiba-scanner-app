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

  Future<File> get _localFileProductScan async {
    final path = await _localPath;
    return File('$path/productScans.txt');
  }

  Future<File> writeProductScans(String productList) async {
    final file = await _localFileProductScan;

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
      return [];
    }
    return [];
  }

  Future<List<String>> readProductScans() async {
    try {
      List<String> productScanList = [];
      if (kIsWeb) {
        print("read file web");
        return [
          '8858730365089,GR-A12VT(H),123',
          '8858730365089,GR-A13VT(H),456',
          '8858730365089,GR-A14VT(H),789',
        ];
      } else {
        print("read file mobile");
        final file = await _localFileProductScan;

        // Read the file
        // final contents = await file.readAsString();
        // handle file
        await file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) => {productScanList.add(line)});
        // list product return
        return productScanList;
      }
    } catch (e) {
      // If encountering an error, return 0
      print(e);
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
