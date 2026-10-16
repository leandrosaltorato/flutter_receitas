import 'package:flutter/material.dart';

class ReceitaImagem extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;

  const ReceitaImagem({super.key, required this.url, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      height: height,
      width: width,
      color: scheme.secondaryContainer,
      child: Icon(
        Icons.restaurant,
        size: 36,
        color: scheme.onSecondaryContainer,
      ),
    );

    if (url.trim().isEmpty) return placeholder;

    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          width: width,
          color: scheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
