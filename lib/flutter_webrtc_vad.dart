import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';

class FlutterWebrtcVAD {
  final lib = WebrtcVadLibrary(DynamicLibrary.open('libwebrtc_vad.so'));
  Pointer<Fvad>? instance;
  bool isInitialized = false;

  void initialize({VADMode mode = VADMode.normal, int sampleRate = 16000}) {
    instance = lib.fvad_new();
    if (instance == null) throw Exception('fvad_new failed');
    _setMode(mode);
    _setSampleRate(sampleRate);
    isInitialized = true;
  }

  void dispose() {
    if (!isInitialized) return;
    lib.fvad_reset(instance!);
    lib.fvad_free(instance!);
    isInitialized = false;
  }

  /// Changes the VAD operating ("aggressiveness") mode of a VAD instance.
  ///
  /// A more aggressive (higher mode) VAD is more restrictive in reporting speech.
  /// Put in other words the probability of being speech when the VAD returns 1 is
  /// increased with increasing mode. As a consequence also the missed detection
  /// rate goes up.
  ///
  /// Valid modes are [normal], [lowBitrate], [aggressive], and
  /// [veryAggressive]. The default mode is 0.
  ///
  void _setMode(VADMode mode) {
    final res = lib.fvad_set_mode(instance!, mode.index);
    if (res == -1) throw Exception('fvad_set_mode failed');
  }

  /// Sets the input sample rate in Hz for a VAD instance.
  ///
  /// Valid values are 8000, 16000, 32000 and 48000. The default is 8000.
  /// that internally all processing will be done 8000 Hz; input data in higher
  /// sample rates will just be downsampled first.
  ///
  void _setSampleRate(int sampleRate) {
    final res = lib.fvad_set_sample_rate(instance!, sampleRate);
    if (res == -1) throw Exception('fvad_set_sample_rate failed');
  }

  /// Calculates a VAD decision for an audio frame.
  ///
  /// `data` is a pointer to an int16 array of length `length`.
  bool process(List<int> data) {
    assert(isInitialized);
    final frame = malloc<Int16>(data.length);

    for (var i = 0; i < data.length; i++) {
      frame[i] = data[i];
    }

    final res = lib.fvad_process(instance!, frame, data.length);
    malloc.free(frame);
    if (res == -1) throw Exception('fvad_process failed');
    return res == 1;
  }
}

enum VADMode {
  normal,
  lowBitrate,
  aggressive,
  veryAggressive,
}
