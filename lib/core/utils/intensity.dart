import 'package:flutter/material.dart';
import '../../theme.dart';

String rotuloIntensidade(int valor) => switch (valor) {
  >= 1 && <= 5 => 'Leve',
  >= 6 && <= 8 => 'Moderado',
  _ => 'Intenso',
};

Color corIntensidade(BuildContext context, int valor) => switch (valor) {
  >= 1 && <= 5 => AppTheme.intensityLight,
  >= 6 && <= 8 => AppTheme.intensityModerate,
  _ => AppTheme.intensityHeavy,
};

Widget intensityChip({
  required BuildContext context,
  required int intensidade,
  VoidCallback? onPressed,
}) {
  return ActionChip(
    label: Text(rotuloIntensidade(intensidade)),
    backgroundColor: corIntensidade(context, intensidade),
labelStyle: TextStyle(
  color: intensidade >= 6 && intensidade <= 8 ? Colors.black : Colors.white,
  fontWeight: FontWeight.w600,
),
    onPressed: onPressed,
    tooltip: 'Filtrar por ${rotuloIntensidade(intensidade).toLowerCase()}',
  );
}