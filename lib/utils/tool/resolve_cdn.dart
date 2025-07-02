final RegExp cdnRegex = RegExp(r'~?@cdn\?(\w)(\w)(\w+)', multiLine: false);

String resolveCDN(
  String source, {
  String baseUrl = 'https://cdn-static.chanmama.com/sub-module/static-file',
  bool log = false,
}) {
  try {
    final replaced = source.replaceAllMapped(cdnRegex, (match) {
      return '$baseUrl/${match.group(1)}/${match.group(2)}/${match.group(3)}';
    });

    if (replaced.isNotEmpty) {
      if (log && cdnRegex.hasMatch(source)) {
        print('original value:$source');
        print('\x1B[32mreplaced @cdn value:$replaced\x1B[0m');
      }
    }

    return replaced;
  } catch (e) {
    print(e);
    return source;
  }
}
