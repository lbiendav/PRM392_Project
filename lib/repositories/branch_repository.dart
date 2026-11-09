import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/branch_model.dart';

class BranchRepository {
  final FirebaseFirestore? firestore;

  BranchRepository({this.firestore});

  CollectionReference<Map<String, dynamic>> get _branches =>
      (firestore ?? FirebaseFirestore.instance).collection(
        AppConstants.colBranches,
      );

  Future<BranchModel?> getBranch(String id) async {
    final document = await _branches
        .doc(id)
        .get(const GetOptions(source: Source.server));
    final data = document.data();
    return data == null ? null : BranchModel.fromMap(data, document.id);
  }

  Stream<List<BranchModel>> watchBranches() {
    return _branches
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BranchModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
