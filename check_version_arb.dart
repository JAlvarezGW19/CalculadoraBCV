import 'dart:io';

void main() async {
  final dir = Directory('lib/l10n');
  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.arb'),
  );

  for (final file in files) {
    String content = await file.readAsString();
    if (content.contains('"aboutAppSubtitle":')) {
      // Regex to replace version info in aboutAppSubtitle if it contains "Version X.X.X"
      // Wait, usually the version is displayed dynamically or hardcoded in a "version" key?
      // checking app_es.arb: "version": "Versión", "aboutAppSubtitle": "Versión, desarrollador y licencias"
      // It seems the number is NOT in the arb file but in the code.
      // Let's double check if there's a hardcoded version string in any arb file.
    }
  }
}
