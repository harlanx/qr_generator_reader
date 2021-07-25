import 'package:flutter/material.dart';
import 'package:qr_generator_reader/pages/qr_generator_page.dart';
import 'package:qr_generator_reader/pages/qr_scanner_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: Text('Generate QR Code'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QRGenerator())),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            OutlinedButton(
              child: Text('Scan QR Code'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner())),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
