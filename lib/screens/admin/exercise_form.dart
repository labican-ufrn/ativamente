import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/exercicio.dart';
import '../../providers/tts_provider.dart';

class ExerciseForm extends ConsumerStatefulWidget {
  const ExerciseForm({
    super.key,
    required this.title,
    required this.onSave,
    this.exercise,
  });

  final String title;
  final Exercicio? exercise;
  final Future<void> Function(Exercicio exercise) onSave;

  @override
  ConsumerState<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends ConsumerState<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _mediaController;
  late final TextEditingController _categoryController;
  late final TextEditingController _typeController;
  late final String _categoryIcon;
  late final String _typeIcon;
  late int _intensity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _nameController = TextEditingController(text: exercise?.nome ?? '');
    _descriptionController = TextEditingController(
      text: exercise?.descricao ?? '',
    );
    _mediaController = TextEditingController(text: exercise?.midia ?? '');
    _categoryController = TextEditingController(
      text: exercise?.categoria.nome ?? '',
    );
    _typeController = TextEditingController(text: exercise?.tipo.nome ?? '');
    _categoryIcon = exercise?.categoria.icone ?? 'fitness_center';
    _typeIcon = exercise?.tipo.icone ?? 'fitness_center';
    _intensity = exercise?.intensidade ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mediaController.dispose();
    _categoryController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Informe $label.';
    return null;
  }

  String? _validateMedia(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Informe um endereço válido começando com http:// ou https://.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final currentExercise = widget.exercise;
    final exercise = Exercicio(
      id: currentExercise?.id ?? '',
      codigo: currentExercise?.codigo ?? '',
      nome: _nameController.text.trim(),
      descricao: _descriptionController.text.trim(),
      midia: _mediaController.text.trim(),
      statusRealizado: currentExercise?.statusRealizado ?? false,
      categoria: Categoria(
        nome: _categoryController.text.trim(),
        icone: _categoryIcon,
      ),
      tipo: Tipo(nome: _typeController.text.trim(), icone: _typeIcon),
      intensidade: _intensity,
    );

    try {
      await widget.onSave(exercise);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercício salvo com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar o exercício: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final readScreen = ref.watch(
      readScreenProvider(
        'Formulário de exercício. Informe nome, descrição, categoria, tipo e intensidade.',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: readScreen,
            tooltip: 'Ler tela',
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
              decoration: const InputDecoration(labelText: 'Nome do exercício'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => _requiredField(value, 'o nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => _requiredField(value, 'a descrição'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Categoria'),
              validator: (value) => _requiredField(value, 'a categoria'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Tipo'),
              validator: (value) => _requiredField(value, 'o tipo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mediaController,
              decoration: const InputDecoration(
                labelText: 'Link de mídia (opcional)',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              validator: _validateMedia,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _intensity,
              decoration: const InputDecoration(
                labelText: 'Intensidade (1 a 10)',
              ),
              items: List.generate(
                10,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _intensity = value);
                    },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Salvar exercício'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
