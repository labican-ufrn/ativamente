import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tts_provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final signedIn = await ref
          .read(authControllerProvider)
          .signInWithGoogle();
      if (signedIn && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        final message = e is FirebaseAuthException
            ? (e.message ?? 'Erro ao entrar com o Google.')
            : e.toString().replaceAll('Exception: ', '');
        setState(() {
          _errorMessage = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(fontSize: 18)),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const screenText =
        'AtivaMente. Tela de Cadastro. Preencha seus dados. Campo nome. Campo email. Campo senha. Botão Cadastrar. Botão Entrar com Google.';
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          tooltip: 'Voltar',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Criar Conta', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'AtivaMente',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cadastre-se para começar!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  border: Border.all(color: Theme.of(context).colorScheme.error, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Nome completo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Seu nome completo',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text('Email', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Seu email',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Text('Senha', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Sua senha',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () async {
                setState(() {
                  _errorMessage = null;
                });
                try {
                  await ref.read(authControllerProvider).register(
                    _nameController.text.trim(),
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
                  if (context.mounted) context.go('/home');
                } catch (e) {
                  if (context.mounted) {
                    final message = e is FirebaseAuthException ? (e.message ?? 'Erro ao cadastrar.') : e.toString().replaceAll('Exception: ', '');
                    setState(() {
                      _errorMessage = message;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          message,
                          style: const TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: const Text('Cadastrar', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 16),
            Tooltip(
              message: 'Entrar com conta Google',
              excludeFromSemantics: true,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                onPressed: _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata, size: 36),
                label: const Text(
                  'Entrar com Google',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
