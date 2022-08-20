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
  late List<String> _productScanList = [
    // '1858730365089,GR-A13VT(H),1',
    // '2858730365096,GR-A13VPT(SX),2',
    // '3858730365102,GR-A13VPT(LB),3',
    // '4858730365089,GR-A13VT(H),4',
    // '4858730365096,GR-A13VPT(SX),5',
    // '6858730365102,GR-A13VPT(LB),6',
    // '7858730365089,GR-A13VT(H),7',
    // '8858730365096,GR-A13VPT(SX),8',
    // '9858730365102,GR-A13VPT(LB),9',
    // '1058730365089,GR-A13VT(H),10',
    // '1158730365096,GR-A13VPT(SX),11',
    // '1258730365102,GR-A13VPT(LB),12',
    // '1358730365089,GR-A13VT(H),13',
    // '1458730365096,GR-A13VPT(SX),14',
    // '1558730365102,GR-A13VPT(LB),15',
  ];

  @override
  void initState() {
    super.initState();
    // widget.handleFile.readProductScans().then((value) => setState(() {
    //       _productScanList = value;
    //     }));
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
      // body: Center(
      //   child: ElevatedButton(
      //     onPressed: () {
      //       // Navigate back to first route when tapped.
      //     },
      //     child: ListView.builder(
      //       itemCount: _productScanList.length,
      //       itemBuilder: (context, i) {
      //         return ListTile(
      //             leading: const Icon(Icons.gif_box),
      //             title: Text(_productScanList[i].toString()),
      //             trailing: const Icon(Icons.delete));
      //       },
      //     ),
      //   ),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            // you could add any widget
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.transparent,
              ),
              title: Row(
                children: const <Widget>[
                  Expanded(child: Text("Model")),
                  Expanded(child: Text("Serial")),
                  Expanded(child: Text("Action")),
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
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text((index + 1).toString()),
                            ),
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                        _productScanList[index].split(',')[1])),
                                Expanded(
                                    child: Text(
                                        _productScanList[index].split(',')[2])),
                                Expanded(
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
                                        contentProductScan = '$item}\n';
                                      }
                                      // widget.handleFile.writeProductScans(
                                      //     contentProductScan);
                                    },
                                  ),
                                ),
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
