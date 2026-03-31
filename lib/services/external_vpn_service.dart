import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';

class ExternalVpnService {
  static const String baseUrl = 'http://37.60.249.108:3005';

  static Future<Map<String, dynamic>> getVpnConfig() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/vpn/config'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<String> downloadOvpnFile() async {
    final data = await getVpnConfig();

    if (data['ok'] != true) {
      throw Exception(data['message'] ?? 'فشل جلب ملف VPN');
    }

    final ovpn = data['ovpn']?.toString() ?? '';
    if (ovpn.isEmpty) {
      throw Exception('ملف VPN فارغ');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/client.ovpn');
    await file.writeAsString(ovpn, flush: true);

    return file.path;
  }

  static Future<void> openExternalVpnApp() async {
    final filePath = await downloadOvpnFile();
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      throw Exception('تعذر فتح ملف VPN في تطبيق خارجي');
    }
  }
}
