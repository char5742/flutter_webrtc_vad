import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc_vad/flutter_webrtc_vad.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final vad= FlutterWebrtcVAD();
  vad.initialize();
  vad.dispose();
}
