import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../providers/auth_provider.dart';

class HelpAndFAQScreen extends ConsumerStatefulWidget {
  const HelpAndFAQScreen({super.key});

  @override
  ConsumerState<HelpAndFAQScreen> createState() => _HelpAndFAQScreenState();
}

class _HelpAndFAQScreenState extends ConsumerState<HelpAndFAQScreen> {
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Quán giao hàng trong bao lâu?',
      'a': 'Thời gian giao hàng trung bình từ 15 - 30 phút tùy thuộc vào khoảng cách từ chi nhánh gần nhất đến địa chỉ của bạn.',
    },
    {
      'q': 'Làm sao để tích điểm đổi quà thành viên?',
      'a': 'Mỗi 10.000đ chi tiêu trên đơn hàng hoàn tất, bạn sẽ được tự động tích lũy 1 điểm thưởng vào tài khoản.',
    },
    {
      'q': 'Tôi có thể hủy đơn hàng sau khi đặt không?',
      'a': 'Bạn có thể hủy đơn hàng khi đơn còn ở trạng thái "Đã tiếp nhận". Khi đơn chuyển sang "Đang pha chế", vui lòng gọi điện thoại trực tiếp cho chi nhánh.',
    },
  ];

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final userId = ref.read(authNotifierProvider).userModel?.id;
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': userId,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _feedbackController.clear();
      SnackBarUtils.showSuccess(context, 'Cảm ơn bạn đã gửi ý kiến đóng góp!');
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, 'Lỗi gửi phản hồi: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ Giúp & Góp Ý')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Câu Hỏi Thường Gặp (FAQ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ..._faqs.map(
                  (f) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(f['a']!, style: const TextStyle(color: Colors.grey, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            const Text('Gửi Góp Ý / Báo Lỗi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Hãy chia sẻ trải nghiệm hoặc báo lỗi để chúng tôi cải thiện tốt hơn...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Gửi Đóng Góp Ý Kiến'),
            ),
          ],
        ),
      ),
    );
  }
}