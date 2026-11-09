import 'package:flutter/material.dart';

class ProductPhoto extends StatelessWidget {
  final String source;
  final String label;
  final BoxFit fit;
  const ProductPhoto({
    super.key,
    required this.source,
    required this.label,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const Center(child: Icon(Icons.local_cafe_outlined, size: 48)),
      );
    }

    if (source.isEmpty) return fallback(context, StateError('No image'), null);
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        width: double.infinity,
        semanticLabel: label,
        errorBuilder: fallback,
      );
    }
    return Image.network(
      source,
      fit: fit,
      width: double.infinity,
      semanticLabel: label,
      errorBuilder: fallback,
    );
  }
}
