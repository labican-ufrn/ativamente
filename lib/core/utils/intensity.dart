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

Widget intensityChip({
  required int intensidade,
  VoidCallback? onPressed,
}) {
  return ActionChip(
    label: Text(rotuloIntensidade(intensidade)),
    backgroundColor: corIntensidade(intensidade),
    labelStyle: TextStyle(
      color: intensidade >= 6 && intensidade <= 8 ? Colors.black : Colors.white,
      fontWeight: FontWeight.w600,
    ),
    onPressed: onPressed,
    tooltip: 'Filtrar por ${rotuloIntensidade(intensidade).toLowerCase()}',
  );
}