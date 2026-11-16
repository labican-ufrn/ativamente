/// Utilitários para formatação de tempo no app AtivaMente.
library;

/// Formata uma duração em segundos no padrão `MM:SS`.
///
/// Exemplos:
/// - `0` -> `'00:00'`
/// - `59` -> `'00:59'`
/// - `65` -> `'01:05'`
/// - `3600` -> `'60:00'`
String formatarSegundos(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final remainingSeconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
