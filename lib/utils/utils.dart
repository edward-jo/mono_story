List<String> splitStringWithPattern(String target, RegExp pattern) {
  assert(pattern.pattern.isNotEmpty, 'Search pattern should have a value');
  String source = pattern.pattern;

  int ret, offset = 0;
  var list = <String>[];

  while (true) {
    if ((ret = target.indexOf(pattern, offset)) < 0) {
      list.add(target.substring(offset));
      break;
    } else {
      list.add(target.substring(offset, ret));
      offset = ret;
      list.add(target.substring(offset, offset + source.length));
      offset += source.length;
    }
  }
  return list;
}
