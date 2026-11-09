import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'Hương Vị Nguyên Bản',
      description:
          'Khám phá những hạt cà phê rang xay thượng hạng, tuyển chọn kỹ lưỡng từ các nông trại cao nguyên trứ danh.',
      icon: Icons.coffee_rounded,
    ),
    OnboardingItem(
      title: 'Bánh Ngọt Nướng Tươi',
      description:
          'Mỗi mẻ bánh ngọt và bánh mì tươi mới ra lò mỗi sớm mai, đồng hành trọn vẹn cùng tách cà phê của bạn.',
      icon: Icons.bakery_dining_rounded,
    ),
    OnboardingItem(
      title: 'Giao Hàng Siêu Tốc',
      description:
          'Đặt đồ uống và món ngon chỉ với vài chạm. Đơn hàng giao tới tận tay còn nóng hổi và đúng giờ.',
      icon: Icons.delivery_dining_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeAndNavigate() async {
    await ref.read(authNotifierProvider.notifier).completeOnboarding();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeAndNavigate,
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 76,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading1.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isLastPage ? 'Bắt đầu ngay' : 'Tiếp tục',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
