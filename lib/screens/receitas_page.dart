import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/api_service.dart';
import '../services/favoritos_service.dart';
import '../widgets/receita_card.dart';
import 'detalhe_page.dart';

class ReceitasPage extends StatefulWidget {
  final String titulo;
  final bool apenasFavoritas;

  const ReceitasPage({
    super.key,
    required this.titulo,
    this.apenasFavoritas = false,
  });

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  List<Receita> _receitas = [];
  bool _carregando = true;
  String? _erro;
  String _busca = '';
  String? _tipo; 

  @override
  void initState() {
    super.initState();
    _carregar();
    ApiService.recarregar.addListener(_carregar);
  }

  @override
  void dispose() {
    ApiService.recarregar.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await ApiService.listar();
      lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _receitas = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as receitas.\nVerifique sua conexão.';
        _carregando = false;
      });
    }
  }

  List<Receita> _filtradas(Set<int> favs) {
    return _receitas.where((r) {
      if (widget.apenasFavoritas && !favs.contains(r.id)) return false;
      if (_tipo != null && r.tipo != _tipo) return false;
      if (_busca.isNotEmpty &&
          !r.nome.toLowerCase().contains(_busca.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              decoration: const InputDecoration(
                hintText: 'Buscar receita',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Todas', null),
                for (final t in Receita.tipos)
                  _chip(Receita(nome: '', tipo: t, ingredientes: '', modoFazer: '').tipoLabel, t),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Set<int>>(
              valueListenable: FavoritosService.favoritos,
              builder: (context, favs, _) => _conteudo(favs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _tipo == valor,
        onSelected: (_) => setState(() => _tipo = valor),
      ),
    );
  }

  Widget _conteudo(Set<int> favs) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48),
              const SizedBox(height: 12),
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _carregar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final lista = _filtradas(favs);
    if (lista.isEmpty) {
      return Center(
        child: Text(
          widget.apenasFavoritas
              ? 'Nenhuma receita favorita ainda.'
              : 'Nenhuma receita encontrada.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final r = lista[i];
          return ReceitaCard(
            receita: r,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetalhePage(receita: r)),
            ),
          );
        },
      ),
    );
  }
}
