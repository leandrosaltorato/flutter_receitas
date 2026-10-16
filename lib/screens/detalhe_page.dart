import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receita.dart';
import '../services/api_service.dart';
import '../services/favoritos_service.dart';
import '../widgets/receita_imagem.dart';
import 'form_page.dart';

class DetalhePage extends StatelessWidget {
  final Receita receita;

  const DetalhePage({super.key, required this.receita});

  Future<void> _editar(BuildContext context) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormPage(receita: receita)),
    );
    if (salvou == true && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _excluir(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text('Deseja realmente excluir "${receita.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || receita.id == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.excluir(receita.id!);
      if (context.mounted) Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Receita excluída.')));
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a receita.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moeda = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                receita.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ReceitaImagem(url: receita.img),
                  // Gradiente para dar leitura ao título
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ValueListenableBuilder<Set<int>>(
                valueListenable: FavoritosService.favoritos,
                builder: (context, favs, _) {
                  final fav = receita.id != null && favs.contains(receita.id);
                  return IconButton(
                    onPressed: receita.id == null
                        ? null
                        : () => FavoritosService.alternar(receita.id!),
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                  );
                },
              ),
              IconButton(
                onPressed: () => _editar(context),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _excluir(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(receita.tipoLabel),
                    ),
                    Chip(
                      avatar: const Icon(Icons.payments_outlined, size: 18),
                      label: Text(moeda.format(receita.custoAproximado)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _secao(context, 'Ingredientes', Icons.shopping_basket_outlined,
                    receita.ingredientes),
                const SizedBox(height: 24),
                _secao(context, 'Modo de fazer', Icons.soup_kitchen_outlined,
                    receita.modoFazer),
                SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
              ]),
            ),
          ),
        ],
      ),
      backgroundColor: scheme.surface,
    );
  }

  Widget _secao(
      BuildContext context, String titulo, IconData icone, String texto) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          texto,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}
