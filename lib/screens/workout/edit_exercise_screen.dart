import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/intensity.dart';
import '../../models/exercicio.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/tts_provider.dart';

// Valores usados pelo app (mesmos do seed `assets/data/exercises.json`).
const _categorias = <(String, String)>[
  ('Coracao', 'favorite'),
  ('Equilibrio', 'balance'),
  ('Flexibilidade', 'accessibility_new'),
  ('Musculo', 'fitness_center'),
  ('NaRua', 'park'),
];

const _tipos = <(String, String)>[
  ('Cardio', 'directions_run'),
  ('Estabilidade', 'accessibility'),
  ('Alongamento', 'self_improvement'),
  ('Forca', 'fitness_center'),
];

/// Opções do seletor; preserva o valor atual caso não esteja na lista padrão.
List<String> _opcoes(List<(String, String)> padrao, String atual) => [
  for (final (nome, _) in padrao) nome,
  if (atual.isNotEmpty && !padrao.any((o) => o.$1 == atual)) atual,
];

/// Papéis autorizados a editar exercícios.
const papeisEditoresExercicio = {'trainer', 'admin'};

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/workout');
  }
}

class EditExerciseScreen extends ConsumerWidget {
  const EditExerciseScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pessoa = ref.watch(userDataProvider);
    if (pessoa.isLoading) {
      return const _StateScreen(
        message: 'Carregando...',
        screenText: 'Editar exercício. Carregando.',
        showProgress: true,
      );
    }
    if (!papeisEditoresExercicio.contains(pessoa.value?.role)) {
      return const _StateScreen(
        message: 'Você não tem permissão para editar exercícios.',
        screenText:
            'Editar exercício. Você não tem permissão para editar exercícios.',
      );
    }

    return ref
        .watch(exerciciosProvider)
        .when(
          data: (exercicios) {
            for (final exercicio in exercicios) {
              if (exercicio.id == exerciseId) {
                return _EditExerciseForm(exercicio: exercicio);
              }
            }
            return const _StateScreen(
              message: 'Exercício não encontrado.',
              screenText: 'Editar exercício. Exercício não encontrado.',
            );
          },
          loading: () => const _StateScreen(
            message: 'Carregando exercício...',
            screenText: 'Editar exercício. Carregando.',
            showProgress: true,
          ),
          error: (err, stack) {
            debugPrint('Erro ao buscar exercício $exerciseId: $err');
            return const _StateScreen(
              message:
                  'Não foi possível carregar o exercício. Tente novamente.',
              screenText:
                  'Editar exercício. Erro ao carregar. Tente novamente.',
            );
          },
        );
  }
}

class _StateScreen extends ConsumerWidget {
  const _StateScreen({
    required this.message,
    required this.screenText,
    this.showProgress = false,
  });

  final String message;
  final String screenText;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(
        context,
        onRead: () => ref.read(readScreenProvider(screenText))(),
      ),
      body: Center(
        child: showProgress
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
      ),
    );
  }
}

AppBar _buildAppBar(BuildContext context, {required VoidCallback onRead}) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      tooltip: 'Voltar',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: () => _goBack(context),
    ),
    title: const Text(
      'Editar exercício',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.volume_up, size: 28),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: onRead,
        tooltip: 'Ler tela',
      ),
    ],
  );
}

class _EditExerciseForm extends ConsumerStatefulWidget {
  const _EditExerciseForm({required this.exercicio});

  final Exercicio exercicio;

  @override
  ConsumerState<_EditExerciseForm> createState() => _EditExerciseFormState();
}

class _EditExerciseFormState extends ConsumerState<_EditExerciseForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers preenchidos uma única vez: novos eventos do stream não
  // sobrescrevem o que o Personal Trainer está digitando.
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _midiaController;
  late int _intensidade;
  late String _categoriaNome;
  late String _tipoNome;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.exercicio;
    _nomeController = TextEditingController(text: e.nome);
    _descricaoController = TextEditingController(text: e.descricao);
    _midiaController = TextEditingController(text: e.midia);
    _intensidade = e.intensidade;
    _categoriaNome = e.categoria.nome;
    _tipoNome = e.tipo.nome;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _midiaController.dispose();
    super.dispose();
  }

  void _readScreen() {
    final text =
        'Editar exercício. ${widget.exercicio.nome}. '
        'Campos: nome, descrição, mídia, intensidade $_intensidade '
        '(${rotuloIntensidade(_intensidade)}), categoria $_categoriaNome '
        'e tipo $_tipoNome. Botão salvar alterações.';
    ref.read(readScreenProvider(text))();
  }

  String _icone(List<(String, String)> padrao, String nome, String atual) {
    for (final (n, icone) in padrao) {
      if (n == nome) return icone;
    }
    return atual;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final e = widget.exercicio;
    setState(() => _isSaving = true);
    try {
      // Apenas campos editáveis: `codigo` e `criadoEm` nunca entram no payload.
      await ref
          .read(atualizarExercicioProvider)(e.id, {
            'nome': _nomeController.text.trim(),
            'descricao': _descricaoController.text.trim(),
            'midia': _midiaController.text.trim(),
            'intensidade': _intensidade,
            'categoria': {
              'nome': _categoriaNome,
              'icone': _icone(_categorias, _categoriaNome, e.categoria.icone),
            },
            'tipo': {
              'nome': _tipoNome,
              'icone': _icone(_tipos, _tipoNome, e.tipo.icone),
            },
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Tempo limite esgotado.'),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício atualizado com sucesso!')),
      );
      _goBack(context);
    } catch (err) {
      debugPrint('Erro ao atualizar exercício ${e.id}: $err');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar as alterações. Tente novamente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, onRead: _readScreen),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                style: const TextStyle(fontSize: 18),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o nome do exercício'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição / instruções',
                ),
                style: const TextStyle(fontSize: 18),
                minLines: 3,
                maxLines: 6,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe as instruções do exercício'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _midiaController,
                decoration: const InputDecoration(
                  labelText: 'Mídia (URL)',
                  hintText: 'https://...',
                ),
                keyboardType: TextInputType.url,
                style: const TextStyle(fontSize: 18),
                validator: (v) {
                  final url = v?.trim() ?? '';
                  if (url.isEmpty) return null;
                  final uri = Uri.tryParse(url);
                  return uri != null && uri.hasScheme && uri.host.isNotEmpty
                      ? null
                      : 'Informe uma URL válida';
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _intensidade,
                decoration: const InputDecoration(labelText: 'Intensidade'),
                style: const TextStyle(fontSize: 18),
                items: [
                  for (var i = 1; i <= 10; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('$i — ${rotuloIntensidade(i)}'),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _intensidade = v ?? _intensidade),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoriaNome,
                decoration: const InputDecoration(labelText: 'Categoria'),
                style: const TextStyle(fontSize: 18),
                items: [
                  for (final n in _opcoes(
                    _categorias,
                    widget.exercicio.categoria.nome,
                  ))
                    DropdownMenuItem(value: n, child: Text(n)),
                ],
                onChanged: (v) =>
                    setState(() => _categoriaNome = v ?? _categoriaNome),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoNome,
                decoration: const InputDecoration(labelText: 'Tipo'),
                style: const TextStyle(fontSize: 18),
                items: [
                  for (final n in _opcoes(_tipos, widget.exercicio.tipo.nome))
                    DropdownMenuItem(value: n, child: Text(n)),
                ],
                onChanged: (v) => setState(() => _tipoNome = v ?? _tipoNome),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Icon(Icons.save, size: 28),
                label: Text(
                  _isSaving ? 'Salvando...' : 'Salvar alterações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
