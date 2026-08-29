# Guia de Estudo: Firebase e Cloud Firestore (Issue #1)

Este documento registra as anotações, roteiros e trechos de código (snippets) resultantes dos estudos práticos do **Firebase (Authentication e Cloud Firestore)** no aplicativo **AtivaMente**.

---

## 1. Visão Geral e Roteiro de Setup

1. **Criação do Projeto no Firebase Console:**
   - Criar um projeto pessoal de testes no [Firebase Console](https://console.firebase.google.com/).
   - Ativar o serviço **Authentication** com o provedor de E-mail/Senha ativado.
   - Ativar o **Cloud Firestore** em modo de teste ou com regras de segurança inicializatórias.

2. **Configuração da CLI do FlutterFire:**
   - Instalar a CLI globalmente (caso necessário): `dart pub global activate flutterfire_cli`.
   - Executar no diretório raiz do projeto Flutter:
     ```bash
     flutterfire configure
     ```
   - O comando gera/atualiza automaticamente o arquivo `lib/firebase_options.dart`.

3. **Inicialização no Flutter (`main.dart`):**
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

---

## 2. Autenticação Básica (Firebase Auth)

### Cadastro de Usuário (E-mail / Senha)
```dart
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Login de Usuário
```dart
final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Logout
```dart
await FirebaseAuth.instance.signOut();
```

---

## 3. Operações CRUD no Cloud Firestore

### 3.1 Create (Adicionar Documento)
Usando `.add()` para gerar um ID automático e incluir carimbo de data/hora do servidor (`FieldValue.serverTimestamp()`):
```dart
final docRef = await FirebaseFirestore.instance.collection('estudo_tarefas').add({
  'titulo': titulo,
  'descricao': descricao,
  'concluida': false,
  'criadoEm': FieldValue.serverTimestamp(),
});
```

### 3.2 Read (Leitura em Tempo Real via Stream)
Escuta continuamente alterações na coleção com ordenação:
```dart
Stream<List<TarefaEstudo>> getTarefasStream() {
  return FirebaseFirestore.instance
      .collection('estudo_tarefas')
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => TarefaEstudo.fromJson(doc.data(), doc.id))
        .toList();
  });
}
```

### 3.3 Read (Consulta Pontual via `get()`)
Busca única dos documentos atuais sem escuta ativa:
```dart
Future<List<TarefaEstudo>> fetchTarefasPontual() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('estudo_tarefas')
      .orderBy('criadoEm', descending: true)
      .get();

  return snapshot.docs
      .map((doc) => TarefaEstudo.fromJson(doc.data(), doc.id))
      .toList();
}
```

### 3.4 Update (Editar Campos)
Atualiza apenas os campos especificados do documento:
```dart
await FirebaseFirestore.instance
    .collection('estudo_tarefas')
    .doc(documentId)
    .update({
  'titulo': novoTitulo,
  'descricao': novaDescricao,
  'concluida': statusConcluida,
});
```

### 3.5 Delete (Remover Documento)
Exclui um documento pelo seu ID:
```dart
await FirebaseFirestore.instance
    .collection('estudo_tarefas')
    .doc(documentId)
    .delete();
```

---

## 4. Uso com Firebase Emulators para Desenvolvimento Local

Para evitar custos e consumo de rede durante testes locais, utilize o Firebase Emulator Suite:

```dart
if (AppEnvironment.useEmulators) {
  await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
}
```

---

## 5. Checklist de Conclusão (LuizFelixDev)
- [x] Projeto pessoal de teste / ambiente de emuladores conectado ao Firebase.
- [x] CRUD completo (Create, Read Stream, Read Pontual `get()`, Update, Delete) no Firestore.
- [x] Autenticação por e-mail/senha testada.
- [x] Checkbox marcado e documentação atualizada.
