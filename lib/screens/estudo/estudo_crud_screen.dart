import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tarefa_estudo.dart';
import '../../providers/estudo_firestore_provider.dart';
import '../../providers/tts_provider.dart';

class EstudoCrudScreen extends ConsumerStatefulWidget {
  const EstudoCrudScreen({super.key});

  @override
  ConsumerState<EstudoCrudScreen> createState() => _EstudoCrudScreenState();
}

class _EstudoCrudScreenState extends ConsumerState<EstudoCrudScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  String? _editingId;
  bool _isSaving = false;
  bool _usePontualQuery = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _tituloController.clear();
      _descricaoController.clear();
    });
  }

  void _startEditing(TarefaEstudo tarefa) {
    setState(() {
      _editingId = tarefa.id;
      _tituloController.text = tarefa.titulo;
      _descricaoController.text = tarefa.descricao;
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final service = ref.read(estudoFirestoreServiceProvider);

    try {
      if (_editingId == null) {
        // Create (Adicionar)
        await service.addTarefa(
          _tituloController.text.trim(),
          _descricaoController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa adicionada com sucesso!')),
          );
        }
      } else {
        // Update (Editar)
        await service.updateTarefa(_editingId!, {
          'titulo': _tituloController.text.trim(),
          'descricao': _descricaoController.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
          );
        }
      }
      _clearForm();
      if (_usePontualQuery) {
        ref.invalidate(tarefasPontualProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleConcluida(TarefaEstudo tarefa) async {
    final service = ref.read(estudoFirestoreServiceProvider);
    try {
      await service.updateTarefa(tarefa.id, {
        'concluida': !tarefa.concluida,
      });
      if (_usePontualQuery) {
        ref.invalidate(tarefasPontualProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    }
  }

  Future<void> _deleteTarefa(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente remover esta tarefa do Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(estudoFirestoreServiceProvider);
      try {
        await service.deleteTarefa(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa removida com sucesso!')),
          );
        }
        if (_usePontualQuery) {
          ref.invalidate(tarefasPontualProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const screenText =
        "Tela de Estudo CRUD no Firestore. Formulário de cadastro de tarefas e lista em tempo real.";
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudo CRUD Firestore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card do Formulário
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _editingId == null ? 'Cadastrar Tarefa' : 'Editar Tarefa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Título da Tarefa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        style: const TextStyle(fontSize: 18),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveForm,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(_editingId == null ? Icons.add : Icons.save),
                              label: Text(_editingId == null ? 'Adicionar' : 'Salvar Alteraçoes'),
                            ),
                          ),
                          if (_editingId != null) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _clearForm,
                              child: const Text('Cancelar'),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controles de Modo de Leitura (Stream vs Consulta Pontual)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _usePontualQuery ? 'Consulta Pontual (.get)' : 'Tempo Real (Stream)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _usePontualQuery,
                      onChanged: (val) {
                        setState(() => _usePontualQuery = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarefas Cadastradas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_usePontualQuery)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.invalidate(tarefasPontualProvider),
                    tooltip: 'Atualizar consulta pontual',
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Lista de Tarefas
            _buildTarefasList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTarefasList() {
    if (_usePontualQuery) {
      final pontualAsync = ref.watch(tarefasPontualProvider);
      return pontualAsync.when(
        data: (tarefas) => _buildListView(tarefas),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro na busca pontual: $err')),
      );
    }

    final streamAsync = ref.watch(tarefasStreamProvider);
    return streamAsync.when(
      data: (tarefas) => _buildListView(tarefas),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro no stream Firestore: $err')),
    );
  }

  Widget _buildListView(List<TarefaEstudo> tarefas) {
    if (tarefas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Nenhuma tarefa cadastrada no Firestore.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tarefas.length,
      itemBuilder: (context, index) {
        final tarefa = tarefas[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 2,
          child: ListTile(
            leading: Checkbox(
              value: tarefa.concluida,
              onChanged: (_) => _toggleConcluida(tarefa),
            ),
            title: Text(
              tarefa.titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                color: tarefa.concluida ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
            ),
            subtitle: tarefa.descricao.isNotEmpty
                ? Text(
                    tarefa.descricao,
                    style: const TextStyle(fontSize: 16),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _startEditing(tarefa),
                  tooltip: 'Editar tarefa',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTarefa(tarefa.id),
                  tooltip: 'Excluir tarefa',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
