import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final ttsProvider = Provider<FlutterTts>((ref) {
  final flutterTts = FlutterTts();
  flutterTts.setLanguage("pt-BR");
  flutterTts.setSpeechRate(0.5);
  flutterTts.setVolume(1.0);
  flutterTts.setPitch(1.0);
  return flutterTts;
});

final readScreenProvider = Provider.family<void Function(), String>((ref, textToRead) {
  final tts = ref.watch(ttsProvider);
  return () async {
    await tts.stop();
    await tts.speak(textToRead);
  };
});
