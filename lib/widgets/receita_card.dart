import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receita.dart';
import '../services/favoritos_service.dart';
import 'receita_imagem.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;

  const ReceitaCard({super.key, required this.receita, required this.onTap});

  static IconData iconeTipo(String tipo) {
    switch (tipo) {
      case 'DOCE':
        return Icons.cake_outlined;
      case 'BEBIDA':
        return Icons.local_cafe_outlined;
      default:
        return Icons.lunch_dining_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moeda = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              ReceitaImagem(url: receita.img, width: 110, height: 110),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        receita.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(iconeTipo(receita.tipo),
                              size: 16, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text(receita.tipoLabel,
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          const SizedBox(width: 12),
                          Icon(Icons.payments_outlined,
                              size: 16, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text(moeda.format(receita.custoAproximado),
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<Set<int>>(
                valueListenable: FavoritosService.favoritos,
                builder: (context, favs, _) {
                  final fav = receita.id != null && favs.contains(receita.id);
                  return IconButton(
                    onPressed: receita.id == null
                        ? null
                        : () => FavoritosService.alternar(receita.id!),
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? scheme.error : scheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
