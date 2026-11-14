import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tts_provider.dart';

class ExerciseManagementGuard extends ConsumerWidget {
  const ExerciseManagementGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userDataProvider)
        .when(
          data: (pessoa) {
            if (pessoa?.podeGerenciarExercicios ?? false) return child;
            return const _AccessStateScreen(
              title: 'Acesso restrito',
              message: 'Você não tem autorização para gerenciar exercícios.',
            );
          },
          loading: () => const _AccessStateScreen(
            message: 'Verificando autorização...',
            showProgress: true,
          ),
          error: (error, stackTrace) {
            debugPrint(
              'Erro ao verificar autorização para gerenciar exercícios: $error',
            );
            return const _AccessStateScreen(
              message:
                  'Não foi possível verificar sua autorização. Tente novamente.',
            );
          },
        );
  }
}

class _AccessStateScreen extends ConsumerWidget {
  const _AccessStateScreen({
    this.title = 'Verificação de acesso',
    required this.message,
    this.showProgress = false,
  });

  final String title;
  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readScreen = ref.watch(readScreenProvider(message));
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress) const CircularProgressIndicator(),
              if (showProgress) const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              if (!showProgress) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Voltar ao perfil'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
