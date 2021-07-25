# qr_generator_reader

A QR Generator and QR Scanner made using Dart Language with Flutter SDK

This demonstrates the packages: 
- qr_flutter
- qr_code_scanner
- path_provider
- image_picker
- flutter_keyboard_visibility
- share
- permission_handler

Note: Sorry for the bad footage quality I was using a webcam with no auto focus and exposure.

## Preview

|              Generator Preview             |             Scanner Preview           |
| :----------------------------------------: | :-----------------------------------: |
|![generator_preview](https://user-images.githubusercontent.com/78299538/126902042-ebd13de8-cabb-4c57-b0d3-d72b0e927814.gif)|![scanner_preview](https://user-images.githubusercontent.com/78299538/126902070-21df11a5-33ed-4123-8907-28de72f91f4b.gif)|


### Bugs

The QR Code Sanner (qr_code_scanner: ^0.5.2) used by this project has some issues with Android 5.1.1 where it crashes as soon as it recognizes the QR Code.

* [BUG] App Crashes on opening qr scanner on older devices ([#337][i337])

[i337]: https://github.com/juliuscanute/qr_code_scanner/issues/377
