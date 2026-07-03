import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tts_provider.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';
  bool _isLoading = false;

  void _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider).createSecondaryUser(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            _selectedRole,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário adicionado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar usuário: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readScreen = ref.watch(readScreenProvider("Tela de adicionar usuário. Preencha os campos para criar um novo usuário."));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) => value!.isEmpty ? 'Insira o nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Tipo de Usuário'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Usuário Comum')),
                  DropdownMenuItem(value: 'trainer', child: Text('Personal Trainer')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Insira o e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Senha deve ter no mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Criar Usuário', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
