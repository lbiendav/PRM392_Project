import 'package:url_launcher/url_launcher.dart';

class StoreContactRepository {
  Future<bool> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));
}
