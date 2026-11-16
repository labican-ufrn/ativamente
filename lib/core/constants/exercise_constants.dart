/// Categorias e tipos padrão do catálogo de exercícios (nome e identificador de ícone).
/// Espelham as opções definidas no catálogo seed `assets/data/exercises.json`.
library;

/// Categorias padrão de exercícios.
const defaultExerciseCategories = <(String, String)>[
  ('Coracao', 'favorite'),
  ('Equilibrio', 'balance'),
  ('Flexibilidade', 'accessibility_new'),
  ('Musculo', 'fitness_center'),
  ('NaRua', 'park'),
];

/// Tipos padrão de exercícios.
const defaultExerciseTypes = <(String, String)>[
  ('Cardio', 'directions_run'),
  ('Estabilidade', 'accessibility'),
  ('Alongamento', 'self_improvement'),
  ('Forca', 'fitness_center'),
];
