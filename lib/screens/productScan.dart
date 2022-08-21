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

  @override
  void initState() {
    super.initState();
    widget.handleFile.readProductScans().then((value) => setState(() {
          _productScanList = value;
        }));
  }

  void removeProduct() {
    setState(() => {_productScanList = []});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product scan'),
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
              builder: (innerContext, removeProduct) => SliverList(
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
                                        (index + 1).toString(),
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
                                        onPressed: () {
                                          removeProduct(() => {
                                                _productScanList.removeWhere(
                                                    (item) =>
                                                        item ==
                                                        _productScanList[index])
                                              });
                                          String contentProductScan = '';
                                          for (var item in _productScanList) {
                                            contentProductScan =
                                                '$contentProductScan$item\n';
                                          }
                                          widget.handleFile.writeProductScans(
                                              contentProductScan);
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
