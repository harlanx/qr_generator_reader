import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Note: qr_code_scanner: ^0.5.2 has some issues with Android 5.1.1 or lower where it crashes
// immediately after recognizing the QRCode 
// Issue: https://github.com/juliuscanute/qr_code_scanner/issues/377

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey _viewKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Reassemble is for debug only.
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    //var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 500.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Read'),
        centerTitle: true,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            QRView(
              key: _viewKey,
              onQRViewCreated: _onViewCreated,
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
              overlay: QrScannerOverlayShape(
                borderColor: Colors.orange.shade400,
                borderRadius: 5,
                borderLength: 20,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.flash_on,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller!.getSystemFeatures().then((value) {
                        if (value.hasFlash) {
                          controller!.toggleFlash();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_front_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller!.getSystemFeatures().then((value) {
                        if (value.hasFrontCamera && value.hasBackCamera) {
                          controller!.flipCamera();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black38,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 20),
                child: result != null
                    ? Text(
                        'Barcode Type: ${describeEnum(result!.format)}\n\nData: ${result!.code}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    print('created');
    controller.scannedDataStream.listen((data) {
      print('listening');
      setState(() {
        this.result = data;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    //log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget resultDialog(Barcode barcode) {
    return SimpleDialog(
      children: [
        Text(
          'Barcode Type: ${describeEnum(barcode.format)}\n\nData: ${barcode.code}',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
