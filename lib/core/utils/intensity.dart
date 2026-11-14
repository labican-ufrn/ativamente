import 'package:flutter/material.dart';
import '../../theme.dart';

String rotuloIntensidade(int valor) => switch (valor) {
  >= 1 && <= 5 => 'Leve',
  >= 6 && <= 8 => 'Moderado',
  >= 9 && <= 10 => 'Intenso',
  _ => throw ArgumentError('Intensidade deve estar entre 1 e 10.'),
};

Color corIntensidade(int valor) => switch (valor) {
  >= 1 && <= 5 => AppTheme.intensityLight,
  >= 6 && <= 8 => AppTheme.intensityModerate,
  >= 9 && <= 10 => AppTheme.intensityHeavy,
  _ => throw ArgumentError('Intensidade deve estar entre 1 e 10.'),
};

/// Chip de intensidade. Com [onPressed] é interativo (filtro na listagem);
/// sem ele é apenas informativo (tela de detalhe), com a mesma estilização.
Widget intensityChip({required int intensidade, VoidCallback? onPressed}) {
  final label = Text(rotuloIntensidade(intensidade));
  final background = corIntensidade(intensidade);
  final labelStyle = TextStyle(
    color: intensidade >= 6 && intensidade <= 8 ? Colors.black : Colors.white,
    fontWeight: FontWeight.w600,
  );

  if (onPressed == null) {
    return Chip(
      label: label,
      backgroundColor: background,
      labelStyle: labelStyle,
    );
  }

  return ActionChip(
    label: label,
    backgroundColor: background,
    labelStyle: labelStyle,
    onPressed: onPressed,
    tooltip: 'Filtrar por ${rotuloIntensidade(intensidade).toLowerCase()}',
  );
}
