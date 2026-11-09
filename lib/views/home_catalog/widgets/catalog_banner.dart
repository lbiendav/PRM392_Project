import 'dart:async';
import 'package:flutter/material.dart';
import 'product_photo.dart';

class CatalogBanner extends StatefulWidget {
  final ValueChanged<String> onOpenCategory;
  const CatalogBanner({super.key, required this.onOpenCategory});

  @override
  State<CatalogBanner> createState() => _CatalogBannerState();
}

class _CatalogBannerState extends State<CatalogBanner> {
  static const slides = [
    (
      image: 'coffee-shop.jpg',
      title: 'Một tách ngon.\nMột ngày thật vui.',
      description: 'Cà phê đậm vị, bánh mới mỗi ngày.',
      category: 'all',
    ),
    (
      image: 'latte.jpg',
      title: 'Cà phê thơm.\nChọn vị bạn thích.',
      description: 'Pha chế theo kích cỡ bạn chọn.',
      category: 'coffee',
    ),
    (
      image: 'croissant.jpg',
      title: 'Bánh mới nướng.\nThêm chút ngọt ngào.',
      description: 'Một chiếc bánh cho giờ nghỉ của bạn.',
      category: 'bakery',
    ),
  ];
  late final Timer _timer;
  int _index = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted ||
          _paused ||
          !TickerMode.valuesOf(context).enabled ||
          ModalRoute.of(context)?.isCurrent == false ||
          MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context)) {
        return;
      }
      setState(() => _index = (_index + 1) % slides.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[_index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: ProductPhoto(
              source: 'assets/images/${slide.image}',
              label: 'Banner ${_index + 1}: ${slide.title}',
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.62)),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHẬM MỘT CHÚT, THƯỞNG MỘT CHÚT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.title,
                  key: const Key('banner-title'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => widget.onOpenCategory(slide.category),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Khám phá thực đơn'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${_index + 1} / ${slides.length}',
                      key: const Key('banner-page'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      tooltip: _paused ? 'Tự chuyển banner' : 'Tạm dừng banner',
                      color: Colors.white,
                      onPressed: () => setState(() => _paused = !_paused),
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                    ),
                    IconButton(
                      tooltip: 'Banner tiếp theo',
                      color: Colors.white,
                      onPressed: () => setState(() {
                        _paused = true;
                        _index = (_index + 1) % slides.length;
                      }),
                      icon: const Icon(Icons.navigate_next),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
