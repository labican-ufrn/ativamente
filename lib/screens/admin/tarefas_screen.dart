import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/tarefa.dart';
import '../../providers/tarefas_provider.dart';
import '../../providers/tts_provider.dart';

class TarefasScreen extends ConsumerWidget {
  const TarefasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarefas = ref.watch(tarefasProvider);
    final readScreen = ref.watch(readScreenProvider(
      'Coleção de tarefas. Aqui você pode criar, consultar, editar e excluir tarefas.',
    ));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('CRUD de tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Ler tela',
            onPressed: readScreen,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: tarefas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro ao carregar tarefas: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: items.length,
                itemBuilder: (context, index) => _TarefaTile(tarefa: items[index]),
              ),
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context, WidgetRef ref, [Tarefa? tarefa]) async {
    final tituloController = TextEditingController(text: tarefa?.titulo ?? '');
    final descricaoController = TextEditingController(text: tarefa?.descricao ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tarefa == null ? 'Criar tarefa' : 'Editar tarefa'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: tituloController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título'
                    : null,
              ),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final controller = ref.read(tarefasControllerProvider);
              if (tarefa == null) {
                await controller.criar(
                  titulo: tituloController.text.trim(),
                  descricao: descricaoController.text.trim(),
                );
              } else {
                await controller.atualizar(Tarefa(
                  id: tarefa.id,
                  titulo: tituloController.text.trim(),
                  descricao: descricaoController.text.trim(),
                  concluida: tarefa.concluida,
                ));
              }
              if (dialogContext.mounted) dialogContext.pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    tituloController.dispose();
    descricaoController.dispose();
  }
}

class _TarefaTile extends ConsumerWidget {
  final Tarefa tarefa;

  const _TarefaTile({required this.tarefa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tarefasControllerProvider);
    return Card(
      child: ListTile(
        leading: Icon(tarefa.concluida ? Icons.check_circle : Icons.radio_button_unchecked),
        title: Text(tarefa.titulo),
        subtitle: Text(tarefa.descricao.isEmpty ? 'Sem descrição' : tarefa.descricao),
        onTap: () async {
          final atual = await controller.buscarPorId(tarefa.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(atual == null ? 'Tarefa não encontrada' : 'Consulta pontual: ${atual.titulo}')),
          );
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'editar') {
              await _editar(context, ref);
            } else if (value == 'concluir') {
              await controller.atualizar(Tarefa(
                id: tarefa.id,
                titulo: tarefa.titulo,
                descricao: tarefa.descricao,
                concluida: !tarefa.concluida,
              ));
            } else {
              await controller.remover(tarefa.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(
              value: 'concluir',
              child: Text(tarefa.concluida ? 'Reabrir' : 'Concluir'),
            ),
            const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final tituloController = TextEditingController(text: tarefa.titulo);
    final descricaoController = TextEditingController(text: tarefa.descricao);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await ref.read(tarefasControllerProvider).atualizar(Tarefa(
                id: tarefa.id,
                titulo: tituloController.text.trim(),
                descricao: descricaoController.text.trim(),
                concluida: tarefa.concluida,
              ));
              if (dialogContext.mounted) dialogContext.pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    tituloController.dispose();
    descricaoController.dispose();
  }
}