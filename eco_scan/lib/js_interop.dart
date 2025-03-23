import 'package:js/js.dart';
import 'package:universal_html/html.dart' as html;

@JS('BarcodeReader')
external dynamic get barcodeReader;

@JS('BarcodeReader.init')
external void init(Function callback);

@JS('BarcodeReader.start')
external void start(html.VideoElement videoElement, Function onDetected);

@JS('BarcodeReader.stop')
external void stop();