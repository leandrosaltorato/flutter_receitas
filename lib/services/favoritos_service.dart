import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  static const _key = 'favoritos';

  static final ValueNotifier<Set<int>> favoritos = ValueNotifier<Set<int>>({});

  static Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    favoritos.value = lista.map(int.parse).toSet();
  }

  static Future<void> alternar(int id) async {
    final novo = {...favoritos.value};
    if (!novo.remove(id)) novo.add(id);
    favoritos.value = novo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, novo.map((e) => '$e').toList());
  }
}
