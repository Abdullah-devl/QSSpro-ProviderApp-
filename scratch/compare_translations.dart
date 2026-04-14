import 'dart:convert';
import 'dart:io';

void main() async {
  final arFile = File('assets/lang/ar.json');
  final enFile = File('assets/lang/en.json');

  if (!await arFile.exists() || !await enFile.exists()) {
    print('Error: JSON files not found');
    return;
  }

  final arMap = json.decode(await arFile.readAsString()) as Map<String, dynamic>;
  final enMap = json.decode(await enFile.readAsString()) as Map<String, dynamic>;

  final arKeys = arMap.keys.toSet();
  final enKeys = enMap.keys.toSet();

  final onlyInAr = arKeys.difference(enKeys);
  final onlyInEn = enKeys.difference(arKeys);

  print('Keys only in ar.json:');
  for (var key in onlyInAr) {
    print('- $key');
  }

  print('\nKeys only in en.json:');
  for (var key in onlyInEn) {
    print('- $key');
  }
}
