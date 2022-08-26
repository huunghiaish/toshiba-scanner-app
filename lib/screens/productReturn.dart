// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:scanner_product_app/handleFile.dart';

class ProductReturnScreen extends StatefulWidget {
  const ProductReturnScreen({Key? key, required this.handleFile})
      : super(key: key);

  final HandleFile handleFile;

  @override
  State<ProductReturnScreen> createState() => _MyProductReturnScreenState();
}

class _MyProductReturnScreenState extends State<ProductReturnScreen> {
  final _fromKey = GlobalKey<FormState>();
  late List<String> _productReturnList = [];
  late String barcode = '';
  late int index = 0;

  var textSerialController = TextEditingController();
  FocusNode textSerialNode = FocusNode();
  @override
  void initState() {
    super.initState();
    setState(() {
      _productReturnList = [];
    });

    widget.handleFile.readProductReturns().then((value) => {
          if (value.isNotEmpty)
            {
              setState(() {
                _productReturnList = value;
              })
            }
        });
  }

  void reloadState() {
    setState(() => {_productReturnList = []});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product return (${_productReturnList.length})'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            // you could add any widget
            child: ListTile(
              title: Row(
                children: const <Widget>[
                  SizedBox(width: 30, child: Center(child: Text("No."))),
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
                                      child: Text((index + 1).toString()),
                                    ))),
                                Expanded(
                                    child: Center(
                                        child:
                                            Text(_productReturnList[index]))),
                                SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Delete',
                                        onPressed: () async {
                                          _productReturnList.removeWhere(
                                              (item) =>
                                                  item ==
                                                  _productReturnList[index]);

                                          String contentProductReturn = '';
                                          for (var item in _productReturnList) {
                                            contentProductReturn =
                                                '$contentProductReturn$item\n';
                                          }
                                          await widget.handleFile
                                              .writeProductReturns(
                                                  contentProductReturn);
                                          reloadState(
                                              () => {_productReturnList});
                                        },
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _productReturnList.length,
                    ),
                  )),
        ],
      ),
    );
  }
}
