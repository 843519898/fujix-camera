import 'package:flutter_module/services/common_service.dart';
import '../../../utils/storage_util.dart';
import '../../../config/app_env.dart';

class TrackEvent {

  static Future<void> report(String category, String action, String? opt_label, String? opt_value, dynamic ext) async {
    if (AppEnv.checkEnvironment() != 'release') {
      return;
    }
    String token = '';
    final Map userInfo = await StorageUtil.getUserInfo();
    token = userInfo['token'] ?? '';
    final String strogeToken = await StorageUtil.getToken();
    reportApi({
      'action': 'baidu_event',
      'attributes': {
        'category': category,
        'action': action,
        'opt_label': opt_label ?? '',
        'opt_value': opt_value ?? '',
        'ext': ext ?? ''
      },
      'client_id': '',
      'platform': 10055,
      'refer': '',
      'site_id': 'cmm_jx',
      'token': token != '' ? token : strogeToken
    });
  }
}