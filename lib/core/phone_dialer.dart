import 'package:url_launcher/url_launcher.dart';

class PhoneDialer {
  static Future<bool> openDialer(String phone) async {
    final clean = phone.trim();
    if (clean.isEmpty) return false;

    final uri = Uri.parse('tel:$clean');
    return launchUrl(uri);
  }
}
