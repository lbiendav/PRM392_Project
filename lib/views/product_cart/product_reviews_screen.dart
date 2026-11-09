import 'package:flutter/material.dart';

class ProductReview {
  final String author;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ProductReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

double averageReviewRating(List<ProductReview> reviews) {
  if (reviews.isEmpty) return 0;

  final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);

  return total / reviews.length;
}

class ProductReviewsScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final _commentController = TextEditingController();
  final List<ProductReview> _reviews = [];
  int _selectedRating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nhận xét')));
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        ProductReview(
          author: 'Bạn',
          rating: _selectedRating,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
      _selectedRating = 5;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã gửi đánh giá')));
  }

  @override
  Widget build(BuildContext context) {
    final average = averageReviewRating(_reviews);

    return Scaffold(
      appBar: AppBar(title: Text('Đánh giá ${widget.productName}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                _StarDisplay(rating: average.round()),
                const SizedBox(height: 4),
                Text('${_reviews.length} lượt đánh giá'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _reviews.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có đánh giá.\nHãy là người đầu tiên nhận xét.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _StarDisplay(rating: review.rating),
                              const SizedBox(height: 8),
                              Text(review.comment),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;

                      return IconButton(
                        tooltip: '$value sao',
                        onPressed: () {
                          setState(() => _selectedRating = value);
                        },
                        icon: Icon(
                          value <= _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Viết nhận xét của bạn',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: 'Gửi đánh giá',
                        onPressed: _submitReview,
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarDisplay extends StatelessWidget {
  final int rating;

  const _StarDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }
}
