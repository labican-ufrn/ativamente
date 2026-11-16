import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/tts_provider.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediaController = TextEditingController();

  static const _categories = ['Coracao', 'Musculo'];
  static const _types = ['Cardio', 'Forca', 'Alongamento', 'Estabilidade'];
  String _category = _categories.first;
  String _type = _types.first;
  double _intensity = 5;
  bool _isSaving = false;

  String _intensityLabel(int value) {
    if (value <= 5) return 'Leve';
    if (value <= 8) return 'Moderado';
    return 'Intenso';
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe o nome do exercício';
    if (name.length > 150) return 'Use no máximo 150 caracteres';
    return null;
  }

  String? _validateDescription(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Informe as instruções de execução';
    }
    return null;
  }

  String? _validateMedia(String? value) {
    final media = value?.trim() ?? '';
    if (media.isEmpty) return null;
    final uri = Uri.tryParse(media);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Informe uma URL http:// ou https:// válida';
    }
    return null;
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final media = _mediaController.text.trim();
    final intensity = _intensity.round();

    try {
      await FirebaseFirestore.instance.collection('Exercicios').add({
        'codigo': 'exercicio-${DateTime.now().millisecondsSinceEpoch}',
        'nome': name,
        'descricao': description,
        'midia': media,
        'statusRealizado': false,
        'categoria': {
          'nome': _category,
          'icone': _category == 'Coracao' ? 'favorite' : 'fitness_center',
        },
        'tipo': {
          'nome': _type,
          'icone': _type == 'Cardio'
              ? 'directions_run'
              : _type == 'Alongamento'
              ? 'self_improvement'
              : 'fitness_center',
        },
        'intensidade': intensity,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício cadastrado com sucesso!')),
      );
      context.pop();
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível cadastrar o exercício: ${error.message ?? error.code}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readScreen = ref.watch(
      readScreenProvider(
        'Tela de cadastro de exercício. Informe nome, instruções, categoria, tipo e intensidade.',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo exercício'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Ler tela',
            onPressed: readScreen,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do exercício *',
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição / instruções *',
              ),
              validator: _validateDescription,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria *'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo *'),
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 20),
            Semantics(
              label:
                  'Intensidade ${_intensity.round()}, ${_intensityLabel(_intensity.round())}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intensidade: ${_intensity.round()} - ${_intensityLabel(_intensity.round())}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: _intensity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${_intensity.round()}',
                    onChanged: (value) => setState(() => _intensity = value),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 - Leve'),
                      Text('5 - Leve'),
                      Text('8 - Moderado'),
                      Text('10 - Intenso'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _mediaController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL de GIF ou mídia (opcional)',
              ),
              validator: _validateMedia,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveExercise,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Cadastrar exercício'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
