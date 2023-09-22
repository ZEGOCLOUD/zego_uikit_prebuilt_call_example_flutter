import 'dart:core';
import 'dart:math' as math;

class ZIMWrapperStringUtils {
  static final _random = math.Random();
  static const _defaultPool = 'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';

  static String createRandomString(int size, {String pool = _defaultPool}) {
    final len = pool.length;
    var id = '';
    var i = size;
    while (0 < i--) {
      id += pool[_random.nextInt(len)];
    }
    return id;
  }

  static Future<String> createRandomStringAsync(int size, {String pool = _defaultPool}) async {
    return createRandomString(size, pool: pool);
  }
}

extension ZIMWrapperStringUtilsExtension on String {
  String get urlEncode {
    return replaceAll('#', '%23').replaceAll('&', '%26');
  }
}
