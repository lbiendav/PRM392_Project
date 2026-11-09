import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/views/product_cart/product_reviews_screen.dart';

void main() {
  test('tính điểm đánh giá trung bình', () {
    final reviews = [
      ProductReview(
        author: 'A',
        rating: 5,
        comment: 'Tốt',
        createdAt: DateTime(2026),
      ),
      ProductReview(
        author: 'B',
        rating: 3,
        comment: 'Ổn',
        createdAt: DateTime(2026),
      ),
    ];

    expect(averageReviewRating(reviews), 4);
  });

  test('danh sách rỗng có điểm trung bình bằng 0', () {
    expect(averageReviewRating([]), 0);
  });
}
