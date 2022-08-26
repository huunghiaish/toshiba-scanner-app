// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';

class ProductScanScreen extends StatefulWidget {
  const ProductScanScreen({Key? key, required this.handleFile})
      : super(key: key);

  final HandleFile handleFile;

  @override
  State<ProductScanScreen> createState() => _MyProductScanScreenState();
}

class _MyProductScanScreenState extends State<ProductScanScreen> {
  late List<String> _productScanList = [];
  late String barcode = '';
  late int index = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      _productScanList = [];
    });

    widget.handleFile.readProductScans().then((value) => {
          for (var item in value)
            {
              if (index == 0)
                {
                  setState(() {
                    index = index + 1;
                  }),
                }
              else
                {
                  if (barcode == item.split(',')[0])
                    {
                      setState(() {
                        index = index + 1;
                      }),
                    }
                  else
                    {
                      setState(() {
                        index = 1;
                      }),
                    }
                },
              setState(() {
                barcode = item.split(',')[0];
              }),
              setState(() {
                _productScanList.add('$item,$index');
              })
            },
        });
  }

  void reloadState() {
    setState(() => {_productScanList = []});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product scan (${_productScanList.length})'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            // you could add any widget
            child: ListTile(
              title: Row(
                children: const <Widget>[
                  SizedBox(width: 30, child: Center(child: Text("No."))),
                  Expanded(child: Center(child: Text("Model"))),
                  Expanded(child: Center(child: Text("Serial"))),
                  SizedBox(width: 40, child: Center(child: Text("AT"))),
                ],
              ),
            ),
          ),
          StatefulBuilder(
              builder: (innerContext, reloadState) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return InkWell(
                          child: ListTile(
                            title: Row(
                              children: <Widget>[
                                SizedBox(
                                    width: 30,
                                    child: Center(
                                        child: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 10,
                                      child: Text(
                                        (_productScanList[index].split(',')[3])
                                            .toString(),
                                      ),
                                    ))),
                                Expanded(
                                    child: Center(
                                        child: Text(_productScanList[index]
                                            .split(',')[1]))),
                                Expanded(
                                    child: Center(
                                        child: Text(_productScanList[index]
                                            .split(',')[2]))),
                                SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Delete',
                                        onPressed: () async {
                                          _productScanList.removeWhere((item) =>
                                              item == _productScanList[index]);

                                          String contentProductScan = '';
                                          for (var item in _productScanList) {
                                            contentProductScan =
                                                '$contentProductScan${item.split(',')[0]},${item.split(',')[1]},${item.split(',')[2]}\n';
                                          }
                                          await widget.handleFile
                                              .writeProductScans(
                                                  contentProductScan);
                                          reloadState(() => {_productScanList});
                                        },
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _productScanList.length,
                    ),
                  )),
        ],
      ),
    );
  }
}
