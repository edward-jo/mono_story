List<String> splitStringWithWord(String target, String word) {
  assert(word.isNotEmpty);

  int ret, offset = 0;
  var list = <String>[];

  while (true) {
    if ((ret = target.indexOf(word, offset)) < 0) {
      list.add(target.substring(offset));
      break;
    } else {
      list.add(target.substring(offset, ret));
      offset = ret;
      list.add(target.substring(offset, offset + word.length));
      offset += word.length;
    }
  }
  return list;
}
