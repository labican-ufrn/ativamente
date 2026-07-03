import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tts_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const screenText = "App Academia. Seja bem-vindo! Botão Entrar. Botão Criar conta.";
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Color(0xFF1E315A), size: 32),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Placeholder for Logo
              const Icon(
                Icons.favorite_border, // Using generic icon until asset is provided
                size: 100,
                color: Color(0xFF1E315A),
              ),
              const SizedBox(height: 16),
              Text(
                'App Academia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Seja bem-vindo(a)!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Entrar'),
                    SizedBox(width: 8),
                    Icon(Icons.login),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Criar conta'),
                    SizedBox(width: 8),
                    Icon(Icons.edit),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
