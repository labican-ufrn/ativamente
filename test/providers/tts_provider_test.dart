import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/tts_provider.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ttsProvider', () {
    const canal = MethodChannel('flutter_tts');
    late List<MethodCall> chamadas;

    setUp(() {
      chamadas = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, (call) async {
            chamadas.add(call);
            return 1;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, null);
    });

    test('configura idioma pt-BR, velocidade, volume e tom', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(ttsProvider);
      await pumpEventQueue();

      final porMetodo = {for (final c in chamadas) c.method: c.arguments};
      expect(porMetodo['setLanguage'], 'pt-BR');
      expect(porMetodo['setSpeechRate'], 0.5);
      expect(porMetodo['setVolume'], 1.0);
      expect(porMetodo['setPitch'], 1.0);
    });
  });

  group('readScreenProvider', () {
    test('interrompe a fala atual antes de ler o novo texto', () async {
      final tts = FakeFlutterTts();
      final container = ProviderContainer(
        overrides: [ttsProvider.overrideWithValue(tts)],
      );
      addTearDown(container.dispose);

      final lerTela = container.read(readScreenProvider('Tela inicial.'));
      lerTela();
      await pumpEventQueue();

      expect(tts.chamadas, ['stop', 'speak:Tela inicial.']);
    });

    test('cada texto gera uma função de leitura própria', () async {
      final tts = FakeFlutterTts();
      final container = ProviderContainer(
        overrides: [ttsProvider.overrideWithValue(tts)],
      );
      addTearDown(container.dispose);

      container.read(readScreenProvider('A'))();
      await pumpEventQueue();
      container.read(readScreenProvider('B'))();
      await pumpEventQueue();

      expect(tts.chamadas, ['stop', 'speak:A', 'stop', 'speak:B']);
    });
  });
}
