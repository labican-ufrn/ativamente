import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seed_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const screenText = "Tela de Perfil. Configurações de acessibilidade. Sair da conta.";
    final readScreen = ref.watch(readScreenProvider(screenText));
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF1E315A),
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 24),
          userDataAsync.when(
            data: (pessoa) => Text(
              pessoa?.nome ?? 'Nome do Usuário',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text(
              'Erro ao carregar',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Acessibilidade',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E315A)),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo Alto Contraste', style: TextStyle(fontSize: 18)),
            value: false,
            onChanged: (value) {},
          ),
          ListTile(
            title: const Text('Tamanho da Fonte', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.format_size),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Velocidade da Leitura (Voz)', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.record_voice_over),
            onTap: () {},
          ),
          const SizedBox(height: 48),
          userDataAsync.maybeWhen(
            data: (pessoa) {
              if (pessoa?.role == 'admin') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Admin (Testes)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E315A)),
                    ),
                    const Divider(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        context.push('/add-user');
                      },
                      child: const Text('Adicionar Usuário', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        try {
                          await ref.read(seedDatabaseProvider)();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Banco Semeado com sucesso!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Seed Database (Exercícios & Contas)', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            onPressed: () async {
              await ref.read(authControllerProvider).logout();
              if (context.mounted) context.go('/');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sair', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Icon(Icons.logout),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) {} // TODO: Progresso
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Progresso'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
