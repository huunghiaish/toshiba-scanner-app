import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

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
        await file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) => {productScanList.add(line)});
        return productScanList;
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<bool> importProductFile() async {
    final result = await FilePicker.platform
        .pickFiles(withReadStream: true, withData: true);

    // if no file is picked
    if (result == null) return false;

    // we get the file from result object
    final file = result.files.single;
    Uint8List? fileBytes = file.bytes;

    String fileContent = utf8.decode(fileBytes!);
    await writeProducts(fileContent);
    return true;
  }

  Future<String> getFilePathStorage() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/demoTextFile.txt';

    return filePath;
  }

  Future<bool> saveFileStorage(content, folderName, fileName) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage) &&
            await _requestPermission(Permission.accessMediaLocation) &&
            await _requestPermission(Permission.manageExternalStorage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath = "$newPath/Toshiba_SPA_Files/$folderName";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File file = File("${directory.path}/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await file.writeAsString(content);
        return true;
      }
    } catch (err) {
      print('error: $err');
      return false;
    }
    return true;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}
