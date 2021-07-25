import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _flashStatus = false;
  QRViewController? controller;
  Barcode? result;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    controller?.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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
      extendBody: true,
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
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                color: Colors.black38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        _flashStatus ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        controller!.getSystemFeatures().then((value) {
                          if (value.hasFlash) {
                            controller!.toggleFlash().then((value) {
                              controller!.getFlashStatus().then((value) {
                                _flashStatus = value!;
                              });
                            });
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cameraswitch_rounded,
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
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black38,
                  padding: EdgeInsets.all(15),
                  width: double.infinity,
                  child: result != null
                      ? Text(
                          'Data: ${result!.code}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Scan QR Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
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
