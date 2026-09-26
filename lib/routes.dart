import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

// Placeholder screens
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'screens/admin/add_user_screen.dart';

// Convenção de navegação (go_router):
// - `context.go(path)`: usar para TROCA DE SEÇÃO entre as rotas de nível
//   superior definidas abaixo (ex.: /home -> /workout -> /profile). `go`
//   substitui a pilha de navegação inteira, então não sobra nada para um
//   `context.pop()` desfazer. Uma tela alcançada via `go` deve voltar
//   chamando `context.go('/home')` (ou outra rota de destino explícita),
//   nunca `context.pop()`.
// - `context.push(path)`: usar para EMPILHAR uma tela de detalhe/fluxo sobre
//   a tela atual (ex.: profile -> /add-user). `push` mantém a rota anterior
//   na pilha, então a tela empilhada pode voltar com segurança usando
//   `context.pop()`.
// Misturar os dois (navegar com `go` e tentar voltar com `pop`) é a causa
// raiz de botões de "voltar" que não fazem nada — ver issue #6.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/' || 
                          state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';

      if (!isAuth && !isLoggingIn) return '/';
      if (isAuth && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workout',
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/add-user',
        builder: (context, state) => const AddUserScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
