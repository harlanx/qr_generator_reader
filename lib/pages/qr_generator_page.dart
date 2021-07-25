import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class QRGenerator extends StatefulWidget {
  const QRGenerator({Key? key}) : super(key: key);

  @override
  _QRGeneratorState createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  final String _kDefaultImagePath = 'assets/images/dashatar.jpg';
  final _keyboardController = KeyboardVisibilityController();
  final _focuseNode = FocusNode();
  late StreamSubscription _keyboardListener;
  final ImagePicker _picker = ImagePicker();
  String _imageFileName = '';
  String _data = '';
  String _imagePath = 'assets/images/dashatar.jpg';
  bool _qrAvailable = false;
  bool _includeImage = false;
  Uint8List? qrImage;

  @override
  void initState() {
    super.initState();
    _keyboardListener = _keyboardController.onChange.listen((visible) {
      if (!visible) {
        setState(() {
          if (_focuseNode.hasFocus) {
            _focuseNode.unfocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _keyboardListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Generate'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                focusNode: _focuseNode,
                decoration: InputDecoration(
                  hintText: 'Sample data {"id":123,"name":"John Doe"}',
                  hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade400),
                  labelText: 'Data',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  _data = value;
                },
                onSubmitted: (value) {
                  setState(() {
                    _data = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text('Embedded Center Image (Optional)')),
              Row(
                children: [
                  Checkbox(
                    value: _includeImage,
                    onChanged: (value) {
                      setState(() {
                        _includeImage = !_includeImage;
                      });
                    },
                  ),
                  ElevatedButton(
                    child: Text('Insert Image'),
                    onPressed: _includeImage
                        ? () async {
                            await _picker.pickImage(source: ImageSource.gallery).then((value) {
                              if (value != null) {
                                setState(() {
                                  _imagePath = value.path;
                                });
                              }
                            });
                          }
                        : null,
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: SingleChildScrollView(
                            child: Text(
                              _imagePath,
                              style: TextStyle(color: _includeImage ? Colors.black : Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _imagePath != _kDefaultImagePath,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: MaterialButton(
                              padding: EdgeInsets.all(2.5),
                              minWidth: 0,
                              shape: CircleBorder(),
                              color: Colors.grey.shade400,
                              textColor: Colors.white,
                              child: Icon(
                                Icons.close,
                                size: 15,
                              ),
                              onPressed: () {
                                setState(() {
                                  _imagePath = _kDefaultImagePath;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Generated QR Code'),
                      AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _qrAvailable && qrImage != null
                              ? Image.memory(qrImage!)
                              : Text(
                                  'N/A',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Generate'),
                    onPressed: _data.isNotEmpty
                        ? () async {
                            await generateQR().then((value) {
                              setState(() {
                                _imageFileName = 'QRCode_${DateTime.now().millisecondsSinceEpoch.toString()}';
                                qrImage = value;
                                _qrAvailable = true;
                              });
                            }).catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e)),
                              );
                            });
                          }
                        : null,
                  ),
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: _qrAvailable
                        ? () async {
                            await Permission.storage.request().then((status) async {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              if (status.isGranted) {
                                Directory dlDir = Directory('storage/emulated/0/Download');
                                if (!(await dlDir.exists())) {
                                  dlDir.create();
                                }
                                String imagePath = '${dlDir.path}/$_imageFileName.png';
                                if (!(await File(imagePath).exists())) {
                                  File(imagePath).writeAsBytes(qrImage!).then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved Locally')));
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Already Saved')));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage Permission Not Granted')));
                              }
                            });
                          }
                        : null,
                  ),
                  ElevatedButton(
                    child: Text('Share'),
                    onPressed: _qrAvailable
                        ? () async {
                            Directory docDir = await getTemporaryDirectory();
                            String imagePath = '${docDir.path}/$_imageFileName.png';
                            File(imagePath).writeAsBytes(qrImage!).then((value) {
                              Share.shareFiles(['${value.path}'], text: 'QR Image').then((value) {
                                return null;
                              });
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> generateQR() async {
    late Uint8List imageByte;
    if (_imagePath == _kDefaultImagePath) {
      await rootBundle.load(_imagePath).then((value) {
        imageByte = value.buffer.asUint8List();
      });
    } else {
      var userFile = XFile(_imagePath);
      imageByte = await userFile.readAsBytes();
    }

    ui.Codec codec = await ui.instantiateImageCodec(imageByte);
    ui.FrameInfo fi = await codec.getNextFrame();

    final validationResult = QrValidator.validate(
      data: _data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (validationResult.isValid) {
      final painter = QrPainter.withQr(
        qr: validationResult.qrCode!,
        embeddedImage: _includeImage ? fi.image : null,
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(
            // Embedded image size must not cover over 30 percent of the QR Code or else the scanner
            // have a hard tine reading the QR Code or not be able to read at all.
            MediaQuery.of(context).size.width * 0.30,
            MediaQuery.of(context).size.width * 0.30,
          ),
        ),
      );

      final imageData = await painter.toImageData(720, format: ui.ImageByteFormat.png);
      return imageData!.buffer.asUint8List();
    }
    return Future.error('Cannot generate QR Code');
  }
}
