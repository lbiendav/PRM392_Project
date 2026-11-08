import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/branch_model.dart';

void main() {
  test('branch checks regular and overnight hours', () {
    const regular = BranchModel(
      id: 'a',
      name: 'A',
      address: 'A',
      openMinute: 480,
      closeMinute: 1320,
    );
    expect(regular.isOpenAt(DateTime(2026, 1, 1, 8)), isTrue);
    expect(regular.isOpenAt(DateTime(2026, 1, 1, 22)), isFalse);

    const overnight = BranchModel(
      id: 'b',
      name: 'B',
      address: 'B',
      openMinute: 1200,
      closeMinute: 360,
    );
    expect(overnight.isOpenAt(DateTime(2026, 1, 1, 23)), isTrue);
    expect(overnight.isOpenAt(DateTime(2026, 1, 2, 4)), isTrue);
    expect(overnight.isOpenAt(DateTime(2026, 1, 2, 8)), isFalse);
  });
}
