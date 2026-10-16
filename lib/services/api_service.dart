import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/receita.dart';

class ApiService {
  static const String baseUrl = 'https://receitasapi-b-2025.vercel.app';
  static const _headers = {'Content-Type': 'application/json; charset=UTF-8'};

  static final ValueNotifier<int> recarregar = ValueNotifier<int>(0);

  static Future<List<Receita>> listar() async {
    final res = await http.get(Uri.parse('$baseUrl/receitas'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar receitas (${res.statusCode})');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    return data
        .map((e) => Receita.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> criar(Receita r) async {
    final res = await http.post(
      Uri.parse('$baseUrl/receitas'),
      headers: _headers,
      body: jsonEncode(r.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erro ao cadastrar (${res.statusCode})');
    }
    recarregar.value++;
  }

  static Future<void> atualizar(Receita r) async {
    final res = await http.put(
      Uri.parse('$baseUrl/receitas/${r.id}'),
      headers: _headers,
      body: jsonEncode(r.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erro ao atualizar (${res.statusCode})');
    }
    recarregar.value++;
  }

  static Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/receitas/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao excluir (${res.statusCode})');
    }
    recarregar.value++;
  }
}
