import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pessoa.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tts_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _nascimentoController;
  late TextEditingController _pesoController;
  late TextEditingController _alturaController;
  
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _nascimentoController = TextEditingController();
    _pesoController = TextEditingController();
    _alturaController = TextEditingController();
  }

  void _initControllers(Pessoa pessoa) {
    if (_isInitialized) return;
    _nomeController.text = pessoa.nome;
    _telefoneController.text = pessoa.numTelefone;
    _nascimentoController.text = pessoa.dataNascimento;
    _pesoController.text = pessoa.peso != 0.0 ? pessoa.peso.toString() : '';
    _alturaController.text = pessoa.altura != 0.0 ? pessoa.altura.toString() : '';
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _nascimentoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authStateProvider).value;
    if (user == null || user.uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final peso = double.tryParse(_pesoController.text.replaceAll(',', '.').trim());
      final altura = double.tryParse(_alturaController.text.replaceAll(',', '.').trim());

      final data = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        'numTelefone': _telefoneController.text.trim(),
        'dataNascimento': _nascimentoController.text.trim(),
        if (peso != null) 'peso': peso,
        if (altura != null) 'altura': altura,
      };

      await FirebaseFirestore.instance
          .collection('Pessoas')
          .doc(user.uid)
          .update(data);
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateDataNascimento(String? value) {
    if (value == null || value.isEmpty) return 'Informe a data de nascimento';
    
    final RegExp dateRegExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegExp.hasMatch(value)) {
      return 'Formato inválido. Use DD/MM/AAAA';
    }
    
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Data inválida';
      }

      final today = DateTime.now();
      if (date.isAfter(today)) {
        return 'Data de nascimento não pode ser no futuro';
      }
      
      int age = today.year - date.year;
      if (today.month < date.month || (today.month == date.month && today.day < date.day)) {
        age--;
      }
      
      if (age < 14) {
        return 'Idade mínima é 14 anos';
      }
    } catch (e) {
      return 'Data inválida';
    }
    
    return null;
  }

  String? _validateTelefone(String? value) {
    if (value != null && value.isNotEmpty) {
       if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
         return 'Telefone deve ter DDD e número válido';
       }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const screenText = "Tela de edição de perfil. Altere seus dados pessoais como nome, data de nascimento, telefone, peso e altura.";
    final readScreen = ref.watch(readScreenProvider(screenText));
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: userDataAsync.when(
        data: (pessoa) {
          if (pessoa != null) {
            _initControllers(pessoa);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 18),
                    validator: (value) => 
                        value == null || value.isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nascimentoController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento (DD/MM/AAAA)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 25/12/1950',
                    ),
                    keyboardType: TextInputType.datetime,
                    style: const TextStyle(fontSize: 18),
                    validator: _validateDataNascimento,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone com DDD',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: (84) 99999-9999',
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 18),
                    validator: _validateTelefone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pesoController,
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _alturaController,
                          decoration: const InputDecoration(
                            labelText: 'Altura (m)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar Alterações', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erro ao carregar perfil: $err',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

